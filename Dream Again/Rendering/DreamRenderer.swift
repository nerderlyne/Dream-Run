import SwiftUI
import RealityKit
import UIKit
import simd

@MainActor final class DreamRenderer {
    let view: ARView
    let anchor=AnchorEntity(world:.zero)
    let world=Entity(), runner=Entity(), camera=PerspectiveCamera(), headAttachment=Entity()
    var chunks: [Int:Entity]=[:], hazards: [String:Entity]=[:], pickups: [String:Entity]=[:]
    var legs:[Entity]=[], arms:[Entity]=[]
    var factory: PrefabFactory
    var palette = -1, base = -1.0, lastRun:UUID?, outfit="", lastVisual:VisualPhase = .ordinary
    var gallery:Entity?
    var renderEntities = 0
    var frozenFrame: UIImage?
    var originalMaterials: [ObjectIdentifier:[SimpleMaterial]] = [:]
    init(palettes:[PaletteDefinition]) {
        factory=PrefabFactory(palettes:palettes)
        view=ARView(frame:.zero,cameraMode:.nonAR,automaticallyConfigureSession:false)
        view.renderOptions=[.disableMotionBlur,.disableDepthOfField,.disableCameraGrain]
        let lightingImage=UIGraphicsImageRenderer(size:CGSize(width:512,height:256)).image { context in
            let colors=[UIColor(hex:"#AAB7D0").cgColor,UIColor(hex:"#FFF0E2").cgColor,UIColor(hex:"#79748C").cgColor] as CFArray
            if let gradient=CGGradient(colorsSpace:CGColorSpaceCreateDeviceRGB(),colors:colors,locations:[0,0.5,1]) {context.cgContext.drawLinearGradient(gradient,start:.zero,end:CGPoint(x:0,y:256),options:[])}
        }
        Task { [weak self] in
            if let image=lightingImage.cgImage,let environment=try? await EnvironmentResource(equirectangular:image) {self?.view.environment.lighting.resource=environment;self?.view.environment.lighting.intensityExponent=0.3}
        }
        view.scene.addAnchor(anchor); anchor.addChild(world); anchor.addChild(runner); anchor.addChild(camera)
        camera.camera.fieldOfViewInDegrees=62
        let light=DirectionalLight(); light.light.intensity=2500; light.light.color=UIColor(hex:"#FFF0E4"); light.look(at:[0,0,0],from:[-6,10,8],relativeTo:nil); anchor.addChild(light)
        let fill=PointLight(); fill.light.intensity=750; fill.light.attenuationRadius=80; fill.position=[4,9,8]; anchor.addChild(fill)
        buildAvatar()
    }
    func piece(_ center:SIMD3<Float>,_ scale:SIMD3<Float>,color:UIColor) -> Entity {
        var g=Geometry(); g.ellipsoid(center,scale,segments:14,rings:8)
        let entity=(try? ModelEntity(mesh:g.resource(),materials:[factory.material(color,style:0)])) ?? ModelEntity()
        if color == UIColor(hex:"#A6BAC0") {entity.name="avatar-body"}; return entity
    }
    func buildAvatar() {
        let skin=UIColor(hex:"#E9DCCB"), suit=UIColor(hex:"#A6BAC0")
        runner.addChild(piece([0,0.98,0],[0.24,0.32,0.15],color:suit))
        runner.addChild(piece([0,1.37,0],[0.19,0.21,0.18],color:skin))
        // Doll-like face faces travel (-Z); visible in wardrobe previews.
        for x:Float in [-0.065,0.065] { runner.addChild(piece([x,1.4,-0.168],[0.02,0.025,0.01],color:UIColor(hex:"#59505E"))) }
        for sign:Float in [-1,1] {
            let leg=Entity(); leg.position=[sign*0.12,0.75,0]; leg.addChild(piece([0,-0.32,0],[0.085,0.32,0.09],color:suit)); leg.addChild(piece([0,-0.65,-0.055],[0.09,0.065,0.15],color:skin)); runner.addChild(leg); legs.append(leg)
            let arm=Entity(); arm.position=[sign*0.27,1.15,0]; arm.addChild(piece([0,-0.23,0],[0.065,0.25,0.07],color:skin)); runner.addChild(arm); arms.append(arm)
        }
        headAttachment.position=[0,1.56,0]; runner.addChild(headAttachment)
    }
    func dress(_ equipped:[String:String]) {
        let signature=equipped.keys.sorted().map { "\($0):\(equipped[$0]!)" }.joined()
        guard signature != outfit else { return }; outfit=signature
        headAttachment.children.removeAll()
        runner.children.filter{$0.name == "equipped-trail"}.forEach{$0.removeFromParent()}
        let colors=["pearl_body":"#E9E6E2","rose_body":"#CBA6B7","mint_body":"#ACCFBE"]
        let bodyColor=UIColor(hex:colors[equipped["body_color"] ?? ""] ?? "#A6BAC0")
        func tintBody(_ e:Entity) {if let model=e as? ModelEntity,e.name == "avatar-body" {model.model?.materials=[factory.material(bodyColor,style:0)]};for c in e.children {tintBody(c)}}
        tintBody(runner)
        if equipped["trail"] != nil {
            var g=Geometry();g.tube([[0,0.5,0.2],[0.15,0.35,0.65],[-0.1,0.2,1.1]],radius:0.03)
            if let mesh=try? g.resource() {let trail=ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:"#D5C6D6").withAlphaComponent(0.25),style:0)]);trail.name="equipped-trail";runner.addChild(trail)}
        }
        let hat=equipped["hat"] ?? "bare_head"
        let mapped:[String:AssetID]=["bow":.ribbon,"balloon_hat":.balloon,"eight_ball_hat":.eightBall,"tiny_house_hat":.house,"moon_hat":.moon,"lucky_pig_hat":.pig,"beyond_crown":.star]
        if hat == "lucky_pig_hat" {for n in 0..<3 {let e=factory.build(.pig,palette:7);e.scale=[0.18,0.18,0.18];e.position=[Float(n-1)*0.16,0,0];headAttachment.addChild(e)};let c=factory.build(.clover);c.scale=[0.15,0.15,0.15];c.position=[0,0.12,0];headAttachment.addChild(c)}
        else if hat == "beyond_crown" {var g=Geometry();g.tube((0...18).map{let a=Float($0)/24*2*Float.pi;return [cos(a)*0.23,0.08,sin(a)*0.23]},radius:0.025);for x:Float in [-0.15,0,0.15]{g.polygon([[-0.045,0],[0.045,0],[0,0.13]],center:[x,0.14,-0.12],depth:0.03)};if let mesh=try? g.resource(){headAttachment.addChild(ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:"#E3C786"),style:2)]))}}
        else if let id=mapped[hat] { let e=factory.build(id,palette:max(0,palette)); let scale:Float=id == .house ? 0.17 : id == .ribbon ? 0.16 : 0.3; e.scale=SIMD3(repeating:scale); headAttachment.addChild(e) }
        else if hat != "bare_head" {
            var g=Geometry()
            if hat == "paper_hat" { g.polygon([[-0.25,0],[0.25,0],[0,0.28]],center:.zero,depth:0.23) }
            else { g.ellipsoid([0,0.08,0],[0.23,hat == "nightcap" ? 0.25 : 0.14,0.21]); g.box([0,0,0],[0.52,0.04,0.43]) }
            if let mesh=try? g.resource() { headAttachment.addChild(ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:hat == "nightcap" ? "#B3ABC9" : "#ECE6E1"),style:0)])) }
        }
        if equipped["accessory"] == "unbroken_clover" { let e=factory.build(.clover); e.scale=[0.12,0.12,0.12]; e.position=[0.22,-0.25,0]; headAttachment.addChild(e) }
    }
    func local(_ sample:RouteSample,origin:RouteSample,lateral:Double = 0) -> SIMD3<Float> { [Float(sample.x-origin.x+lateral*cos(sample.yaw)),Float(sample.y-origin.y),Float(sample.z-origin.z+lateral*sin(sample.yaw))] }
    func render(_ run:RunState,equipped:[String:String],menu:Bool = false,lowPower:Bool = false) {
        if gallery?.name != "ending-pigs" || run.pigs.count != 3 { gallery?.removeFromParent(); gallery=nil }
        let cinematic = run.pigs.count == 3
        let visualDistance = run.distance + (cinematic ? min(45,run.endingElapsed)*2 + min(8,max(0,run.endingElapsed-45))*0.5 : 0)
        let generator=WorldGenerator(run.identity), newBase=floor(run.distance/192)*192, origin=generator.sample(newBase)
        var paletteRNG=run.identity.stream("palette",0)
        let targetPalette=cinematic ? (Int(paletteRNG.below(7))+Int(run.distance / 432)+run.mirrorCount*2)%7 : run.paletteIndex
        if lastRun != run.id || newBase != base || palette != targetPalette || lastVisual != run.visual {
            world.children.removeAll(); gallery=nil; originalMaterials.removeAll(); chunks.removeAll(); hazards.removeAll(); pickups.removeAll(); base=newBase; palette=targetPalette; lastRun=run.id; lastVisual=run.visual
            view.environment.background = .color(UIColor(hex:factory.palettes[palette].sky))
        }
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
                if stair {deck.quad(a-rightA*2,a+rightA*2,a+rightA*2+[0,0.15,0],a-rightA*2+[0,0.15,0])}
            }
            for (g,color) in [(light,UIColor(hex:p.track_light)),(dark,UIColor(hex:p.track_dark)),(rim,UIColor(hex:p.accent_b)),(deck,UIColor(hex:p.fog))] where !g.positions.isEmpty {
                if let mesh=try? g.resource() { root.addChild(ModelEntity(mesh:mesh,materials:[factory.material(color,style:0)])) }
            }
            if let drop=c.drop {
                for s in [drop.departure-1,drop.departure-0.6] { var g=Geometry(); let pos=local(generator.sample(s),origin:origin); g.box(pos+[0,0.05,0],[4.2,0.05,0.1]); if let mesh=try? g.resource() { root.addChild(ModelEntity(mesh:mesh,materials:[UnlitMaterial(color:.white)])) } }
                let landing=factory.build(.platform,palette:palette,lod:1); landing.scale=[1.25,1,0.18]; landing.position=local(generator.sample(drop.landing+2),origin:origin); root.addChild(landing)
            }
            let sceneAllowed = !sparse || c.id == Int(run.distance/24)+4
            if sceneAllowed {
                for placement in c.scenery.prefix(sparse || lowPower ? 1 : 2) {
                    let e=factory.build(placement.asset,palette:palette,style:c.recipe%4,lod:lowPower ? 2 : 1)
                    let bounds=e.visualBounds(relativeTo:e)
                    let radius=Double(max(bounds.extents.x,bounds.extents.z))*placement.scale/2
                    let clearance=(placement.lateral < 0 ? -1.0 : 1.0)*max(abs(placement.lateral),radius+8)
                    e.scale=SIMD3(repeating:Float(placement.scale)); e.position=local(generator.sample(placement.distance),origin:origin,lateral:clearance)
                    if placement.asset == .cloud { e.position.y -= 5 }; if placement.asset == .water { e.position.y -= 4; e.scale=[3,1,3] }
                    e.name="scenery"; root.addChild(e)
                }
            }
            chunks[c.id]=root; world.addChild(root)
        }
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
            let e=factory.build(.balloon,palette:palette,lod:1); e.position=local(generator.sample(p.distance),origin:origin,lateral:p.lateral)+[0,0.3,0]; world.addChild(e); pickups[p.id]=e
        }
        let position=local(generator.sample(visualDistance),origin:origin,lateral:run.player.lateral)
        runner.position=position+[0,Float(run.player.height),0]; runner.isEnabled=true
        let slide=run.player.slideTicks > 0, faint=run.pigs.count == 3 && run.endingElapsed > 51
        let stumble=cinematic ? Float(0) : Float(run.stumbleWeight)
        let stumbleAge=Float(1-run.stumbleWeight)
        let pitch:Float=faint ? .pi/2 : slide ? -1.15 : -0.55*stumble
        let roll:Float=sin(stumbleAge*22)*0.12*stumble
        runner.orientation=simd_quatf(angle:-Float(generator.sample(visualDistance).yaw),axis:[0,1,0])*simd_quatf(angle:pitch,axis:[1,0,0])*simd_quatf(angle:roll,axis:[0,0,1])
        if slide {runner.position.y += 0.1} else if !faint {runner.position.y -= 0.12*stumble}
        if faint {runner.position.y += 0.2}
        let t=Float(run.seconds)*10
        for i in 0..<2 {
            let stride=sin(t+Float(i)*Float.pi)
            let legAngle:Float=slide ? 0.6 : stride*0.55*(1-stumble)+(i == 0 ? -0.5 : 0.3)*stumble
            let armAngle:Float=slide ? -0.5 : -stride*0.5*(1-stumble)-0.9*stumble
            legs[i].orientation=simd_quatf(angle:legAngle,axis:[1,0,0])
            arms[i].orientation=simd_quatf(angle:armAngle,axis:[1,0,0])*simd_quatf(angle:(i == 0 ? -0.45 : 0.45)*stumble,axis:[0,0,1])
        }
        if cinematic && run.endingElapsed >= 45 {
            if gallery == nil { let pigs=Entity(); pigs.name="ending-pigs"; for i in 0..<3 { let e=factory.build(.pig,palette:7); e.position=position+[Float(i-1)*1.1,0,-6]; pigs.addChild(e) }; gallery=pigs; world.addChild(pigs) }
            for e in pickups.values { e.isEnabled=false }
        }
        dress(equipped)
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
        a.getRed(&ar,green:&ag,blue:&ab,alpha:&aa);b.getRed(&br,green:&bg,blue:&bb,alpha:&ba)
        return UIColor(red:ar+(br-ar)*t,green:ag+(bg-ag)*t,blue:ab+(bb-ab)*t,alpha:1)
    }
    func whiten(_ entity:Entity,amount:CGFloat) {
        if entity.name == "ending-pigs" {return}
        if let model=entity as? ModelEntity, let component=model.model {
            let key=ObjectIdentifier(model)
            if originalMaterials[key] == nil {originalMaterials[key]=component.materials.compactMap{$0 as? SimpleMaterial}}
            if let originals=originalMaterials[key],!originals.isEmpty {
                model.model?.materials=originals.map { original in var m=original;m.color.tint=mix(original.color.tint,UIColor(hex:"#F4F3EF"),amount);return m }
            }
        }
        for child in entity.children {whiten(child,amount:amount)}
    }
    func previewAvatar(equipped:[String:String]) {
        world.children.removeAll();chunks.removeAll();hazards.removeAll();pickups.removeAll();lastRun=nil
        runner.isEnabled=true;runner.position = .zero;runner.orientation=simd_quatf(angle:0,axis:[0,1,0]);dress(equipped)
        for e in legs+arms {e.orientation=simd_quatf(angle:0,axis:[1,0,0])}
        camera.look(at:[0,1,0],from:[1.4,1.5,-3.3],relativeTo:nil)
        view.environment.background = .color(UIColor(hex:"#686378"))
    }
    func preview(_ id:AssetID,palette:Int,style:Int,lod:Int,colliders:Bool = false) {
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
