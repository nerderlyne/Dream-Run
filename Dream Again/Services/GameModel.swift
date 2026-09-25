import Foundation
import SwiftUI
import Combine
import UIKit

@MainActor private final class DreamDisplayTarget:NSObject {
    weak var owner:GameModel?
    @objc func tick(_ display:CADisplayLink) {
        guard let owner else {display.invalidate();return}
        owner.frame(display)
    }
}

@MainActor final class GameModel:NSObject,ObservableObject {
    @Published var screen="home"
    @Published var simulation=GameSimulation(identity:DreamIdentity.current(seed:42))
    @Published var profile=Profile()
    @Published var error:String?
    @Published var notice=""
    @Published var settings=Settings()
    @Published var shareItems:[Any]=[]
    @Published var sharing=false
    @Published var catalogue:[CosmeticDefinition]=[]
    @Published var achievements:[AchievementDefinition]=[]
    @Published var assets:[AssetDefinition]=[]
    @Published var labAsset=1
    @Published var labPalette=0
    @Published var labStyle=0
    @Published var labLOD=0
    @Published var labColliders=false
    var palettes:[PaletteDefinition]=[]
    var rules=RunRules()
    var renderer:DreamRenderer?
    #if DEBUG
    @Published var obstacleReview:DreamObstacle?
    @Published var collageMotion=false
    @Published var collageSceneIndex:Int?
    var artEquipped:[String:String]?
    var artIdle=false
    private var collageCaptureSignalled=false
    var performanceRun: FrameRecorder?
    #endif
    var store:ProfileStore?
    var commerce:BalloonStore?
    var input=InputFrame()
    var homeDream=GameSimulation(identity:DreamIdentity.current(seed:42),mode:.reviewDemo)
    var homeFrames=0
    var motion=MotionInput(), audio=DreamAudio()
    private let displayTarget=DreamDisplayTarget()
    var link:CADisplayLink?
    var artReview=false
    var previousTime=0.0
    var clock=FixedStepClock()
    private var idleSceneRunID:UUID?
    private var idleSceneTextureCount = -1
    private var idleSceneViewport = CGSize.zero
    private let horizonWarmup=HorizonWarmup()
    @Published var provider:any RewardedContinueProvider = DisabledRewardProvider()
    var active:Bool { screen == "gameplay" }
    // Simulator has no motion sensor. This is a test-environment adapter, not a player setting.
    var simulatorDragInput:Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    var run:RunState { simulation.state }
    override init() {
        super.init()
        do {
            func read<T:Decodable>(_ name:String,_ key:String) throws -> T {
                guard let url=Bundle.main.url(forResource:name,withExtension:"json") else { throw DreamError.corruptStore }
                let object=try JSONSerialization.jsonObject(with:Data(contentsOf:url)) as! [String:Any]
                return try JSONDecoder().decode(T.self,from:JSONSerialization.data(withJSONObject:object[key]!))
            }
            guard let rulesURL=Bundle.main.url(forResource:"game_config",withExtension:"json") else {throw DreamError.corruptStore}
            rules=try RunRules(configData:Data(contentsOf:rulesURL))
            catalogue=try read("cosmetics","items"); achievements=try read("achievements","achievements"); assets=try read("asset_catalog","assets"); palettes=try read("palettes","palettes")
            guard assets.count == 42, assets.last?.id == "pig" else { throw DreamError.corruptStore }
            var directory=try FileManager.default.url(for:.applicationSupportDirectory,in:.userDomainMask,appropriateFor:nil,create:true).appendingPathComponent("DreamAgain",isDirectory:true)
            #if DEBUG
            let args=ProcessInfo.processInfo.arguments
            if args.contains("--performance-run") || args.contains("--ui-test") || args.contains("--art-review") || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                directory=FileManager.default.temporaryDirectory.appendingPathComponent("DreamReview-\(UUID().uuidString)",isDirectory:true)
            }
            #endif
            // This unreleased course revision uses a fresh development store;
            // keep the superseded profile on disk rather than treating it as corrupt.
            let store=try ProfileStore(url:directory.appendingPathComponent("profile-g2-r2.json")); self.store=store; profile=store.profile; settings=profile.settings
            if store.recoveredBackup { error="A damaged save was preserved and the last good backup was recovered. Progress since that backup may be missing." }
            #if DEBUG
            if !args.contains("--performance-run") { commerce=BalloonStore(store:store) }
            #else
            commerce=BalloonStore(store:store)
            #endif
            renderer=DreamRenderer(palettes:palettes)
            renderer?.render(run,equipped:profile.equipped,menu:true)
            #if !DEBUG && canImport(GoogleMobileAds) && canImport(UserMessagingPlatform)
            if DreamAdConfiguration.liveAdsEnabled {
                Task { await configureLiveAds() }
            }
            #endif
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--ui-test") { settings.music=false; settings.effects=false }
            if ProcessInfo.processInfo.arguments.contains("--art-review") {
                artReview=true;settings.music=false;settings.effects=false
                let arguments=ProcessInfo.processInfo.arguments
                let theme=arguments.firstIndex(of:"--art-theme").flatMap{index in arguments.indices.contains(index+1) ? Int(arguments[index+1]) : nil} ?? 0
                let distance=arguments.firstIndex(of:"--art-distance").flatMap{index in arguments.indices.contains(index+1) ? Double(arguments[index+1]) : nil} ?? 37.5
                let pose=arguments.firstIndex(of:"--art-pose").flatMap{index in arguments.indices.contains(index+1) ? arguments[index+1] : nil} ?? "run"
                labArt(theme:theme,distance:distance,pose:pose)
                if let i=arguments.firstIndex(of:"--collage-scene"),arguments.indices.contains(i+1),let n=Int(arguments[i+1]) {
                    labCollage(index:n);collageMotion=arguments.contains("--collage-moving")
                }
                if let index=arguments.firstIndex(of:"--art-transition-to"),arguments.indices.contains(index+1),let target=Int(arguments[index+1]) {
                    let elapsed=arguments.firstIndex(of:"--art-transition-time").flatMap {i in arguments.indices.contains(i+1) ? Double(arguments[i+1]) : nil} ?? 8
                    labPaletteEvolution(to:target,elapsed:elapsed)
                }

                if arguments.contains("--wardrobe-review") {
                    let bottom=arguments.firstIndex(of:"--bottom").flatMap {i in arguments.indices.contains(i+1) ? arguments[i+1] : nil} ?? "plain_bottom"
                    let hat=arguments.firstIndex(of:"--hat").flatMap {i in arguments.indices.contains(i+1) ? arguments[i+1] : nil} ?? "bare_head"
                    let equipped=["bottom":bottom,"hat":hat]
                    artEquipped=equipped
                    renderer?.render(run,equipped:equipped)
                    if pose == "portrait" {renderer?.previewAvatar(equipped:equipped)}
                }
                if arguments.contains("--design-review") {
                    func arg(_ key:String,_ fallback:String)->String {arguments.firstIndex(of:key).flatMap {i in arguments.indices.contains(i+1) ? arguments[i+1]:nil} ?? fallback}
                    labDesign(theme:theme,pose:pose,variant:Int(arg("--variant","0")) ?? 0,sky:arg("--sky",DreamCollageKit.skyIDs[0]),pattern:TrackPattern(rawValue:arg("--pattern","checker")) ?? .checker,mirror:arguments.contains("--design-mirror"),contrast:arguments.contains("--design-contrast"))
                    if let kind=DreamObstacle(rawValue:arg("--obstacle","")) {labObstacle(kind,striking:arguments.contains("--strike"))}
                    if arguments.contains("--jump-sequence") {labJumpSequence(arg("--jump-sequence","ascending"))}
                    if arguments.contains("--straw-limbs") {
                        let n=max(0,min(4,Int(arg("--straw-limbs","0")) ?? 0))
                        simulation.state.player.missingLimbs=Array(StrawLimb.allCases.prefix(n))
                        simulation.state.hazards=[]
                        for i in simulation.state.chunks.indices {simulation.state.chunks[i].pickups=[]}
                        simulation.state.chunks[0].pickups.append(PickupDescription(id:"straw:preview",distance:run.distance+4,lateral:-0.85,height:0.45,kind:.straw))
                        if n<4 {renderer?.lastStrawState=simulation.state.player.missingLimbs}
                        if n == 4 {simulation.wake("unravelled")}
                        renderer?.render(run,equipped:profile.equipped)
                        if n == 4 {simulation.state.endingElapsed=0.55}
                    }
                    if let value=Int(arg("--vignette","-1")),let vignette=DreamVignette(rawValue:value) {labVignette(vignette)}
                    if let value=Int(arg("--scale-event","-1")),let event=DreamScaleEvent(rawValue:value) {labScale(event,framing:DreamScaleFraming(rawValue:Int(arg("--scale-framing","-1")) ?? -1))}
                    collageMotion=arguments.contains("--collage-moving")
                }
                if let i=arguments.firstIndex(of:"--composition-seed"),arguments.indices.contains(i+1),let seed=UInt64(arguments[i+1]) {
                    labCollage(index:0,seed:seed)
                    renderer?.artPalette=nil
                }
            }

            #endif
        } catch { self.error=error.localizedDescription }
        displayTarget.owner=self
        link=CADisplayLink(target:displayTarget,selector:#selector(DreamDisplayTarget.tick(_:))); link?.add(to:.main,forMode:.common)
        link?.preferredFramesPerSecond = settings.lowPower ? 30 : 60
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--performance-run") {
            let args=ProcessInfo.processInfo.arguments
            func argument(_ name:String)->String? {
                guard let i=args.firstIndex(of:name),args.indices.contains(i+1) else{return nil}
                return args[i+1]
            }
            let recorder=FrameRecorder(duration:Double(argument("--performance-seconds") ?? "120") ?? 120,seed:UInt64(argument("--performance-seed") ?? "42") ?? 42)
            performanceRun=recorder
            UIApplication.shared.isIdleTimerDisabled=true
            Task { @MainActor [weak self] in
                try? await Task.sleep(for:.seconds(2))
                guard let self else{return}
                self.start(identity:.current(seed:recorder.seed),mode:.debug)
                self.audio.prepare(run:self.run,settings:self.settings)
                self.simulation.resume()
                self.notice="Performance test · automated · no rewards"
                PerformanceTrace.recorder=recorder
            }
        }
        #endif
        NotificationCenter.default.addObserver(self,selector:#selector(interrupted(_:)),name:AVAudioSession.interruptionNotification,object:nil)
        NotificationCenter.default.addObserver(self,selector:#selector(audioRouteChanged(_:)),name:AVAudioSession.routeChangeNotification,object:nil)
    }
    @objc func interrupted(_ notification:Notification) {
        guard let type=notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt, type == AVAudioSession.InterruptionType.began.rawValue else {return}
        audio.stop(); pause()
    }
    @objc func audioRouteChanged(_ notification:Notification) {
        guard let reason=notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue else { return }
        audio.stop(); pause()
    }
    func refresh() { if let store { profile=store.profile } }
    func transact(_ action:(inout Profile)throws->Void) {
        guard let store else { error="Storage is unavailable. Retry after resolving the saved profile error."; return }
        do { try PerformanceTrace.measure("Persistence") {try store.transaction(action)}; refresh() } catch { self.error=error.localizedDescription; simulation.pause() }
    }
    func claimReviewRequest() -> Bool {
        guard let store else { return false }
        var claimed=false
        do {
            try store.transaction { claimed=$0.claimReviewRequest() }
            refresh()
            return claimed
        } catch {
            self.error=error.localizedDescription
            return false
        }
    }
    private func checkpoint(_ snapshot:RunState) {
        guard let store else {return}
        let catalogue=achievements
        // Copy immutable simulation data, then encode and commit on the store's
        // single FIFO writer. Pause/finish use its synchronous draining barrier.
        store.transactionAsync({profile in
            profile.snapshot=snapshot
            profile.settle(snapshot,finished:false,catalogue:catalogue)
        },completion:{[weak self] result in
            guard let owner=self else{return}
            Task { @MainActor in
                switch result {
                case .success:owner.refresh()
                case .failure(let error):
                    owner.error=error.localizedDescription
                    owner.simulation.pause();owner.motion.stop();owner.audio.stop()
                }
            }
        })
    }
    func start(identity:DreamIdentity? = nil,mode:RunMode? = nil) {
        artReview=false;renderer?.artPalette=nil;renderer?.artPattern=nil;renderer?.art.collage.previewPlate=nil
        #if DEBUG
        artEquipped=nil;artIdle=false;obstacleReview=nil;renderer?.art.collage.previewVignette=nil;renderer?.art.collage.previewScale=nil;renderer?.art.collage.previewFraming=nil
        #endif
        guard store != nil, renderer != nil else { error="The game resources or profile could not be loaded."; return }
        if let identity, !identity.supported { error=DreamError.unsupportedVersion.localizedDescription; return }
        var selectedMode=mode ?? (identity == nil ? (profile.achievements.contains("first_dream") ? .fresh : .tutorial) : .revisit)
        #if DEBUG
        if performanceRun != nil {selectedMode = .debug}
        #endif
        if selectedMode.earns,let suspended=profile.snapshot,![RunPhase.finished,.waking].contains(suspended.phase) {
            var abandoned=suspended;abandoned.phase = .finished;abandoned.cause="started another dream"
            transact {$0.settle(abandoned,finished:true,catalogue:achievements);$0.snapshot=nil}
            if error != nil {return}
        }
        renderer?.prepareGameplay()
        simulation=GameSimulation(identity:identity ?? DreamIdentity.current(seed:UInt64.random(in:UInt64.min...UInt64.max)),mode:selectedMode)
        screen="gameplay"; input=InputFrame(); previousTime=0; clock.reset()
        renderer?.render(run,equipped:profile.equipped); persist()
    }
    func ready() {
        artReview=false
        notice="";input=InputFrame()
        if !simulatorDragInput { motion.start(); motion.calibrate() }
        audio.prepare(run:run,settings:settings)
        simulation.resume(); previousTime=0; clock.reset(); persist()
    }
    func pause() { guard active else { return }; simulation.pause(); motion.stop(); audio.stop(); previousTime=0; clock.reset(); input=InputFrame(); persist() }
    func persist() {
        guard run.mode.earns else {return}
        let snapshot=run
        transact { $0.snapshot=snapshot; $0.settings=settings }
    }
    func resumeSaved() {
        artReview=false;renderer?.artPalette=nil
        guard let snapshot=profile.snapshot else { return }
        do {
            renderer?.prepareGameplay()
            simulation=try GameSimulation(snapshot:snapshot)
            if profile.grants.contains(where:{$0.runID == snapshot.id && !$0.consumed}) {
                var restored=simulation
                transact { _=$0.consumeContinue(&restored) }
                if profile.snapshot?.continueCount == 1 { simulation=restored }
            }
            if [.finished,.waking].contains(run.phase) { screen="results" }
            else { if run.phase != .ready && run.phase != .paused { simulation.pause() }; screen="gameplay" }
            renderer?.render(run,equipped:profile.equipped); previousTime=0
        } catch { self.error=error.localizedDescription }
    }
    func leave() { pause(); screen="home" }
    func endRun() { simulation.resume(); simulation.wake("left the dream"); finish(); screen="results" }
    func finish() { renderer?.snapshot { [weak self] image in self?.renderer?.frozenFrame=image }; let result=run; if result.mode.earns {transact { $0.settle(result,finished:true,catalogue:achievements); $0.snapshot=result }}; audio.stop(preserveThunder:result.cause == "lightning"); motion.stop() }
    func saveDream(title:String = "Remembered dream") {
        let result=run
        let bookmark=Bookmark(run:result,title:title)
        transact { p in
            p.bookmarks.append(bookmark)
            if result.mode.earns { p.unlock("remembered_dream",catalogue:achievements) }
        }
        notice="Dream saved. Revisiting begins from the start."
        renderer?.snapshot { [weak self] image in
            guard let self,let image,let store=self.store else {return}
            do {
                let directory=store.url.deletingLastPathComponent().appendingPathComponent("thumbnails")
                try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
                let name=bookmark.id.uuidString+".jpg",url=directory.appendingPathComponent(name)
                let size=CGSize(width:240,height:360)
                let thumbnail=UIGraphicsImageRenderer(size:size).image{_ in image.draw(in:CGRect(origin:.zero,size:size))}
                if let data=thumbnail.jpegData(compressionQuality:0.65) {try data.write(to:url,options:.atomic);self.transact {p in if let i=p.bookmarks.firstIndex(where:{$0.id == bookmark.id}) {p.bookmarks[i].thumbnail=name}}}
                let files=try FileManager.default.contentsOfDirectory(at:directory,includingPropertiesForKeys:[.creationDateKey]).sorted{a,b in (try? a.resourceValues(forKeys:[.creationDateKey]).creationDate) ?? .distantPast < (try? b.resourceValues(forKeys:[.creationDateKey]).creationDate) ?? .distantPast}
                for file in files.prefix(max(0,files.count-100)) {try? FileManager.default.removeItem(at:file)}
            } catch {self.notice="Dream saved; thumbnail unavailable."}
        }
    }
    func importCode(_ code:String) {
        do { let normalized=code.hasPrefix("dreamlooper://dream/") ? String(code.dropFirst("dreamlooper://dream/".count)) : code; start(identity:try DreamIdentity.parse(normalized),mode:.revisit) } catch { self.error=error.localizedDescription }
    }
    func importURL(_ url:URL) {
        if url.scheme == "dreamlooper" { importCode(url.lastPathComponent); return }
        let access=url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }
        do { let values=try url.resourceValues(forKeys:[.fileSizeKey]); guard values.fileSize ?? 32769 <= 32768 else { throw DreamError.invalidCode }; start(identity:try DreamFile.read(Data(contentsOf:url)),mode:.revisit) } catch { self.error=error.localizedDescription }
    }
    func share() {
        let result=run
        let caption="Dreamlooper · \(result.mode.rawValue) · \(time(result.activeTicks)) · \(result.continueCount) continues\n\(result.identity.code)\nRules \(result.identity.rulesVersion) · \(result.pigs.count)/3 clover pigs"
        do {
            let url=FileManager.default.temporaryDirectory.appendingPathComponent("DreamAgain.dream")
            try JSONEncoder().encode(DreamFile(result.identity)).write(to:url,options:.atomic)
            let card=ShareCard(run:result)
            let render=ImageRenderer(content:card); render.scale=2
            shareItems=[caption,url]; if let snapshot=renderer?.frozenFrame {shareItems.append(snapshot)}; if let image=render.uiImage { shareItems.append(image) }; sharing=true
        } catch { self.error=error.localizedDescription }
    }
    func buy(_ item:CosmeticDefinition) { transact { try $0.buy(item) } }
    func equip(_ item:CosmeticDefinition) { guard profile.owned.contains(item.id) || (item.balloon_price == 0 && item.required_achievement == nil) else { return }; transact { $0.owned.insert(item.id); $0.equipped[item.slot]=item.id }; renderer?.dress(profile.equipped) }
    func saveSettings() { link?.preferredFramesPerSecond=settings.lowPower ? 30 : 60;transact { $0.settings=settings } }
    func time(_ ticks:UInt64)->String { let seconds=ticks/60; return String(format:"%02lld:%02lld:%02lld",seconds/3600,(seconds/60)%60,seconds%60) }
    func continueDream() async {
        #if DEBUG
        if provider is MockRewardProvider && run.mode != .debug { notice="Developer rewards require a nonrewarding Lab run."; return }
        #endif
        let outcome=await provider.present()
        switch outcome {
        case .earned(let event):
            var candidate=simulation
            #if DEBUG
            if provider is MockRewardProvider {
                var isolated=Profile();_=isolated.grantContinue(eventID:event,run:candidate.state);_=isolated.consumeContinue(&candidate)
                simulation=candidate;audio.prepare(run:run,settings:settings);screen="gameplay";previousTime=0;return
            }
            #endif
            transact { _=$0.grantContinue(eventID:event,run:candidate.state) }
            transact { _=$0.consumeContinue(&candidate) }
            if profile.snapshot?.continueCount == 1 { simulation=candidate; audio.prepare(run:run,settings:settings);screen="gameplay"; previousTime=0 }
        case .dismissed: notice="No reward was earned. Clover odds are unchanged."
        case .unavailable: notice="Rewarded continue is unavailable. Start another dream for free."
        case .failed(let message): notice=message
        }
    }
    #if canImport(GoogleMobileAds) && canImport(UserMessagingPlatform)
    private func makeGoogleProvider(unitID:String,saveRewards:Bool) -> GoogleRewardedProvider {
        GoogleRewardedProvider(unitID:unitID,currentRun:{ [weak self] in self?.run ?? GameSimulation(identity:DreamIdentity.current(seed:42),mode:.reviewDemo).state },persistEarned:{ [weak self] event,offeredRun in
            guard let self else { return false }
            if !saveRewards { self.notice="Google test reward callback received. No continue was granted."; return false }
            guard let store=self.store else { return false }
            do {
                var granted=false
                try store.transaction { granted=$0.grantContinue(eventID:event,run:offeredRun) }
                self.refresh()
                return granted
            } catch { self.error=error.localizedDescription; return false }
        },availabilityChanged:{ [weak self] in self?.objectWillChange.send() })
    }
    private func configureLiveAds() async {
        let google=makeGoogleProvider(unitID:DreamAdConfiguration.rewardedUnitID,saveRewards:true)
        do { try await google.prepare(); provider=google }
        catch { notice="Rewarded ads are unavailable: \(error.localizedDescription)" }
    }
    var adPrivacyOptionsRequired:Bool { (provider as? GoogleRewardedProvider)?.privacyOptionsRequired == true }
    func showAdPrivacyOptions() async {
        guard let google=provider as? GoogleRewardedProvider else { return }
        do { try await google.privacyOptions() }
        catch { notice="Ad privacy options unavailable: \(error.localizedDescription)" }
    }
    #if DEBUG
    func labGoogleTestAd() async {
        let google=makeGoogleProvider(unitID:DreamAdConfiguration.testRewardedUnitID,saveRewards:false)
        do {
            try await google.prepare()
            let outcome=await google.present()
            switch outcome {
            case .earned: notice="Google test reward callback received. No continue was granted."
            case .dismissed: notice="Google test ad closed without a reward."
            case .unavailable: notice="Google test ad unavailable."
            case .failed(let message): notice=message
            }
        } catch { notice="Google test ad unavailable: \(error.localizedDescription)" }
    }
    #endif
    #endif
    @objc func frame(_ display:CADisplayLink) {
        renderer?.art.collage.reducedMotion=settings.reducedMotion
        if artReview {
            #if DEBUG
            if collageMotion,renderer?.art.collage.ready == true {
                let now=display.timestamp
                if previousTime>0 {
                    for _ in 0..<(clock.consume(now-previousTime) ?? 0) {
                        // Review run uses the real simulation at normal speed; no rewards.
                        if obstacleReview == nil {simulation.state.safeUntilDistance=simulation.state.distance+1000}
                        _=simulation.step(input);_=simulation.presentationStep(1.0/60);input.jump=false;input.slide=false
                    }
                }
                previousTime=now
            } else {previousTime=0}
            renderer?.render(run,equipped:artEquipped ?? profile.equipped,menu:artIdle)
            if !collageCaptureSignalled,renderer?.art.collage.ready == true {
                let args=ProcessInfo.processInfo.arguments
                if let i=args.firstIndex(of:"--collage-capture-token"),args.indices.contains(i+1),let token=UUID(uuidString:args[i+1]) {
                    let path=URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("collage-ready-\(token.uuidString).txt")
                    try? Data("Current plate and collage cutouts ready; DEBUG no rewards".utf8).write(to:path,options:.atomic)
                    collageCaptureSignalled=true
                }
            }
            #endif
            return
        }
        if screen == "home",let renderer {
            homeFrames += 1
            if homeFrames%2 == 0 {
                let old=Int(homeDream.state.distance/24)
                homeDream.state.activeTicks += 2;homeDream.state.distance += 0.025
                if Int(homeDream.state.distance/24) != old {homeDream.streamChunks()}
                renderer.render(homeDream.state,equipped:profile.equipped,menu:true,lowPower:true)
            }
            previousTime=0;return
        }
        guard active, renderer != nil else { previousTime=0; return }
        if [.ready,.paused].contains(run.phase),let renderer {
            // The first scene pass may run before the ARView has its final size,
            // and collage textures arrive asynchronously. Refresh the still
            // scene as each resource arrives instead of waiting for Ready.
            let textureCount=renderer.art.collage.loadedTextureCount
            let viewport=renderer.view.bounds.size
            if idleSceneRunID != run.id || idleSceneTextureCount != textureCount || idleSceneViewport != viewport {
                renderer.render(run,equipped:profile.equipped,lowPower:settings.lowPower)
                idleSceneRunID=run.id
                idleSceneTextureCount=textureCount
                idleSceneViewport=viewport
            }
            previousTime=0
            return
        }
        #if DEBUG
        if let recorder=performanceRun, !recorder.complete {
            recorder.begin()
        }
        defer {
            if let recorder=performanceRun, !recorder.complete {
                recorder.end(run:run,entities:renderer?.renderEntities ?? 0)
                if recorder.complete {
                    simulation.pause(); audio.stop(); motion.stop()
                    UIApplication.shared.isIdleTimerDisabled=false
                    PerformanceTrace.recorder=nil
                    recorder.export()
                    notice="Performance test complete"
                }
            }
        }
        if let recorder=performanceRun,!recorder.complete,run.phase == .finished {
            start(identity:.current(seed:run.identity.seed &+ 1),mode:.debug)
            audio.prepare(run:run,settings:settings)
            simulation.resume()
        }
        #endif
        horizonWarmup.request(run)
        let now=display.timestamp
        if previousTime == 0 { previousTime=now; return }
        let delta=now-previousTime; previousTime=now
        if [.ready,.paused,.finished].contains(run.phase) { return }
        if [.waking,.luckyTransition,.whiteEnding,.resuming].contains(run.phase) {
            let events=simulation.presentationStep(delta)
            renderer?.render(run,equipped:profile.equipped,lowPower:settings.lowPower)
            audio.update(run:run,settings:settings,delta:delta)
            if events.contains(.ending) {
                finish()
                #if DEBUG
                if performanceRun == nil { screen="results" }
                #else
                screen="results"
                #endif
            }
            return
        }
        guard let steps=clock.consume(delta) else {clock.reset();return}
        var automated=false
        #if DEBUG
        automated=performanceRun != nil
        #endif
        if !simulatorDragInput && !automated {
            if let steering=motion.sample(settings:settings,now:now,fullScaleDegrees:run.rules.tiltFullScaleDegrees) {input.steering=steering}
            else {input.steering=0;notice="Tilt input was interrupted. Hold your device comfortably and tap ready to recalibrate.";pause();return}
        }
        for _ in 0..<steps {
            #if DEBUG
            if performanceRun != nil { input=EncounterOracle.input(run) }
            #endif
            let before=run
            let events=PerformanceTrace.measure("Simulation") {simulation.step(input)}; input.jump=false; input.slide=false
            PerformanceTrace.measure("MovementAudio") {audio.movement(before:before,after:run,settings:settings)}
            if events.contains(.thunder) {audio.feedback(.thunder,settings:settings)}
            if events.contains(.strawBreak) {audio.feedback(.strawBreak,settings:settings)}
            if events.contains(.strawRepair) {audio.feedback(.strawRepair,settings:settings)}
            if events.contains(.stumble) && !events.contains(.strawBreak) { audio.feedback(.stumble,settings:settings) }
            else if events.contains(.clover) { audio.feedback(.clover,settings:settings) }
            else if events.contains(.balloon) { audio.feedback(.balloon,settings:settings,tick:run.activeTicks) }
            if events.contains(.mirror) { audio.feedback(.mirror,settings:settings) }
            if events.contains(.drop) { audio.feedback(.drop,settings:settings) }
            if events.contains(.waking) && run.cause != "unravelled" { finish() }
            if (run.mode.earns || automated) && (events.contains(.strawBreak) || events.contains(.strawRepair) || events.contains(.pigCommitted) || events.contains(.clover) || run.activeTicks%900 == 0) {
                let snapshot=run
                PerformanceTrace.measure("CheckpointEnqueue") {checkpoint(snapshot)}
            }
            if [.waking,.luckyTransition].contains(run.phase) { break }
        }
        PerformanceTrace.measure("Render") {renderer?.render(run,equipped:profile.equipped,lowPower:settings.lowPower || ProcessInfo.processInfo.thermalState.rawValue >= ProcessInfo.ThermalState.serious.rawValue)}
        PerformanceTrace.measure("Audio") {audio.update(run:run,settings:settings,delta:delta)}
    }
    #if DEBUG
    func labScale(_ event:DreamScaleEvent,framing:DreamScaleFraming?=nil) {
        labCollage(index:0)
        renderer?.art.collage.previewScale=event;renderer?.art.collage.previewFraming=framing
        simulation.state.distance=200
        renderer?.art.collage.reset();renderer?.lastRun=nil
        renderer?.render(run,equipped:profile.equipped)
    }
    func labVignette(_ kind:DreamVignette) {
        labCollage(index:kind.rawValue)
        renderer?.art.collage.previewVignette=kind
        simulation.state.distance=150
        renderer?.art.collage.reset();renderer?.lastRun=nil;renderer?.render(run,equipped:profile.equipped)
    }
    func labJumpSequence(_ variant:String) {
        labCollage(index:0)
        let first=variant == "late" ? 196:4
        let seed=(UInt64(0)..<100).first {seed in
            let c=WorldGenerator(.current(seed:seed)).jumpSequenceChunk(first)!
            if variant == "late" {return c.step != nil}
            if variant == "ascending" {return c.step != nil && c.gap == nil}
            if variant == "floating" {return c.step != nil && c.gap != nil}
            return c.step == nil
        } ?? 0
        simulation.state.identity = .current(seed:seed)
        simulation.state.safeUntilDistance=0;simulation.state.activeTicks=36000
        simulation.state.distance=Double(first)*24+4
        let generator=WorldGenerator(simulation.state.identity)
        simulation.state.chunks=(first-2...first+10).map {i in
            generator.jumpSequenceChunk(i) ?? ChunkDescription(id:i,routeFamily:.trackStraight,start:Double(i)*24,hazards:[],pickups:[],scenery:[],recipe:0)
        }
        simulation.state.hazards=simulation.state.chunks.flatMap(\.hazards)
        renderer?.lastRun=nil;renderer?.render(run,equipped:profile.equipped)
    }
    func labObstacle(_ kind:DreamObstacle,striking:Bool=false) {
        labCollage(index:0);obstacleReview=kind
        simulation.state.safeUntilDistance=0;simulation.state.activeTicks=36000
        simulation.state.distance=kind == .lightning ? (striking ? 118:72):90
        let generator=WorldGenerator(simulation.state.identity)
        simulation.state.chunks=(0...14).map {i in
            ChunkDescription(id:i,routeFamily:.trackStraight,start:Double(i)*24,hazards:[],pickups:[],scenery:[],recipe:0)
        }
        let chunk=generator.encounterChunk(kind == .lightning ? 5:kind == .animals ? 6:4,kind:kind,tier:2)
        if kind == .animals {simulation.state.distance=138}
        simulation.state.chunks[chunk.id]=chunk
        simulation.state.hazards=chunk.hazards.map {h in
            var h=h;h.spawnTick=simulation.state.activeTicks
            if h.encounter == .lightning {h.strikeTick=simulation.state.activeTicks+(striking ? 0:164)}
            return h
        }
        if let hazard=simulation.state.hazards.first {
            let args=ProcessInfo.processInfo.arguments
            if let index=args.firstIndex(of:"--obstacle-ahead"),args.indices.contains(index+1),let ahead=Double(args[index+1]) {
                simulation.state.distance=hazard.distance-max(1,ahead)
            } else if args.contains("--obstacle-close") {simulation.state.distance=hazard.distance-5}
        }
        renderer?.lastRun=nil;renderer?.render(run,equipped:profile.equipped)
    }
    func labDesign(theme:Int,pose:String="run",variant:Int=0,sky:String=DreamCollageKit.skyIDs[0],pattern:TrackPattern = .checker,mirror:Bool=false,contrast:Bool=false) {
        labCollage(index:0)
        renderer?.artPalette=max(0,min(palettes.count-1,theme));renderer?.artPattern=pattern
        renderer?.art.collage.previewPlate=sky
        renderer?.art.collage.reset()
        let looks:[[String:String]]=[[:],["bottom":"straw_skirt","hat":"bow","top":"rose_body"],["bottom":"straw_skirt","hat":"nightcap","top":"pearl_body"],["hat":"moon_hat","top":"mint_body"],["hat":"beyond_crown","top":"pearl_body"]]
        artEquipped=looks[((variant%looks.count)+looks.count)%looks.count]
        artIdle=pose == "idle"
        simulation.state.distance=61.3;simulation.state.activeTicks=300
        if pose == "jump" {simulation.state.player.height=1.0}
        if pose == "slide" {simulation.state.player.slideTicks=30}
        simulation.state.chunks=[];simulation.state.hazards=[];simulation.streamChunks()
        if mirror {simulation.state.hazards=[.init(id:"design-mirror",asset:.mirror,encounter:.mirror,distance:72,lateral:0,radius:2.1,height:5)]}
        if contrast {
            simulation.state.safeUntilDistance=0
            simulation.state.hazards=[.init(id:"contrast-rabbit",asset:.rabbit,encounter:.dodge,distance:67,lateral:-1,radius:0.4,height:0.8),.init(id:"contrast-pig",asset:.pig,encounter:.dodge,distance:68,lateral:1,radius:0.4,height:0.8),.init(id:"contrast-nazar",asset:.nazar,encounter:.dodge,distance:72,lateral:0,radius:0.4,height:0.8),.init(id:"contrast-horse",asset:.horse,encounter:.slide,distance:79,lateral:0,radius:2,height:3),.init(id:"contrast-zebra",asset:.zebra,encounter:.slide,distance:89,lateral:0,radius:2,height:3)]
        }
        // Clear only this DEBUG preview's retained presentation, after the overrides.
        renderer?.lastRun=nil
        renderer?.render(run,equipped:artEquipped ?? [:],menu:artIdle)
    }
    func labCollage(index:Int,seed:UInt64?=nil) {
        obstacleReview=nil;renderer?.art.collage.previewVignette=nil;renderer?.art.collage.previewScale=nil;renderer?.art.collage.previewFraming=nil
        artEquipped=nil;artIdle=false;renderer?.artPattern=nil;renderer?.art.collage.previewPlate=nil
        artReview=true;renderer?.artPalette=seed == nil ? [0,2,4,6,1][((index%5)+5)%5]:nil
        collageSceneIndex=((index%5)+5)%5;collageMotion=false
        let seed=seed ?? DreamCollageComposition.proofSeeds[((index%5)+5)%5]
        simulation=GameSimulation(identity:.current(seed:seed),mode:.debug)
        simulation.state.distance=60;simulation.state.activeTicks=300;simulation.state.phase = .running
        simulation.state.safeUntilDistance=1060
        simulation.state.chunks.removeAll();simulation.state.hazards.removeAll()
        simulation.streamChunks();screen="gameplay";renderer?.render(run,equipped:profile.equipped)
    }
    func labArt(theme:Int,distance:Double=37.5,pose:String="run") {
        artEquipped=nil;artIdle=pose == "idle";renderer?.artPattern=nil;renderer?.art.collage.previewPlate=nil
        collageSceneIndex=nil;collageMotion=false
        artReview=true;renderer?.artPalette=max(0,min(palettes.count-1,theme))
        simulation=GameSimulation(identity:DreamIdentity.current(seed:42),mode:.debug)
        simulation.state.distance=distance.isFinite ? max(0,min(100_000,distance)) : 37.5
        simulation.state.activeTicks=180;simulation.state.phase = .running
        if pose == "slide" {simulation.state.player.slideTicks=20}
        if pose == "jump" {simulation.state.player.height=1.1}
        if pose == "white" {simulation.state.pigs=[CollectedPig(ordinal:1,hue:0),CollectedPig(ordinal:2,hue:1),CollectedPig(ordinal:3,hue:2)];simulation.state.endingElapsed=53;simulation.state.phase = .whiteEnding}
        simulation.streamChunks();screen="gameplay";renderer?.render(run,equipped:profile.equipped)
    }
    func labPaletteEvolution(to target:Int,elapsed:Double) {
        guard let renderer else{return}
        artReview=true;simulation.state.mode = .debug
        for _ in 0..<30 {renderer.render(run,equipped:profile.equipped)}
        renderer.artPalette=max(0,min(palettes.count-1,target))
        renderer.render(run,equipped:profile.equipped)
        let frames=Int(max(0,min(25,elapsed.isFinite ? elapsed : 0))*60)
        for _ in 0..<frames {simulation.state.activeTicks += 1;renderer.render(run,equipped:profile.equipped)}
    }
    func previewAsset() { renderer?.preview(AssetID(rawValue:labAsset)!,palette:labPalette,style:labStyle,lod:labLOD,colliders:labColliders) }
    func labWorld(_ code:String) {
        do {let identity=try DreamIdentity.parse(code);simulation=GameSimulation(identity:identity,mode:.debug);renderer?.render(run,equipped:profile.equipped)} catch {self.error=error.localizedDescription}
    }
    func labStep() {simulation.state.mode = .debug;simulation.state.distance += 24;simulation.streamChunks();renderer?.render(run,equipped:profile.equipped)}
    func labCommerce() {
        var isolated=Profile();isolated.credit(id:"purchase:mock",amount:500,source:"purchase");isolated.credit(id:"purchase:mock",amount:500,source:"purchase")
        let once=isolated.balance;isolated.revoke("mock");isolated.revoke("mock")
        notice="Developer memory-only ledger: duplicate delivery = \(once) once; duplicate refund = \(isolated.balance). Pending/cancelled/unverified grant zero. Production wallet untouched."
    }
    func labExport() {
        do {let url=FileManager.default.temporaryDirectory.appendingPathComponent("DreamAgain-diagnostic.json");let encoder=JSONEncoder();encoder.outputFormatting=[.prettyPrinted,.sortedKeys];try encoder.encode(run).write(to:url,options:.atomic);shareItems=[url];sharing=true} catch {self.error=error.localizedDescription}
    }
    func labEvent(_ event:String) {
        start(mode:.debug); simulation.state.phase = .running
        switch event {
        case "Lucky Dream": simulation.debugPig(third:true)
        case "Clover pig": simulation.debugPig(third:false)
        case "Ordinary pig": simulation.state.hazards.append(HazardDescription(id:"lab:ordinary",asset:.pig,encounter:.dodge,distance:30,lateral:0,radius:0.38,height:0.65))
        case "Three hours": simulation.debugTime(10790)
        case "Sparse": simulation.debugTime(11050)
        case "Beyond": simulation.debugTime(11500)
        case "Straw damage":
            simulation.state.player.missingLimbs=[.leftArm,.rightArm,.leftLeg]
            simulation.state.chunks[0].pickups.append(PickupDescription(id:"straw:lab",distance:15,lateral:0,height:0.45,kind:.straw))
        case "Straw burst":
            renderer?.render(run,equipped:profile.equipped)
            simulation.state.player.missingLimbs=StrawLimb.allCases;simulation.wake("unravelled")
        case "Waking": simulation.wake("developer preview")
        case "Void": simulation.state.mirrorCount=6; simulation.state.distance=432
        case "Mirror": simulation.state.distance=1770; simulation.state.chunks=[]; simulation.state.hazards=[]
        case "Drop": simulation.state.distance=870; simulation.state.chunks=[]; simulation.state.hazards=[]
        case "Rabbit","Nazar","Zebra","Ball":
            let id:AssetID=event == "Rabbit" ? .rabbit : event == "Nazar" ? .nazar : event == "Zebra" ? .zebra : .soccer
            simulation.state.hazards=[HazardDescription(id:"lab:hazard",asset:id,encounter:event == "Zebra" ? .slide : .dodge,distance:35,lateral:0,radius:0.5,height:event == "Zebra" ? 2.4 : 0.8)]
        default: break
        }
        simulation.streamChunks(); renderer?.render(run,equipped:profile.equipped); persist(); previousTime=0
    }
    #endif
}
import AVFAudio
