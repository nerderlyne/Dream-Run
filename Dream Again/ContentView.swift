import SwiftUI
import StoreKit
import UniformTypeIdentifiers

struct ContentView:View {
    @StateObject private var game=GameModel()
    @Environment(\.scenePhase) var scenePhase
    @State private var code=""
    @State private var showImport=false
    @State private var deleteBookmark:UUID?
    @State private var renameID:UUID?
    @State private var renameText=""
    @State private var continueWarning=false
    @State private var swipeStarted:Date?
    var body:some View {
        ZStack {
            if let renderer=game.renderer { DreamSceneView(renderer:renderer).ignoresSafeArea() }
            if game.screen != "gameplay" && game.screen != "lab" && game.screen != "wardrobe" { Color.black.opacity(game.screen == "results" && game.run.pigs.count == 3 ? 0 : game.screen == "home" || game.screen == "wardrobe" ? 0.25 : 0.7).ignoresSafeArea() }
            switch game.screen {
            case "home": home
            case "gameplay": gameplay
            case "results": results
            case "wardrobe": wardrobe
            case "saved": saved
            case "settings": settings
            case "achievements": achievements
            case "import": importView
            case "store": if let commerce=game.commerce { StoreView(commerce:commerce,onBack:{game.refresh();game.screen="wardrobe"}) }
            #if DEBUG
            case "lab": lab
            #endif
            default: home
            }
        }
        .tint(Color(red:0.83,green:0.92,blue:0.89))
        .preferredColorScheme(.dark)
        .alert("Dream Again",isPresented:Binding(get:{game.error != nil},set:{if !$0 {game.error=nil}})) { Button("OK"){game.error=nil} } message:{Text(game.error ?? "")}
        .alert("Delete this saved dream?",isPresented:Binding(get:{deleteBookmark != nil},set:{if !$0 {deleteBookmark=nil}})) {
            Button("Delete",role:.destructive){if let id=deleteBookmark {game.transact{$0.bookmarks.removeAll{$0.id == id}}};deleteBookmark=nil}
            Button("Cancel",role:.cancel){deleteBookmark=nil}
        } message:{Text("Your wallet and wardrobe stay with you.")}
        .alert("Name this dream",isPresented:Binding(get:{renameID != nil},set:{if !$0 {renameID=nil}})) {
            TextField("Dream name",text:$renameText)
            Button("Save"){if let id=renameID {game.transact{p in if let i=p.bookmarks.firstIndex(where:{$0.id == id}) {p.bookmarks[i].title=String(renameText.prefix(100))}}};renameID=nil}
            Button("Cancel",role:.cancel){renameID=nil}
        }
        .alert("Continue this dream — watch an ad",isPresented:$continueWarning) {
            Button("Continue"){Task{await game.continueDream()}}
            Button("Cancel",role:.cancel){}
        } message:{Text("This run will be marked continued. Future clover chances are halved: 1/3 → 1/6 when a pig appears.")}
        .sheet(isPresented:$game.sharing){ShareSheet(items:game.shareItems)}
        .fileImporter(isPresented:$showImport,allowedContentTypes:[.json,.data],allowsMultipleSelection:false){result in do { if let url=try result.get().first {game.importURL(url)} } catch {game.error=error.localizedDescription}}
        .onOpenURL{game.importURL($0)}
        .onChange(of:game.screen){_,screen in if screen == "wardrobe" {game.renderer?.previewAvatar(equipped:game.profile.equipped,wardrobe:true)} else if screen == "home" {game.renderer?.render(game.run,equipped:game.profile.equipped)} }
        .onChange(of:scenePhase){_,phase in if phase != .active {game.pause()} }
    }
    func button(_ title:String,_ action:@escaping ()->Void)->some View {
        Button(action:action) {
            Text(title).font(.system(size:17,weight:.medium,design:.rounded))
                .frame(maxWidth:.infinity).padding(.vertical,14)
                .background(.white.opacity(0.08),in:RoundedRectangle(cornerRadius:22))
                .overlay(RoundedRectangle(cornerRadius:22).strokeBorder(.white.opacity(0.15)).allowsHitTesting(false))
                .contentShape(RoundedRectangle(cornerRadius:22))
        }.buttonStyle(.plain).accessibilityIdentifier(title)
    }
    func menu<Content:View>(_ title:String,@ViewBuilder content:()->Content)->some View {
        VStack(spacing:12){HStack{Button("‹ home"){game.screen="home"};Spacer();Text(title).font(.title2);Spacer()}.padding(.bottom,8)
            ScrollView{VStack(spacing:14){content()}.frame(maxWidth:600)}
        }.padding(24).frame(maxWidth:680)
    }
    var home:some View {
        VStack(spacing:14){Spacer()
            Text("DREAM AGAIN").font(.system(size:13,weight:.medium,design:.rounded)).tracking(6)
            Text("somewhere\nelse.").font(.system(size:58,weight:.light,design:.serif)).multilineTextAlignment(.center)
            Text("a dream you can return to").font(.subheadline).foregroundStyle(.white.opacity(0.75))
            Spacer()
            Text("\(game.profile.balance) balloons").font(.subheadline.monospacedDigit())
            button("dream"){game.start()}.buttonStyle(.borderedProminent)
            if game.profile.snapshot != nil {button("resume suspended dream"){game.resumeSaved()}}
            HStack{button("wardrobe"){game.screen="wardrobe"};button("saved dreams"){game.screen="saved"}}
            HStack{Button("achievements"){game.screen="achievements"};Spacer();Button("settings"){game.screen="settings"}}
            #if DEBUG
            Button("Lab · developer previews"){game.screen="lab";game.previewAsset()}.font(.caption).padding(.top,8)
            #endif
        }.padding(30).frame(maxWidth:480)
    }
    var gameplay:some View {
        ZStack(alignment:.bottom) {
            if game.run.phase == .mirrorCrossing { Color.black.opacity(0.95).ignoresSafeArea().allowsHitTesting(false) }
            if game.run.phase == .waking { GeometryReader{g in Color.black.frame(height:g.size.height*min(1,game.run.endingElapsed/1.25)).frame(maxHeight:.infinity,alignment:.bottom)}.ignoresSafeArea() }
            if game.run.instabilityUntil > game.run.activeTicks && game.run.phase == .running { LinearGradient(colors:[.clear,.black.opacity(0.45)],startPoint:.center,endPoint:.bottom).ignoresSafeArea().allowsHitTesting(false) }

            Color.clear.contentShape(Rectangle()).gesture(DragGesture(minimumDistance:8)
                .onChanged { value in
                    guard [.running,.safeDrop,.mirrorCrossing].contains(game.run.phase) else {return}
                    if swipeStarted == nil {swipeStarted=value.time}
                    if game.simulatorDragInput {
                        let dx=value.translation.width,dy=value.translation.height
                        game.input.steering=abs(dx)>abs(dy) ? max(-1,min(1,Double(dx)/80)) : 0
                    }
                }
                .onEnded { value in
                    defer {swipeStarted=nil;if game.simulatorDragInput {game.input.steering=0}}
                    guard [.running,.safeDrop,.mirrorCrossing].contains(game.run.phase) else {return}
                    let dy=value.translation.height,dx=value.translation.width
                    guard abs(dy)>=34,abs(dy)>abs(dx)*1.4,value.time.timeIntervalSince(swipeStarted ?? value.time)<=0.45 else {return}
                    if dy < 0 {game.input.jump=true} else {game.input.slide=true}
                })
            VStack {
                HStack(spacing:20) {
                    Text(game.time(game.run.activeTicks)).monospacedDigit().tracking(2)
                    Spacer()
                    BalloonCounter(total:game.run.balloons,tick:game.run.activeTicks,runID:game.run.id,reducedMotion:game.settings.reducedMotion)
                    Button {game.pause()} label:{Image(systemName:"pause").frame(width:44,height:44)}.accessibilityLabel("pause").accessibilityIdentifier("pause")
                }.font(.system(size:14,weight:.medium)).padding(.leading,24).padding(.trailing,12).foregroundStyle(game.run.pigs.count == 3 ? Color.black.opacity(0.65) : .white).shadow(color:.black.opacity(0.5),radius:5,y:1)
                if game.run.mode != .fresh {Text(game.run.mode == .debug ? "PREVIEW · NO REWARDS" : game.run.mode.rawValue.uppercased()).font(.system(size:9,weight:.medium)).tracking(2).foregroundStyle(game.run.pigs.count == 3 ? Color.black.opacity(0.5) : .white.opacity(0.7)).allowsHitTesting(false)}
                if game.run.stumbleWeight > 0 && game.run.phase == .running {
                    Text("stumbled").font(.callout.weight(.semibold)).padding(.horizontal,14).padding(.vertical,8).background(.black.opacity(0.5),in:Capsule()).allowsHitTesting(false)
                }
                if game.run.mode == .tutorial {Text(tutorialPrompt).font(.callout).padding().background(.ultraThinMaterial,in:Capsule())}
                Spacer()
                if [.luckyTransition,.whiteEnding,.waking].contains(game.run.phase) {Button("skip presentation"){let events=game.simulation.presentationStep(0,skip:true);if events.contains(.ending){game.finish();game.screen="results"}}.padding().disabled(game.run.endingElapsed < (game.run.pigs.count == 3 ? 5 : 0.35)).foregroundStyle(game.run.pigs.count == 3 ? Color.black.opacity(0.65) : .white)}
                #if DEBUG
                if game.artReview,let index=game.collageSceneIndex {
                    HStack {
                        Button("Lab"){game.artReview=false;game.collageMotion=false;game.screen="lab";game.previewAsset()}
                        Button(game.collageMotion ? "freeze":"run"){game.collageMotion.toggle()}
                        if let obstacle=game.obstacleReview {Button("again"){game.labObstacle(obstacle)}}
                        else {Button("dream \(index+1)/5 →"){game.labCollage(index:index+1)}}
                    }.font(.caption).padding(12).background(.regularMaterial,in:Capsule())
                }
                #endif
            }
            if [.ready,.paused].contains(game.run.phase) {
                VStack(spacing:12){Text(game.run.phase == .ready ? "a little tilt.\na leap. a dream." : "paused").font(.largeTitle).multilineTextAlignment(.center)
                    Text(game.simulatorDragInput ? "Drag left or right to steer. Swipe up to jump, down to slide." : "Tilt left or right to steer. Swipe up to jump, down to slide. Hold comfortably, then tap ready to calibrate.").font(.callout).multilineTextAlignment(.center)
                    if !game.notice.isEmpty {Text(game.notice).font(.caption)}
                    button("ready"){game.ready()}
                    button("save & leave"){game.leave()}
                    button("end this dream"){game.endRun()}
                }.padding(28).background(.regularMaterial,in:RoundedRectangle(cornerRadius:28)).padding(25).frame(maxWidth:450).frame(maxHeight:.infinity)
            }
            if game.run.phase == .resuming {Text("breathe…").font(.largeTitle).frame(maxHeight:.infinity)}
        }
    }
    var tutorialPrompt:String {
        switch game.run.distance {case ..<80:"steer gently toward the balloons";case ..<155:"swipe up to jump across the gap";case ..<255:"swipe down to slide beneath the zebra";case ..<345:"cute, but keep clear of the rabbit";default:"follow the dream. you’re ready."}
    }
    var results:some View {
        VStack(spacing:14){Spacer();Text(game.run.pigs.count == 3 ? "Lucky Dream" : "you woke up.").font(.system(size:42,weight:.light,design:.serif));if game.run.pigs.count == 3 {Text("You were very lucky.")}
            Text(game.time(game.run.activeTicks)).font(.title.monospacedDigit())
            Text("\(Int(game.run.distance)) metres · \(game.run.balloons) balloons · \(game.run.pigs.count)/3 pigs").font(.subheadline)
            Text("\(game.run.mode.rawValue) · \(game.run.continueCount) continues · rules \(game.run.identity.rulesVersion)").font(.caption)
            Text("best unbroken · \(game.time(game.profile.records["unbroken",default:0]))").font(.caption)
            Text(game.run.identity.code).font(.caption2.monospaced()).textSelection(.enabled)
            if !game.notice.isEmpty {Text(game.notice).font(.caption).multilineTextAlignment(.center)}
            Spacer();button("dream again"){game.start(mode:.fresh)}
            HStack{button("save dream"){game.saveDream()};button("share"){game.share()}}
            button("revisit this dream"){game.start(identity:game.run.identity,mode:.revisit)}
            if game.provider.available && game.run.continueCount == 0 && game.run.pigs.count < 3 {button(game.provider.label){continueWarning=true}}
            button("home"){game.screen="home"}
        }.padding(28).frame(maxWidth:560).foregroundStyle(game.run.pigs.count == 3 ? Color.black : Color.white)
    }
    var wardrobe:some View {
        menu("wardrobe") {
            Color.clear.frame(height:220).allowsHitTesting(false)
            Text("your character").font(.headline)
            HStack {
                Button(game.profile.equipped["character"] == "girl" ? "Girl · wearing dress" : "Girl · dress") {game.chooseCharacter("girl")}
                Button(game.profile.equipped["character"] != "girl" ? "Doll · wearing ribbon" : "Doll · ribbon") {game.chooseCharacter("runner")}
            }.buttonStyle(.bordered)
            Text("Both looks are free. Hats and colours work with either.").font(.caption)
            Button("No hat") {if let item=game.catalogue.first(where:{$0.id == "bare_head"}) {game.equip(item)}}
            Text("\(game.profile.balance) balloons").font(.title3)
            button("balloon packs"){game.screen="store"}
            ForEach(game.catalogue){item in
                HStack{VStack(alignment:.leading,spacing:4){Text(item.name);Text(game.profile.owned.contains(item.id) ? "owned · \(item.slot)" : item.balloon_price.map{"\($0) balloons"} ?? "achievement only").font(.caption).foregroundStyle(.secondary)};Spacer()
                    if game.profile.owned.contains(item.id) {Button(game.profile.equipped[item.slot] == item.id ? "equipped" : "equip"){game.equip(item)}}
                    else if item.balloon_price != nil {Button("buy"){game.buy(item)}}
                    else {Image(systemName:"lock")}
                }.padding().background(.white.opacity(0.07),in:RoundedRectangle(cornerRadius:14))
            }
        }
    }
    var saved:some View {
        menu("saved dreams") {
            button("import a dream"){game.screen="import"}
            if game.profile.bookmarks.isEmpty {Text("Nothing saved yet. Remember a dream from its result screen.").padding()}
            ForEach(game.profile.bookmarks.sorted{a,b in a.favourite != b.favourite ? a.favourite : a.created>b.created}){bookmark in
                VStack(alignment:.leading,spacing:10){
                    if let name=bookmark.thumbnail,let directory=game.store?.url.deletingLastPathComponent(),let image=UIImage(contentsOfFile:directory.appendingPathComponent("thumbnails").appendingPathComponent(name).path) {Image(uiImage:image).resizable().scaledToFill().frame(height:140).clipped().clipShape(RoundedRectangle(cornerRadius:12))}
                    Text(bookmark.title).font(.headline);Text(bookmark.dreamID).font(.caption2.monospaced()).textSelection(.enabled)
                    Text(game.time(bookmark.ticks)).font(.caption)
                    HStack{Button("revisit"){game.importCode(bookmark.dreamID)};Spacer();Button(bookmark.favourite ? "★" : "☆"){game.transact{p in if let i=p.bookmarks.firstIndex(where:{$0.id==bookmark.id}){p.bookmarks[i].favourite.toggle()}}}.accessibilityLabel("Favourite dream")
                        Button("rename"){renameText=bookmark.title;renameID=bookmark.id}
                        Button("delete",role:.destructive){deleteBookmark=bookmark.id}}
                    ShareLink(item:bookmark.dreamID){Label("share code",systemImage:"square.and.arrow.up")}
                }.padding().background(.white.opacity(0.07),in:RoundedRectangle(cornerRadius:14))
            }
        }
    }
    var importView:some View {
        menu("import dream") {
            Text("A shared dream begins again in Revisit mode. It cannot resume somebody else’s attempt.")
            TextField("DR1-G1-R1-C1-…",text:$code,axis:.vertical).textInputAutocapitalization(.characters).autocorrectionDisabled().textFieldStyle(.roundedBorder).accessibilityIdentifier("dream code")
            button("revisit code"){game.importCode(code)}
            button("open .dream file"){showImport=true}
        }
    }
    var achievements:some View {
        menu("achievements") {
            Text("Local records · no account required").font(.caption)
            ForEach(game.achievements){a in let owned=game.profile.achievements.contains(a.id)
                HStack{Image(systemName:owned ? "sparkle" : "circle");VStack(alignment:.leading){Text(a.hidden_before_unlock && !owned ? "???" : a.name);Text(a.hidden_before_unlock && !owned ? "Something to discover." : a.description).font(.caption).foregroundStyle(.secondary)};Spacer()}.padding()
            }
        }
    }
    var settings:some View {
        menu("settings") {
            VStack(alignment:.leading){Text("Tilt sensitivity");Slider(value:$game.settings.sensitivity,in:0.5...1.5);Text("Dead zone · \(game.settings.deadzone,specifier:"%.1f")°");Slider(value:$game.settings.deadzone,in:0.5...4)}
            Toggle("Reduced motion",isOn:$game.settings.reducedMotion);Toggle("Reduced flashes",isOn:$game.settings.reducedFlashes)
            Toggle("Music",isOn:$game.settings.music);Toggle("Effects",isOn:$game.settings.effects);Toggle("Haptics",isOn:$game.settings.haptics);Toggle("Lower visual detail",isOn:$game.settings.lowPower)
            button("save settings"){game.saveSettings();game.notice="Settings saved."}
            button("replay introduction"){game.start(mode:.tutorial)}
            Text("Pause and recalibrate at any time. Sound respects silent mode. Wallet and dreams are stored on this device; consumable balance is not automatically restored across reinstalls.").font(.footnote).foregroundStyle(.secondary)
            Text("Purchases: local testing in Debug; disabled in Release. Ads, Game Center, cloud and Universal Links are not configured. Privacy/support URLs must be supplied by the owner before publishing.").font(.footnote).foregroundStyle(.secondary)
        }
    }
    #if DEBUG
    var lab:some View {
        VStack{HStack{Button("home"){game.screen="home";game.renderer?.render(game.run,equipped:game.profile.equipped)};Spacer();Text("Lab · no rewards")}.padding()
            Spacer()
            VStack(spacing:8){Text("\(game.labAsset)/42 · \(game.assets.first(where:{$0.number == game.labAsset})?.name ?? "")").font(.headline)
                Stepper("Asset",value:$game.labAsset,in:1...42).onChange(of:game.labAsset){_,_ in game.previewAsset()}
                HStack{Button("palette"){game.labPalette=(game.labPalette+1)%12;game.previewAsset()};Button("material"){game.labStyle=(game.labStyle+1)%8;game.previewAsset()};Button("LOD \(game.labLOD)"){game.labLOD=(game.labLOD+1)%3;game.previewAsset()}}
                HStack {Button("cloud slice"){game.labArt(theme:0)};Button("aqua slice"){game.labArt(theme:1)};Button("void slice"){game.labArt(theme:5)}}.font(.caption)
                HStack {Text("Collage kit");ForEach(0..<5,id:\.self){i in Button("\(i+1)"){game.labCollage(index:i)}}}.font(.caption)
                HStack {Text("Straw doll");ForEach(0..<5,id:\.self){i in Button("\(i+1)"){game.labDesign(theme:i,variant:i,sky:DreamCollageKit.skyIDs[i])}}}.font(.caption)
                HStack {ForEach(["idle","run","jump","slide"],id:\.self){pose in Button(pose){game.labDesign(theme:0,pose:pose)}}}.font(.caption)
                ScrollView(.horizontal){HStack{ForEach(DreamVignette.allCases,id:\.self){scene in Button(scene.title){game.labVignette(scene)}}}}.font(.caption)
                ScrollView(.horizontal){HStack{ForEach(DreamObstacle.allCases,id:\.self){kind in Button(kind.title){game.labObstacle(kind)}}}}.font(.caption)
                Toggle("Show role bounds",isOn:$game.labColliders).onChange(of:game.labColliders){_,_ in game.previewAsset()}
                HStack{TextField("Dream ID for world preview",text:$code).font(.caption).textFieldStyle(.roundedBorder);Button("preview"){game.labWorld(code)};Button("+24m"){game.labStep()}}
                ScrollView(.horizontal){HStack{ForEach(["Rabbit","Nazar","Zebra","Ball","Mirror","Drop","Ordinary pig","Clover pig","Lucky Dream","Three hours","Sparse","Beyond","Void","Waking"],id:\.self){event in Button(event){game.labEvent(event)}.buttonStyle(.bordered)}}}
                HStack{Button("test reward"){game.labEvent("Waking");game.provider=MockRewardProvider(outcome:.earned("debug:\(UUID().uuidString)"))};Button("dismissed ad"){game.provider=MockRewardProvider(outcome:.dismissed);game.labEvent("Waking")};Button("failed ad"){game.provider=MockRewardProvider(outcome:.failed("Developer test failure"));game.labEvent("Waking")}}
                HStack{Button("ledger scenarios"){game.labCommerce()};Button("export diagnostics"){game.labExport()}}
                if !game.notice.isEmpty {Text(game.notice).font(.caption2)}
                Text("\(game.run.identity.code)\ntick \(game.run.activeTicks) · chunks \(game.run.chunks.count)/16 · entities \(game.renderer?.renderEntities ?? 0)\ngeometry cache \(game.renderer?.factory.cache.count ?? 0) · local preview only").font(.caption2.monospaced())
            }.padding().background(.regularMaterial,in:RoundedRectangle(cornerRadius:22))
        }.padding()
    }
    #endif
}
struct StoreView:View {
    @ObservedObject var commerce:BalloonStore
    var onBack:()->Void
    var body:some View {VStack(spacing:22){Button("‹ wardrobe",action:onBack);Text("balloons").font(.largeTitle);Text(commerce.status).multilineTextAlignment(.center);ForEach(commerce.products){p in Button("\(BalloonStore.quantities[p.id] ?? 0) balloons · \(p.displayPrice)"){Task{await commerce.purchase(p)}}.buttonStyle(.borderedProminent)};Button("reconcile purchases"){Task{await commerce.reconcile()}};Text("Currency buys cosmetics only. No luck, clovers, or skill advantages.").font(.footnote)}.padding(30).task{await commerce.load()}}
}
struct ShareSheet:UIViewControllerRepresentable {
    var items:[Any]
    func makeUIViewController(context:Context)->UIActivityViewController {UIActivityViewController(activityItems:items,applicationActivities:nil)}
    func updateUIViewController(_ controller:UIActivityViewController,context:Context){}
}
struct ShareCard:View {
    let run:RunState
    var body:some View {
        VStack(spacing:24){Text("D R E A M   A G A I N").font(.caption);Text(run.pigs.count == 3 ? "Lucky Dream" : "you woke up.").font(.system(size:40,design:.serif));Text("\(Int(run.seconds/60)) minutes · \(run.pigs.count)/3 clover pigs");Text("\(run.mode.rawValue) · \(run.continueCount) continues · rules \(run.identity.rulesVersion)").font(.caption);Text(run.identity.code).font(.system(size:12,design:.monospaced));Text("A seed remembers a place, not a performance.").font(.caption)}.padding(36).frame(width:420,height:420).foregroundStyle(Color(red:0.25,green:0.21,blue:0.3)).background(Color(red:0.92,green:0.88,blue:0.91))
    }
}
