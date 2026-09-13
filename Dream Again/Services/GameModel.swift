import Foundation
import SwiftUI
import Combine
import UIKit

@MainActor final class GameModel:NSObject,ObservableObject {
    @Published var screen="home"
    @Published var simulation=GameSimulation(identity:DreamIdentity(seed:42))
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
    var store:ProfileStore?
    var commerce:BalloonStore?
    var input=InputFrame()
    var homeDream=GameSimulation(identity:DreamIdentity(seed:42),mode:.reviewDemo)
    var homeFrames=0
    var motion=MotionInput(), audio=DreamAudio()
    var link:CADisplayLink?
    var previousTime=0.0
    var clock=FixedStepClock()
    var provider:any RewardedContinueProvider = DisabledRewardProvider()
    var active:Bool { screen == "gameplay" }
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
            let directory=try FileManager.default.url(for:.applicationSupportDirectory,in:.userDomainMask,appropriateFor:nil,create:true).appendingPathComponent("DreamAgain",isDirectory:true)
            let store=try ProfileStore(url:directory.appendingPathComponent("profile-v1.json")); self.store=store; profile=store.profile; settings=profile.settings
            if store.recoveredBackup { error="A damaged save was preserved and the last good backup was recovered. Progress since that backup may be missing." }
            commerce=BalloonStore(store:store); renderer=DreamRenderer(palettes:palettes)
            renderer?.render(run,equipped:profile.equipped,menu:true)
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--ui-test") { settings.music=false; settings.effects=false; settings.touchSteering=true }
            #endif
        } catch { self.error=error.localizedDescription }
        link=CADisplayLink(target:self,selector:#selector(frame(_:))); link?.add(to:.main,forMode:.common)
        NotificationCenter.default.addObserver(self,selector:#selector(interrupted),name:AVAudioSession.interruptionNotification,object:nil)
    }
    @objc func interrupted() { pause() }
    func refresh() { if let store { profile=store.profile } }
    func transact(_ action:(inout Profile)throws->Void) {
        guard let store else { error="Storage is unavailable. Retry after resolving the saved profile error."; return }
        do { try store.transaction(action); refresh() } catch { self.error=error.localizedDescription; simulation.pause() }
    }
    func start(identity:DreamIdentity? = nil,mode:RunMode? = nil) {
        guard store != nil, renderer != nil else { error="The game resources or profile could not be loaded."; return }
        if let identity, !identity.supported { error=DreamError.unsupportedVersion.localizedDescription; return }
        let selectedMode=mode ?? (identity == nil ? (profile.achievements.contains("first_dream") ? .fresh : .tutorial) : .revisit)
        if selectedMode.earns,let suspended=profile.snapshot,![RunPhase.finished,.waking].contains(suspended.phase) {
            var abandoned=suspended;abandoned.phase = .finished;abandoned.cause="started another dream"
            transact {$0.settle(abandoned,finished:true,catalogue:achievements);$0.snapshot=nil}
            if error != nil {return}
        }
        simulation=GameSimulation(identity:identity ?? DreamIdentity(seed:UInt64.random(in:UInt64.min...UInt64.max)),mode:selectedMode,rules:rules)
        screen="gameplay"; input=InputFrame(); previousTime=0; clock.reset()
        renderer?.render(run,equipped:profile.equipped); persist()
    }
    func ready() {
        if !settings.touchSteering { motion.start(); motion.calibrate() }
        simulation.resume(); previousTime=0; clock.reset(); persist()
    }
    func pause() { guard active else { return }; simulation.pause(); motion.stop(); audio.stop(); previousTime=0; clock.reset(); persist() }
    func persist() {
        guard run.mode.earns else {return}
        let snapshot=run
        transact { $0.snapshot=snapshot; $0.settings=settings }
    }
    func resumeSaved() {
        guard let snapshot=profile.snapshot else { return }
        do {
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
    func finish() { renderer?.snapshot { [weak self] image in self?.renderer?.frozenFrame=image }; let result=run; if result.mode.earns {transact { $0.settle(result,finished:true,catalogue:achievements); $0.snapshot=result }}; audio.stop(); motion.stop() }
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
        do { let normalized=code.hasPrefix("dreamagain://dream/") ? String(code.dropFirst("dreamagain://dream/".count)) : code; start(identity:try DreamIdentity.parse(normalized),mode:.revisit) } catch { self.error=error.localizedDescription }
    }
    func importURL(_ url:URL) {
        if url.scheme == "dreamagain" { importCode(url.lastPathComponent); return }
        let access=url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }
        do { let values=try url.resourceValues(forKeys:[.fileSizeKey]); guard values.fileSize ?? 32769 <= 32768 else { throw DreamError.invalidCode }; start(identity:try DreamFile.read(Data(contentsOf:url)),mode:.revisit) } catch { self.error=error.localizedDescription }
    }
    func share() {
        let result=run
        let caption="Dream Again · \(result.mode.rawValue) · \(time(result.activeTicks)) · \(result.continueCount) continues\n\(result.identity.code)\nRules \(result.identity.rulesVersion) · \(result.pigs.count)/3 clover pigs"
        do {
            let url=FileManager.default.temporaryDirectory.appendingPathComponent("DreamAgain.dream")
            try JSONEncoder().encode(DreamFile(result.identity)).write(to:url,options:.atomic)
            let card=ShareCard(run:result)
            let render=ImageRenderer(content:card); render.scale=2
            shareItems=[caption,url]; if let snapshot=renderer?.frozenFrame {shareItems.append(snapshot)}; if let image=render.uiImage { shareItems.append(image) }; sharing=true
        } catch { self.error=error.localizedDescription }
    }
    func buy(_ item:CosmeticDefinition) { transact { try $0.buy(item) } }
    func equip(_ item:CosmeticDefinition) { guard profile.owned.contains(item.id) else { return }; transact { $0.equipped[item.slot]=item.id }; renderer?.dress(profile.equipped) }
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
                simulation=candidate;screen="gameplay";previousTime=0;return
            }
            #endif
            transact { _=$0.grantContinue(eventID:event,run:candidate.state) }
            transact { _=$0.consumeContinue(&candidate) }
            if profile.snapshot?.continueCount == 1 { simulation=candidate; screen="gameplay"; previousTime=0 }
        case .dismissed: notice="No reward was earned. Clover odds are unchanged."
        case .unavailable: notice="Rewarded continue is unavailable. Start another dream for free."
        case .failed(let message): notice=message
        }
    }
    @objc func frame(_ display:CADisplayLink) {
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
        let now=display.timestamp
        if previousTime == 0 { previousTime=now; return }
        let delta=now-previousTime; previousTime=now
        if [.ready,.paused,.finished].contains(run.phase) { return }
        if [.waking,.luckyTransition,.whiteEnding,.resuming].contains(run.phase) {
            let events=simulation.presentationStep(delta)
            renderer?.render(run,equipped:profile.equipped,lowPower:settings.lowPower)
            if events.contains(.ending) { finish(); screen="results" }
            return
        }
        if delta > 0.25 { notice="The dream paused after an interruption."; pause(); return }
        guard let steps=clock.consume(delta) else {notice="The dream paused to keep the next obstacle fair.";pause();return}
        if !settings.touchSteering {
            guard let steering=motion.sample(settings:settings,now:now) else { notice="Motion is unavailable. Choose touch steering or recalibrate."; pause(); return }; input.steering=steering
        }
        for _ in 0..<steps {
            let events=simulation.step(input); input.jump=false; input.slide=false
            if events.contains(.balloon) { audio.feedback(.balloon,settings:settings) }
            if events.contains(.stumble) { audio.feedback(.stumble,settings:settings) }
            if events.contains(.clover) { audio.feedback(.clover,settings:settings) }
            if events.contains(.waking) { finish() }
            if run.mode.earns && (events.contains(.pigCommitted) || events.contains(.clover) || run.activeTicks%900 == 0) {
                let snapshot=run
                transact { $0.snapshot=snapshot; $0.settle(snapshot,finished:false,catalogue:achievements) }
            }
            if [.waking,.luckyTransition].contains(run.phase) { break }
        }
        renderer?.render(run,equipped:profile.equipped,lowPower:settings.lowPower || ProcessInfo.processInfo.thermalState.rawValue >= ProcessInfo.ThermalState.serious.rawValue)
        audio.update(active:true,palette:run.paletteIndex,settings:settings)
    }
    #if DEBUG
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
