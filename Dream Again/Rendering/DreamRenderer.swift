import SwiftUI
import RealityKit
import UIKit
import simd

@MainActor final class DreamRenderer {
    let view: ARView
    let anchor=AnchorEntity(world:.zero)
    let world=Entity(), runner=Entity(), camera=PerspectiveCamera(), headAttachment=Entity()
    let distantPath=DistantPathRenderer()
    let art=DreamArtDirection()
    let evolution=PaletteEvolution()
    let wardrobeLight=PointLight()
    var chunks: [Int:Entity]=[:], hazards: [String:Entity]=[:], pickups: [String:Entity]=[:]
    var legs:[Entity]=[], arms:[Entity]=[], knees:[Entity]=[], elbows:[Entity]=[]
    var factory: PrefabFactory
    var authoredRunner:AuthoredDreamRunner?
    private(set) var authoredArtError:String?
    var artPalette:Int?
    var palette = -1, base = -1.0, lastRun:UUID?, outfit="", lastVisual:VisualPhase = .ordinary
    private var builtCharacter:Bool?
    private var equippedCache:[String:String]?
    var gallery:Entity?
    var renderEntities = 0
    var frozenFrame: UIImage?
    var originalMaterials: [ObjectIdentifier:[PhysicallyBasedMaterial]] = [:]
    init(palettes:[PaletteDefinition]) {
        factory=PrefabFactory(palettes:palettes)
        view=ARView(frame:.zero,cameraMode:.nonAR,automaticallyConfigureSession:false)
        view.renderOptions=[.disableMotionBlur,.disableDepthOfField,.disableCameraGrain]
        view.scene.addAnchor(anchor); anchor.addChild(world); anchor.addChild(runner); anchor.addChild(camera);anchor.addChild(art.skyDome)
        camera.camera.fieldOfViewInDegrees=62
        camera.camera.far=8000
        let light=DirectionalLight(); light.light.intensity=4200; light.light.color=UIColor(hex:"#FFF0E4"); light.look(at:[0,0,0],from:[-6,10,8],relativeTo:nil); light.shadow = .init();anchor.addChild(light)
        let fill=PointLight(); fill.light.intensity=750; fill.light.attenuationRadius=80; fill.position=[4,9,8]; anchor.addChild(fill)
        wardrobeLight.light.intensity=1600;wardrobeLight.light.attenuationRadius=12;wardrobeLight.position=[-1,2.5,-3];wardrobeLight.isEnabled=false;anchor.addChild(wardrobeLight)
        buildAvatar()
        if let url=Bundle.main.url(forResource:"DreamRunner",withExtension:"usdz") {
            Task { [weak self] in
                do {
                    let art=try await AuthoredDreamRunner.load(url)
                    guard let self else{return}
                    for child in self.runner.children where child !== self.headAttachment {child.isEnabled=false}
                    self.headAttachment.removeFromParent();self.headAttachment.position = .zero
                    art.hatSocket.addChild(self.headAttachment);self.runner.addChild(art.entity);self.authoredRunner=art
                } catch {self?.authoredArtError=String(describing:error)}
            }
        }
    }
    func piece(_ center:SIMD3<Float>,_ scale:SIMD3<Float>,color:UIColor) -> Entity {
        var g=Geometry(); g.ellipsoid(center,scale,segments:40,rings:24)
        let entity=(try? ModelEntity(mesh:g.resource(),materials:[factory.material(color,style:0)])) ?? ModelEntity()
        if color == UIColor(hex:"#A6BAC0") {entity.name="avatar-body"}; return entity
    }
    func buildAvatar(feminine:Bool = false) {
        builtCharacter=feminine
        legs.removeAll();knees.removeAll();arms.removeAll();elbows.removeAll()
        runner.children.removeAll()
        // Tailored, long-legged stand-in. Replaceable named articulation, not final character art.
        let skin=UIColor(hex:"#DCD1C1"),suit=UIColor(hex:"#A6BAC0"),hair=UIColor(hex:"#48464E")
        func garment(_ profile:[SIMD4<Float>],color:UIColor)->Entity {
            var g=Geometry();g.loft(profile)
            let e=(try? ModelEntity(mesh:g.resource(),materials:[factory.material(color,style:3)])) ?? ModelEntity()
            if color == suit {e.name="avatar-body"};return e
        }
        let torso:[SIMD4<Float>]=feminine ? [[0.95,0.17,0.11,0],[1.05,0.155,0.10,0],[1.18,0.17,0.115,0],[1.37,0.235,0.125,0],[1.43,0.195,0.1,0],[1.47,0.085,0.065,0]] : [[0.98,0.177,0.12,0],[1.05,0.175,0.12,0],[1.18,0.18,0.12,0],[1.37,0.235,0.125,0],[1.43,0.195,0.1,0],[1.47,0.085,0.065,0]]
        let bodice=garment(torso,color:suit)
        if !feminine {runner.addChild(garment([[0.84,0.16,0.09,0],[0.94,0.183,0.115,0],[1.005,0.17,0.11,0]],color:UIColor(hex:"#4D505D")))}
        bodice.scale.x=feminine ? 0.88 : 1
        runner.addChild(bodice)
        runner.addChild(piece([0,1.49,0],[0.064,0.085,0.065],color:skin))
        runner.addChild(piece([0,1.67,-0.008],[0.132,0.168,0.123],color:skin))
        for x:Float in [-0.046,0.046] {runner.addChild(piece([x,1.69,-0.123],[0.009,0.012,0.006],color:hair))}
        runner.addChild(piece([0,1.66,-0.131],[0.021,0.025,0.022],color:skin))
        // Hair follows the skull; no rear slab or brim that reads as a baseball cap.
        let hairCrown=piece([0,1.745,0.014],[0.139,0.104,0.123],color:hair)
        hairCrown.name="hair-crown";runner.addChild(hairCrown)
        for sign:Float in [-1,1] {
            runner.addChild(piece([sign*0.117,1.66,0.025],[0.025,0.09,0.085],color:hair))
        }
        if feminine {
            let tail=piece([0,1.48,0.14],[0.092,0.225,0.075],color:hair)
            tail.name="ponytail";runner.addChild(tail)
            runner.addChild(piece([0,1.68,0.144],[0.08,0.065,0.05],color:hair))
            var skirt=Geometry()
            skirt.loft([[0.62,0.31,0.42,0.015],[0.67,0.315,0.40,0.012],[0.82,0.265,0.32,0],[0.98,0.19,0.135,0],[1.11,0.138,0.102,0]],segments:64)
            if let mesh=try? skirt.resource() {let e=ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:"#C8A7BC"),style:3)]);e.name="avatar-body";runner.addChild(e)}
        }
        // Narrow waist sash, not a business-suit centre seam.
        let sash=garment([[1.055,0.156,0.106,0],[1.095,0.151,0.104,0]],color:UIColor(hex:"#E7D9CB"))
        sash.scale.x=0.9;if feminine {runner.addChild(sash)}
        for sign:Float in [-1,1] {
            let leg=Entity(),knee=Entity();leg.name=sign < 0 ? "hip.L" : "hip.R";leg.position=[sign*0.105,0.94,0]
            leg.addChild(garment([[-0.47,0.064,0.064,0],[-0.38,0.073,0.079,0],[-0.15,0.085,0.085,0],[0,0.085,0.092,0]],color:feminine ? skin : UIColor(hex:"#4D505D")))
            knee.addChild(piece([0,0,0],[0.064,0.064,0.064],color:feminine ? skin : UIColor(hex:"#4D505D")))
            knee.name=sign < 0 ? "knee.L" : "knee.R";knee.position=[0,-0.46,0]
            knee.addChild(garment([[-0.39,0.045,0.055,0],[-0.25,0.06,0.067,0],[-0.1,0.068,0.071,0],[0.025,0.065,0.065,0]],color:feminine ? skin : UIColor(hex:"#4D505D")))
            knee.addChild(piece([0,-0.405,-0.055],[0.07,0.07,0.14],color:hair))
            leg.addChild(knee);runner.addChild(leg);legs.append(leg);knees.append(knee)
            let arm=Entity(),elbow=Entity();arm.name=sign < 0 ? "shoulder.L" : "shoulder.R";arm.position=[sign*0.228,1.38,0]
            arm.addChild(garment([[-0.285,0.047,0.05,0],[-0.16,0.058,0.061,0],[0,0.066,0.071,0]],color:suit))
            arm.addChild(piece([0,-0.01,0],[0.066,0.065,0.07],color:suit))
            elbow.addChild(piece([0,0,0],[0.048,0.048,0.048],color:skin))
            elbow.name=sign < 0 ? "elbow.L" : "elbow.R";elbow.position=[0,-0.275,0]
            elbow.addChild(garment([[-0.235,0.032,0.036,0],[-0.13,0.045,0.048,0],[0.018,0.05,0.05,0]],color:skin))
            elbow.addChild(piece([0,-0.275,0],[0.038,0.064,0.03],color:skin))
            arm.addChild(elbow);runner.addChild(arm);arms.append(arm);elbows.append(elbow)
        }
        headAttachment.name="hat.socket";headAttachment.position=[0,1.73,0];runner.addChild(headAttachment)
    }
    func dress(_ equipped:[String:String]) {
        guard equipped != equippedCache else {return};equippedCache=equipped
        let feminine=equipped["character"] == "girl"
        if authoredRunner == nil && builtCharacter != feminine {buildAvatar(feminine:feminine)}
        runner.findEntity(named:"hair-crown")?.isEnabled=true
        headAttachment.children.removeAll()
        runner.children.filter{$0.name == "equipped-trail"}.forEach{$0.removeFromParent()}
        let colors=["pearl_body":"#E9E6E2","rose_body":"#CBA6B7","mint_body":"#ACCFBE"]
        let bodyColor=UIColor(hex:colors[equipped["body_color"] ?? ""] ?? (feminine ? "#C8A7BC" : "#B5C8C3"))
        func tintBody(_ e:Entity) {if let model=e as? ModelEntity,e.name == "avatar-body" {model.model?.materials=[factory.material(bodyColor,style:3)]};for c in e.children {tintBody(c)}}
        tintBody(runner)
        if equipped["trail"] != nil {
            var g=Geometry();g.tube([[0,0.5,0.2],[0.15,0.35,0.65],[-0.1,0.2,1.1]],radius:0.03)
            if let mesh=try? g.resource() {let trail=ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:"#D5C6D6").withAlphaComponent(0.25),style:0)]);trail.name="equipped-trail";runner.addChild(trail)}
        }
        let hat=equipped["hat"] ?? "bare_head"
        if hat != "bare_head" {
            runner.findEntity(named:"hair-crown")?.isEnabled = ["bow","moon_hat","beyond_crown","lucky_pig_hat","balloon_hat"].contains(hat)
            headAttachment.addChild(fittedHat(hat))
        }
        if equipped["accessory"] == "unbroken_clover" { let e=factory.build(.clover); e.scale=[0.12,0.12,0.12]; e.position=[0.22,-0.25,0]; headAttachment.addChild(e) }
    }
    func local(_ sample:RouteSample,origin:RouteSample,lateral:Double = 0) -> SIMD3<Float> { [Float(sample.x-origin.x+lateral*cos(sample.yaw)),Float(sample.y-origin.y),Float(sample.z-origin.z+lateral*sin(sample.yaw))] }
    func render(_ run:RunState,equipped:[String:String],menu:Bool = false,lowPower:Bool = false) {
        wardrobeLight.isEnabled=false
        dress(equipped)
        if gallery?.name != "ending-pigs" || run.pigs.count != 3 { gallery?.removeFromParent(); gallery=nil }
        let cinematic = run.pigs.count == 3
        let visualDistance = run.distance + (cinematic ? min(45,run.endingElapsed)*2 + min(8,max(0,run.endingElapsed-45))*0.5 : 0)
        let generator=WorldGenerator(run.identity), newBase=floor(run.distance/192)*192, origin=generator.sample(newBase)
        var paletteRNG=run.identity.stream("palette",0)
        let targetPalette=artPalette ?? (cinematic ? (Int(paletteRNG.below(7))+Int(run.distance / 432)+run.mirrorCount*2)%7 : run.paletteIndex)
        if lastRun != run.id {
            distantPath.reset();art.resetHaze();art.invalidateEnvironment()
            world.children.removeAll(); gallery=nil; originalMaterials.removeAll(); chunks.removeAll(); hazards.removeAll(); pickups.removeAll(); base=newBase; palette=targetPalette; lastRun=run.id; lastVisual=run.visual
            evolution.reset(palette:palette,definition:factory.palettes[palette])
            // Create the sky once for this run. Palette changes tint the retained texture.
            art.environment(palette:palette == 5 ? 0 : palette,definition:factory.palettes[palette == 5 ? 0 : palette],view:view,enabled:true)
            if palette == 5 {art.tintSky(.black)}
            if run.identity.contentVersion >= 2 {view.environment.background = .color(.black)}
        } else if newBase != base {
            // Translate retained meshes into the new local origin; do not regenerate them.
            let shift=local(generator.sample(base),origin:origin)
            for child in world.children where child !== distantPath.root && child !== art.horizon && child !== art.collage.root {child.position += shift}
            distantPath.rebase(by:shift);art.rebase(by:shift)
            base=newBase
        }
        evolution.request(targetPalette,seconds:run.seconds,accelerated:run.phase == .mirrorCrossing || run.phase == .safeDrop,palettes:factory.palettes,art:art)
        if run.visual == .deepSparse && lastVisual != .deepSparse {view.environment.background = .color(.black)}
        palette=targetPalette;lastVisual=run.visual
        art.skyDome.isEnabled = !cinematic && run.visual != .deepSparse
        let active=Set(run.chunks.map(\.id))
        for (id,e) in chunks where !active.contains(id) { e.removeFromParent(); chunks.removeValue(forKey:id) }
        let sparse=run.visual == .deepSparse
        for c in run.chunks where chunks[c.id] == nil {
            let root=Entity(),p=factory.palettes[palette]
            var light=Geometry(),dark=Geometry(),rim=Geometry(),deck=Geometry()
            for n in 0..<24 {
                let s=c.start+Double(n), middle=s+0.5
                if !cinematic && c.gap?.contains(middle) == true { continue }
                let dropPosition=middle.truncatingRemainder(dividingBy:1800)
                if !cinematic && dropPosition >= 900 && dropPosition < 916 {continue}
                // Real gaps and drops never receive an invisible collision floor.
                let sampleA=generator.sample(s),sampleB=generator.sample(s+1)
                let a=local(sampleA,origin:origin), b=local(sampleB,origin:origin)
                let stair=[AssetID.stairsStraight,.stairsCurve,.stairsSpiral].contains(c.routeFamily)
                let y=stair ? max(a.y,b.y) : a.y
                let rightA=SIMD3<Float>(Float(cos(sampleA.yaw)),0,Float(sin(sampleA.yaw))), rightB=SIMD3<Float>(Float(cos(sampleB.yaw)),0,Float(sin(sampleB.yaw)))
                for x in 0..<4 {
                    let left=Float(x)-2, right=left+1
                    let aa=SIMD3<Float>(a.x,y,a.z)+rightA*left,bb=SIMD3<Float>(b.x,stair ? y : b.y,b.z)+rightB*left,cc=SIMD3<Float>(b.x,stair ? y : b.y,b.z)+rightB*right,dd=SIMD3<Float>(a.x,y,a.z)+rightA*right
                    if (Int(s)+x)%2 == 0 { light.quad(aa,dd,cc,bb) } else { dark.quad(aa,dd,cc,bb) }
                }
                let lower=SIMD3<Float>(0,-0.35,0)
                deck.quad(a-rightA*2+lower,b-rightB*2+lower,b+rightB*2+lower,a+rightA*2+lower)
                for x:Float in [-2.03,2.03] { let aa=a+rightA*x,bb=b+rightB*x;rim.tube([aa+[0,0.025,0],bb+[0,0.025,0]],radius:0.035,segments:4);deck.quad(aa,aa+lower,bb+lower,bb) }
                if stair {deck.quad(a-rightA*2,a+rightA*2,a+rightA*2+[0,y-a.y,0],a-rightA*2+[0,y-a.y,0])}
            }
            for (g,color,role) in [(light,UIColor(hex:p.track_light),"light"),(dark,UIColor(hex:p.track_dark),"dark"),(rim,UIColor(hex:p.accent_b),"rim"),(deck,UIColor(hex:p.fog),"deck")] where !g.positions.isEmpty {
                if let mesh=try? g.resource() { let model=ModelEntity(mesh:mesh,materials:[factory.material(color,style:4)]);model.name="palette:\(role)";root.addChild(model) }
            }
            if let drop=c.drop {
                for s in [drop.departure-1,drop.departure-0.6] { var g=Geometry(); let pos=local(generator.sample(s),origin:origin); g.box(pos+[0,0.05,0],[4.2,0.05,0.1]); if let mesh=try? g.resource() { root.addChild(ModelEntity(mesh:mesh,materials:[UnlitMaterial(color:.white)])) } }
                let landing=factory.build(.platform,palette:palette,lod:1); landing.scale=[1.25,1,0.18]; landing.position=local(generator.sample(drop.landing+2),origin:origin); root.addChild(landing)
            }
            let sceneAllowed = !sparse || c.id == Int(run.distance/24)+4
            if sceneAllowed {art.decorate(root,chunk:c,generator:generator,origin:origin,palette:palette,factory:factory,lowPower:lowPower)}
            chunks[c.id]=root; world.addChild(root);evolution.register(root,palette:palette,palettes:factory.palettes,art:art)
        }
        art.landscape(run:run,origin:origin,palette:palette,factory:factory,world:world,lowPower:lowPower,evolution:evolution)
        distantPath.update(run:run,origin:origin,palette:factory.palettes[palette],world:world)
        let activeHazards=Set(run.hazards.filter{ !$0.resolved }.map(\.id))
        for (id,e) in hazards where !activeHazards.contains(id) { e.removeFromParent(); hazards.removeValue(forKey:id) }
        for h in run.hazards where !h.resolved {
            let e:Entity
            if let existing=hazards[h.id] { e=existing } else {
                if h.isRollingSportsBall {
                    e=Entity()
                    let pivot=Entity(),mesh=factory.build(h.asset,palette:palette,lod:0)
                    pivot.name="rolling-ball";pivot.position.y=Float(h.rollingRadius)
                    mesh.position.y = -0.45
                    pivot.addChild(mesh);e.addChild(pivot)
                } else {e=factory.build(h.asset,palette:palette,lod:0)}
                if h.encounter == .jump { e.scale=[0.47,1,0.47]; e.orientation=simd_quatf(angle:.pi/2,axis:[0,0,1]) }
                if h.pig?.clover == true { let clover=factory.build(.clover,palette:palette); clover.scale=[0.45,0.45,0.45]; clover.position=[0,0.7,0]; e.addChild(clover) }
                world.addChild(e); hazards[h.id]=e
            }
            let routeSample=generator.sample(h.position(at:run.activeTicks))
            e.position=local(routeSample,origin:origin,lateral:h.lateral)
            e.orientation=simd_quatf(angle:-Float(routeSample.yaw),axis:[0,1,0])
            if h.encounter == .jump {e.orientation *= simd_quatf(angle:.pi/2,axis:[0,0,1]);e.position += [Float(cos(routeSample.yaw))*2,0.225,Float(sin(routeSample.yaw))*2]}
            if let pivot=e.findEntity(named:"rolling-ball") {pivot.orientation=simd_quatf(angle:Float(h.rollAngle(at:run.activeTicks)),axis:[1,0,0])}
            e.isEnabled=h.hasStartedMoving(at:run.activeTicks) && run.pigs.count < 3 && (h.pig != nil || h.encounter == .mirror || h.position(at:run.activeTicks) >= run.safeUntilDistance)
        }
        let available=run.chunks.flatMap(\.pickups).filter { !run.collectedIDs.contains($0.id) }
        let ids=Set(available.map(\.id))
        for (id,e) in pickups where !ids.contains(id) { e.removeFromParent(); pickups.removeValue(forKey:id) }
        for p in available where pickups[p.id] == nil {
            let e=factory.build(.balloon,palette:palette,style:1,lod:0); e.position=local(generator.sample(p.distance),origin:origin,lateral:p.lateral)+[0,0.3,0]; world.addChild(e); pickups[p.id]=e
        }
        let position=local(generator.sample(visualDistance),origin:origin,lateral:run.player.lateral)
        runner.position=position+[0,Float(run.player.height),0]; runner.isEnabled=true
        let slide=run.player.slideTicks > 0, faint=run.pigs.count == 3 && run.endingElapsed > 51
        let stumble=cinematic ? Float(0) : Float(run.stumbleWeight)
        let stumbleAge=Float(1-run.stumbleWeight)
        let heading=simd_quatf(angle:-Float(generator.sample(visualDistance).yaw),axis:[0,1,0])
        let dressRun=equipped["character"] == "girl"
        let activeGait = !menu && !faint && run.phase != .ready && run.phase != .finished
        // A six-metre full stride gives about four footfalls/second at the starting run speed.
        // Distance-based phase naturally slows the limbs during an obstacle hit.
        let t=Float(visualDistance.truncatingRemainder(dividingBy:6)/6)*2*Float.pi
        let pitch:Float=faint ? .pi/2 : slide ? .pi/2 : activeGait ? -0.14-0.45*stumble : 0
        let roll:Float=slide || faint ? 0 : sin(stumbleAge*22)*0.12*stumble
        runner.orientation=heading*simd_quatf(angle:pitch,axis:[1,0,0])*simd_quatf(angle:roll,axis:[0,0,1])
        if slide {
            // Face upward, feet ahead (-Z), head behind. Centre the reclined body over the hitbox.
            runner.position += heading.act(SIMD3<Float>(0,0.24,-0.75))
        } else if faint {runner.position += heading.act(SIMD3<Float>(0,0.2,-0.75))}
        else if activeGait {runner.position.y += (0.04+0.07*abs(sin(t)))*(1-stumble)-0.12*stumble}
        for i in 0..<2 {
            let stride=sin(t+Float(i)*Float.pi)
            let legAngle:Float=slide ? 0.1 : activeGait ? stride*(dressRun ? 0.8 : 0.95)*(1-stumble)+(i == 0 ? -0.5 : 0.3)*stumble : 0
            let kneeAngle:Float=slide ? -0.12 : activeGait ? -(0.2+max(0,-stride)*(dressRun ? 0.45 : 1.35))*(1-stumble)-0.35*stumble : 0
            let armAngle:Float=slide ? 0 : activeGait ? -stride*0.75*(1-stumble)-0.9*stumble : 0
            legs[i].orientation=simd_quatf(angle:legAngle,axis:[1,0,0])
            knees[i].orientation=simd_quatf(angle:kneeAngle,axis:[1,0,0])
            arms[i].orientation=simd_quatf(angle:armAngle,axis:[1,0,0])*simd_quatf(angle:(i == 0 ? -1 : 1)*(slide ? 0.08 : 0.45*stumble),axis:[0,0,1])
            elbows[i].orientation=simd_quatf(angle:slide ? 0.15 : activeGait ? 1.35 : 0,axis:[1,0,0])
        }
        if let authoredRunner {
            runner.orientation=heading
            let clip=faint ? "faint" : slide ? "slide" : stumble>0 ? "stumble" : run.phase == .safeDrop ? "fall" : run.player.height>0.05 ? "jump" : activeGait ? "run" : "idle"
            authoredRunner.pose(clip,speed:clip == "run" ? Float(run.speed/12.25) : 1)
        }
        if cinematic && run.endingElapsed >= 45 {
            if gallery == nil { let pigs=Entity(); pigs.name="ending-pigs"; for i in 0..<3 { let e=factory.build(.pig,palette:7); e.position=position+[Float(i-1)*1.1,0,-6]; pigs.addChild(e) }; gallery=pigs; world.addChild(pigs) }
            for e in pickups.values { e.isEnabled=false }
        }
        if cinematic {
            let blend = CGFloat(min(1,run.endingElapsed/45))
            let start=UIColor(hex:factory.palettes[palette].sky), white=UIColor(hex:"#F4F3EF")
            view.environment.background = .color(mix(start,white,blend))
            whiten(world,amount:blend)
            for (id,chunk) in chunks {
                for e in chunk.children where e.name == "scenery" { e.isEnabled = Double(abs(id)%12)/12 > Double(blend) }
            }
            for e in pickups.values {e.isEnabled=false}
        }
        let cameraPosition=local(generator.sample(visualDistance-4.8),origin:origin,lateral:run.player.lateral*0.2)+[0,2.8,0]
        let target=local(generator.sample(visualDistance+9),origin:origin)+[0,0.7,0]
        camera.look(at:target,from:cameraPosition,relativeTo:nil)
        art.collage.update(run:run,origin:origin,world:world,camera:camera,aspect:Float(view.bounds.width/max(1,view.bounds.height)),lowPower:lowPower,voidWeight:evolution.voidWeight(seconds:run.seconds))
        if run.identity.contentVersion >= 2 && art.collage.loadedTextureCount>0 {art.skyDome.isEnabled=false}
        if !cinematic {
            evolution.update(seconds:run.seconds,palettes:factory.palettes,art:art)
            art.haze(world,camera:cameraPosition,color:evolution.fog)
        }
        if run.visual == .deepStripping || run.visual == .deepRebuilding {
            let cycle=run.seconds.truncatingRemainder(dividingBy:10800)
            let fraction=run.visual == .deepStripping ? max(0,1-cycle/240) : min(1,(cycle-300)/300)
            for (id,chunk) in chunks {for (index,e) in chunk.children.filter({$0.name == "scenery"}).enumerated() {e.isEnabled=Double((id*2+index)%24)/24 < fraction}}
        }
        func count(_ entity:Entity)->Int {1+entity.children.reduce(0){$0+count($1)}}
        renderEntities=count(anchor)
    }
    func mix(_ a:UIColor,_ b:UIColor,_ t:CGFloat)->UIColor {
        var ar:CGFloat=0,ag:CGFloat=0,ab:CGFloat=0,aa:CGFloat=0,br:CGFloat=0,bg:CGFloat=0,bb:CGFloat=0,ba:CGFloat=0
        a.artSRGB.getRed(&ar,green:&ag,blue:&ab,alpha:&aa);b.artSRGB.getRed(&br,green:&bg,blue:&bb,alpha:&ba)
        return UIColor(red:ar+(br-ar)*t,green:ag+(bg-ag)*t,blue:ab+(bb-ab)*t,alpha:1)
    }
    func whiten(_ entity:Entity,amount:CGFloat) {
        if entity.name == "ending-pigs" {return}
        if let model=entity as? ModelEntity, let component=model.model {
            let key=ObjectIdentifier(model)
            if originalMaterials[key] == nil {originalMaterials[key]=component.materials.compactMap{$0 as? PhysicallyBasedMaterial}}
            if let originals=originalMaterials[key],!originals.isEmpty {
                model.model?.materials=originals.map { original in var m=original;m.baseColor.tint=mix(original.baseColor.tint,UIColor(hex:"#F4F3EF"),amount);return m }
            }
        }
        for child in entity.children {whiten(child,amount:amount)}
    }
    func previewAvatar(equipped:[String:String],wardrobe:Bool = false) {
        wardrobeLight.isEnabled=true
        art.invalidateEnvironment();art.skyDome.isEnabled=false
        world.children.removeAll();chunks.removeAll();hazards.removeAll();pickups.removeAll();lastRun=nil
        runner.isEnabled=true;runner.position = .zero;runner.orientation=simd_quatf(angle:0,axis:[0,1,0]);dress(equipped)
        for e in legs+arms+knees+elbows {e.orientation=simd_quatf(angle:0,axis:[1,0,0])}
        authoredRunner?.pose("idle")
        camera.look(at:wardrobe ? [0,-1.15,0] : [0,1,0],from:wardrobe ? [2,-0.55,-6.7] : [1.4,1.5,-3.3],relativeTo:nil)
        view.environment.background = .color(UIColor(hex:"#686378"))
    }
    func preview(_ id:AssetID,palette:Int,style:Int,lod:Int,colliders:Bool = false) {
        art.invalidateEnvironment();art.skyDome.isEnabled=false
        world.children.removeAll(); chunks.removeAll(); hazards.removeAll(); pickups.removeAll(); gallery=nil; runner.isEnabled=false; lastRun=nil
        let e=factory.build(id,palette:palette,style:style,lod:lod); world.addChild(e); gallery=e
        let bounds=e.visualBounds(relativeTo:e), center=bounds.center, extent=max(bounds.extents.x,max(bounds.extents.y,bounds.extents.z))
        if colliders {
            var g=Geometry()
            if id == .horse || id == .zebra {g.box([0,1.625,0],[4,1.55,1.2]);for x:Float in [-1.7,1.7] {for z:Float in [-0.43,0.43] {g.box([x,0.425,z],[0.25,0.85,0.25])}}}
            else {g.box(bounds.center,bounds.extents)}
            var material=SimpleMaterial(color:.cyan,roughness:1,isMetallic:false);material.triangleFillMode = .lines
            if let mesh=try? g.resource() {e.addChild(ModelEntity(mesh:mesh,materials:[material]))}
        }
        camera.look(at:center,from:center+[extent*0.7,extent*0.45,max(2,extent*1.15)],relativeTo:nil)
        view.environment.background = .color(UIColor(hex:factory.palettes[palette].sky))
    }
    func snapshot(_ completion:@escaping (UIImage?)->Void) { view.snapshot(saveToHDR:false,completion:completion) }
}
struct DreamSceneView: UIViewRepresentable {
    let renderer:DreamRenderer
    func makeUIView(context:Context) -> ARView { renderer.view }
    func updateUIView(_ uiView:ARView,context:Context) {}
}
