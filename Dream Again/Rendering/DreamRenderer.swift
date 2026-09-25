import SwiftUI
import RealityKit
import UIKit
import simd

@MainActor final class DreamRenderer {
    let view: ARView
    let anchor=AnchorEntity(world:.zero)
    let world=Entity(), runner=Entity(), camera=PerspectiveCamera(), headAttachment=Entity()
    var terrainKeys:[Int:String]=[:]
    private var trackAlphas:[Int:Float]=[:]
    let distantPath=DistantPathRenderer()
    let art=DreamArtDirection()
    let evolution=PaletteEvolution()
    let wardrobeLight=PointLight()
    let wardrobeFill=PointLight(), wardrobeHalo=Entity()
    let storm=StormVFX()
    let daylight=DirectionalLight(),ambientFill=PointLight()
    var chunks: [Int:Entity]=[:], hazards: [String:Entity]=[:], pickups: [String:Entity]=[:]
    var legs:[Entity]=[], arms:[Entity]=[], knees:[Entity]=[], elbows:[Entity]=[]
    var factory: PrefabFactory
    let vividPalettes:[PaletteDefinition]
    var artPalette:Int?
    var artPattern:TrackPattern?
    var palette = -1, base = -1.0, lastRun:UUID?, lastVisual:VisualPhase = .ordinary
    private var equippedCache:[String:String]?
    var gallery:Entity?
    var renderEntities = 0
    var strawBallPrototype:Entity?
    var obstacleCache=BoundedLRUCache<String,Entity>(capacity:24)
    private var resourcesPrepared=false
    private var lastEntityCountTime = -Double.infinity
    let balloonPops=BalloonPopEffects()
    let strawBursts=StrawBurstEffects()
    var lastHayCount=0
    var lastStrawState:[StrawLimb]=[]
    var frozenFrame: UIImage?
    var originalMaterials: [ObjectIdentifier:[PhysicallyBasedMaterial]] = [:]
    init(palettes:[PaletteDefinition]) {
        factory=PrefabFactory(palettes:palettes)
        vividPalettes=TrackArt.palettes(palettes)
        view=ARView(frame:.zero,cameraMode:.nonAR,automaticallyConfigureSession:false)
        view.renderOptions=[.disableMotionBlur,.disableDepthOfField,.disableCameraGrain]
        view.scene.addAnchor(anchor); anchor.addChild(world); anchor.addChild(runner); anchor.addChild(camera)
        camera.camera.fieldOfViewInDegrees=62
        camera.camera.far=8000
        let light=daylight; light.light.intensity=4200; light.light.color=UIColor(hex:"#FFF0E4"); light.look(at:[0,0,0],from:[-6,10,8],relativeTo:nil); light.shadow = .init();anchor.addChild(light)
        let fill=ambientFill; fill.light.intensity=750; fill.light.attenuationRadius=80; fill.position=[4,9,8]; anchor.addChild(fill)
        wardrobeLight.light.intensity=6000;wardrobeLight.light.attenuationRadius=12;wardrobeLight.position=[-1.8,2.8,-2.5];wardrobeLight.isEnabled=false;anchor.addChild(wardrobeLight)
        wardrobeFill.light.intensity=4800;wardrobeFill.light.attenuationRadius=10;wardrobeFill.light.color=UIColor(hex:"#DCE9FF");wardrobeFill.position=[1.8,1.3,-2.2];wardrobeFill.isEnabled=false;anchor.addChild(wardrobeFill)
        wardrobeHalo.name="wardrobe-halo";wardrobeHalo.isEnabled=false;anchor.addChild(wardrobeHalo)
        buildWardrobeHalo()
        buildStrawDoll()
    }
    private func buildWardrobeHalo() {
        let size=512
        var pixels=[UInt8](repeating:0,count:size*size*4)
        for y in 0..<size { for x in 0..<size {
            let dx=(Double(x)+0.5)/Double(size)*2-1
            let dy=(Double(y)+0.5)/Double(size)*2-1
            let falloff=exp(-4.5*(dx*dx+dy*dy))
            var hash=UInt32(truncatingIfNeeded:(x &* 374_761_393) ^ (y &* 668_265_263))
            hash=(hash ^ (hash >> 13)) &* 1_274_126_177
            hash ^= hash >> 16
            let dither=Double(hash & 0xffff)/65535-0.5
            let offset=(y*size+x)*4
            pixels[offset]=226;pixels[offset+1]=222;pixels[offset+2]=236
            pixels[offset+3]=UInt8(max(0,min(255,(0.055*falloff*255+dither).rounded())))
        } }
        guard let provider=CGDataProvider(data:Data(pixels) as CFData),
              let image=CGImage(width:size,height:size,bitsPerComponent:8,bitsPerPixel:32,bytesPerRow:size*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGBitmapInfo(rawValue:CGImageAlphaInfo.last.rawValue),provider:provider,decode:nil,shouldInterpolate:true,intent:.defaultIntent),
              let texture=try? TextureResource(image:image,options:.init(semantic:.color)) else {return}
        var mesh=MeshDescriptor(name:"Wardrobe soft halo")
        mesh.positions = .init([[-2,0,0],[2,0,0],[2,4.2,0],[-2,4.2,0]])
        mesh.normals = .init(Array(repeating:SIMD3<Float>(0,0,-1),count:4))
        mesh.textureCoordinates = .init([[0,0],[1,0],[1,1],[0,1]])
        mesh.primitives = .triangles([0,1,2,0,2,3])
        guard let resource=try? MeshResource.generate(from:[mesh]) else {return}
        var material=UnlitMaterial(applyPostProcessToneMap:false)
        material.color = .init(tint:.white,texture:.init(texture))
        material.blending = .transparent(opacity:.init(floatLiteral:1))
        material.faceCulling = .none
        let card=ModelEntity(mesh:resource,materials:[material]);card.position=[0,-0.95,1.25]
        card.components.set(DynamicLightShadowComponent(castsShadow:false))
        wardrobeHalo.addChild(card)
    }
    /// Called while preparing a run, before its active clock starts.
    func prepareGameplay() {
        guard !resourcesPrepared else{return}
        resourcesPrepared=true
        factory.prepareGameplay()
        _ = strawBall()
        for (asset,encounter) in [(AssetID.moon,Encounter.swing),(.window,.slide),(.bed,.jump),(.chair,.jump)] {
            _ = obstacleModel(HazardDescription(id:"prewarm",asset:asset,encounter:encounter,distance:0,lateral:0,radius:0.5,height:1))
        }
    }
    func dress(_ equipped:[String:String]) {
        guard equipped != equippedCache else {return};equippedCache=equipped
        headAttachment.children.removeAll()
        runner.children.filter{$0.name == "equipped-trail"}.forEach{$0.removeFromParent()}
        let colors=["pearl_body":"#E9E6E2","rose_body":"#CBA6B7","mint_body":"#ACCFBE"]
        let bodyColor=UIColor(hex:colors[equipped["top"] ?? ""] ?? "#B5C8C3")
        strawCostume(top:equipped["top"] ?? "bare_top",bottom:equipped["bottom"] ?? "plain_bottom",color:bodyColor)
        if equipped["trail"] == "void_ribbon" {
            var g=Geometry();g.tube([[0,0.5,0.2],[0.15,0.35,0.65],[-0.1,0.2,1.1]],radius:0.03)
            if let mesh=try? g.resource() {let trail=ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:"#D5C6D6").withAlphaComponent(0.25),style:0)]);trail.name="equipped-trail";runner.addChild(trail)}
        }
        let hat=equipped["hat"] ?? "bare_head"
        if hat != "bare_head" {
            headAttachment.addChild(fittedHat(hat))
        }
        if equipped["accessory"] == "unbroken_clover" { let e=factory.build(.clover); e.scale=[0.12,0.12,0.12]; e.position=[0.22,-0.25,0]; headAttachment.addChild(e) }
    }
    func local(_ sample:RouteSample,origin:RouteSample,lateral:Double = 0) -> SIMD3<Float> { [Float(sample.x-origin.x+lateral*cos(sample.yaw)),Float(sample.y-origin.y),Float(sample.z-origin.z+lateral*sin(sample.yaw))] }
    func render(_ run:RunState,equipped:[String:String],menu:Bool = false,lowPower:Bool = false) {
        let surfacePalettes=vividPalettes
        wardrobeLight.isEnabled=false;wardrobeFill.isEnabled=false;wardrobeHalo.isEnabled=false
        let threat=run.hazards.filter{$0.encounter == .lightning}.map {h -> Float in
            let d=h.distance-run.distance
            return d < -5 ? 0:Float(max(0,min(1,(42-d)/30)))
        }.max() ?? 0
        daylight.light.intensity=4200-2900*threat;ambientFill.light.intensity=750-550*threat
        dress(equipped)
        if gallery?.name != "ending-pigs" || run.pigs.count != 3 { gallery?.removeFromParent(); gallery=nil }
        let cinematic = run.pigs.count == 3
        let visualDistance = run.distance + (cinematic ? min(45,run.endingElapsed)*2 + min(8,max(0,run.endingElapsed-45))*0.5 : 0)
        let generator=WorldGenerator(run.identity), newBase=floor(run.distance/192)*192, origin=generator.sample(newBase)
        var paletteRNG=run.identity.stream("palette",0)
        let targetPalette=artPalette ?? (cinematic ? (Int(paletteRNG.below(7))+Int(run.distance / 432)+run.mirrorCount*2)%7 : run.paletteIndex)
        if lastRun != run.id {
            distantPath.reset();art.reset();art.invalidateEnvironment()
            strawBursts.reset();lastHayCount=run.hayCollected;lastStrawState=run.player.missingLimbs;balloonPops.reset();world.children.removeAll(); gallery=nil; originalMaterials.removeAll(); chunks.removeAll(); terrainKeys.removeAll();trackAlphas.removeAll(); hazards.removeAll(); pickups.removeAll(); base=newBase; palette=targetPalette; lastRun=run.id; lastVisual=run.visual
            evolution.reset(palette:palette,definition:surfacePalettes[palette])
            art.environment(view:view)
        } else if newBase != base {
            // Translate retained meshes into the new local origin; do not regenerate them.
            let shift=local(generator.sample(base),origin:origin)
            for child in world.children where child !== distantPath.root && child !== art.collage.root {child.position += shift}
            distantPath.rebase(by:shift);art.rebase(by:shift)
            base=newBase
        }
        evolution.request(targetPalette,seconds:run.seconds,accelerated:run.phase == .mirrorCrossing || run.phase == .safeDrop,palettes:surfacePalettes,art:art)
        // Always restore the emergency reality after void, even when a photo load fails.
        let visibility=DreamCollageComposition.plateVisibility(seconds:run.seconds,visual:run.visual,voidWeight:evolution.voidWeight(seconds:run.seconds))
        view.environment.background = .color(mix(.black,UIColor(hex:"#77748F"),CGFloat(visibility)))
        palette=targetPalette;lastVisual=run.visual
        let active=Set(run.chunks.map(\.id))
        for (id,e) in chunks where !active.contains(id) { e.removeFromParent(); chunks.removeValue(forKey:id);terrainKeys.removeValue(forKey:id) }
        for c in run.chunks {
            let key="\(c.halfWidth)/\(String(describing:c.gap))/\(String(describing:c.step))/\(c.collapsing)"
            if terrainKeys[c.id] != key {chunks[c.id]?.removeFromParent();chunks[c.id]=nil;trackAlphas[c.id]=nil;terrainKeys[c.id]=key}
        }
        terrainKeys=terrainKeys.filter{active.contains($0.key)}
        trackAlphas=trackAlphas.filter{active.contains($0.key)}
        for c in run.chunks where chunks[c.id] == nil {
            let root=Entity(),p=surfacePalettes[palette]
            let pattern=artPattern ?? (c.id == 0 ? .checker : TrackArt.pattern(identity:run.identity,distance:c.start))
            var light=Geometry(),dark=Geometry(),rim=Geometry(),deck=Geometry()
            // The camera starts behind route distance zero. Give the opening
            // section a visual apron so the near edge never cuts across the
            // bottom of the screen while the run is waiting for Ready.
            for n in (c.id == 0 ? -24 : 0)..<24 {
                let s=c.start+Double(n), middle=s+0.5
                if !cinematic && c.gap?.contains(middle) == true { continue }
                // Every missing surface is backed by a real simulation gap.
                let sampleA=generator.sample(s),sampleB=generator.sample(s+1)
                let elevation=Float(c.step?.height(at:middle) ?? 0)
                let a=local(sampleA,origin:origin)+[0,elevation,0], b=local(sampleB,origin:origin)+[0,elevation,0]
                let stair=[AssetID.stairsStraight,.stairsSpiral].contains(c.routeFamily)
                let y=stair ? max(a.y,b.y) : a.y
                let rightA=SIMD3<Float>(Float(cos(sampleA.yaw)),0,Float(sin(sampleA.yaw))), rightB=SIMD3<Float>(Float(cos(sampleB.yaw)),0,Float(sin(sampleB.yaw)))
                for x in 0..<4 {
                    let width=Float(c.halfWidth)
                    let left=(Float(x)/2-1)*width, right=left+width/2
                    let aa=SIMD3<Float>(a.x,y,a.z)+rightA*left,bb=SIMD3<Float>(b.x,stair ? y : b.y,b.z)+rightB*left,cc=SIMD3<Float>(b.x,stair ? y : b.y,b.z)+rightB*right,dd=SIMD3<Float>(a.x,y,a.z)+rightA*right
                    if TrackArt.isLight(pattern,distance:Int(s),column:x) { light.quad(aa,dd,cc,bb) } else { dark.quad(aa,dd,cc,bb) }
                }
                let lower=SIMD3<Float>(0,-0.35,0)
                for x:Float in [-Float(c.halfWidth)-0.03,Float(c.halfWidth)+0.03] { let aa=a+rightA*x,bb=b+rightB*x;rim.tube([aa+[0,0.025,0],bb+[0,0.025,0]],radius:0.035,segments:4);deck.quad(aa,aa+lower,bb+lower,bb) }
                let rise=elevation-Float(c.step?.height(at:s-0.5) ?? 0)
                if stair || rise != 0 {rim.tube([SIMD3<Float>(a.x,y+0.03,a.z)-rightA*Float(c.halfWidth),SIMD3<Float>(a.x,y+0.03,a.z)+rightA*Float(c.halfWidth)],radius:0.025,segments:4)}
                if rise != 0 {deck.quad(a-rightA*Float(c.halfWidth)-[0,rise,0],a+rightA*Float(c.halfWidth)-[0,rise,0],a+rightA*Float(c.halfWidth),a-rightA*Float(c.halfWidth))}
                if stair {deck.quad(a-rightA*Float(c.halfWidth),a+rightA*Float(c.halfWidth),a+rightA*Float(c.halfWidth)+[0,y-a.y,0],a-rightA*Float(c.halfWidth)+[0,y-a.y,0])}
            }
            for (g,color,role) in [(light,UIColor(hex:p.track_light),"light"),(dark,UIColor(hex:p.track_dark),"dark"),(rim,UIColor(hex:p.accent_b),"rim"),(deck,UIColor(hex:p.fog),"deck")] where !g.positions.isEmpty {
                if let mesh=try? g.resource() {
                    var material=factory.material(color,style:11)
                    if role == "light" || role == "dark" {material.blending = .transparent(opacity:.init(floatLiteral:1));material.faceCulling = .none;material.roughness=0.28;material.metallic=0.04}
                    let model=ModelEntity(mesh:mesh,materials:[material]);model.name="palette:\(role)";root.addChild(model)
                }
            }
            if let drop=c.drop {
                for s in [drop.departure-1,drop.departure-0.6] { var g=Geometry(); let pos=local(generator.sample(s),origin:origin); g.box(pos+[0,0.05,0],[4.2,0.05,0.1]); if let mesh=try? g.resource() { root.addChild(ModelEntity(mesh:mesh,materials:[UnlitMaterial(color:.white)])) } }
                let landing=factory.build(.platform,palette:palette,lod:1); landing.scale=[1.25,1,0.18]; landing.position=local(generator.sample(drop.landing+2),origin:origin); root.addChild(landing)
            }
            terrainDecorations(c,root:root,generator:generator,origin:origin,palette:p)
            chunks[c.id]=root; world.addChild(root);evolution.register(root,palette:palette,palettes:surfacePalettes,art:art)
        }
        for c in run.chunks {
            let stormFooting=run.hazards.contains{$0.encounter == .lightning && $0.distance >= c.start-3 && $0.distance <= c.end+3}
            let critical=stormFooting || c.gap != nil || c.step != nil || c.drop != nil || [.stairsStraight,.stairsSpiral].contains(c.routeFamily)
            let alpha=TrackTranslucency.opacity(identity:run.identity,distance:run.distance,seconds:run.seconds,visual:run.visual,transitions:run.mirrorCount+run.dropCount,ahead:c.start-run.distance,critical:critical)
            if abs((trackAlphas[c.id] ?? -1)-alpha.base)>0.012,let root=chunks[c.id] {
                root.findEntity(named:"palette:dark")?.components.set(OpacityComponent(opacity:alpha.base))
                root.findEntity(named:"palette:light")?.components.set(OpacityComponent(opacity:alpha.pattern))
                trackAlphas[c.id]=alpha.base
            }
        }
        animateTerrain(run)
        PerformanceTrace.measure("DistantPath") {distantPath.update(run:run,origin:origin,palette:surfacePalettes[palette],world:world)}
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
                } else {e=obstacleModel(h) ?? factory.build(h.asset,palette:palette,lod:0)}
                if h.pig?.clover == true { let clover=factory.build(.clover,palette:palette); clover.scale=[0.45,0.45,0.45]; clover.position=[0,0.7,0]; e.addChild(clover) }
                world.addChild(e); hazards[h.id]=e
                if ![AssetID.soccer,.eightBall,.softball,.americanFootball,.zebra,.nazar,.rabbit,.pig].contains(h.asset) && h.encounter != .lightning {
                    coordinatePalette(e,definition:surfacePalettes[palette])
                    evolution.register(e,palette:palette,palettes:surfacePalettes,art:art,allSurfaces:true)
                }
            }
            let routeSample=generator.sample(h.position(at:run.activeTicks))
            e.position=local(routeSample,origin:origin,lateral:h.lateral(at:run.activeTicks))+[0,Float(run.floorHeight(at:h.position(at:run.activeTicks))),0]
            e.orientation=simd_quatf(angle:-Float(routeSample.yaw),axis:[0,1,0])

            animateObstacle(e,h:h,run:run)
            if let pivot=e.findEntity(named:"rolling-ball") {pivot.orientation=simd_quatf(angle:Float(h.rollAngle(at:run.activeTicks)),axis:[1,0,0])}
            e.isEnabled=h.hasStartedMoving(at:run.activeTicks) && run.pigs.count < 3 && (h.pig != nil || h.encounter == .mirror || h.position(at:run.activeTicks) >= run.safeUntilDistance)
        }
        let available=run.chunks.flatMap(\.pickups).filter { !run.collectedIDs.contains($0.id) }
        let ids=Set(available.map(\.id))
        for (id,e) in pickups where !ids.contains(id) {
            if run.collectedIDs.contains(id) && !id.hasPrefix("straw:") {balloonPops.spawn(at:e.position,world:world,tick:run.activeTicks)}
            e.removeFromParent();pickups.removeValue(forKey:id)
        }
        for p in available {
            let e:Entity
            if let existing=pickups[p.id] {e=existing} else {
                e=p.kind == .straw ? strawBall():factory.build(.balloon,palette:palette,style:1,lod:0);world.addChild(e);pickups[p.id]=e
                if p.kind == .balloon {
                    coordinatePalette(e,definition:surfacePalettes[palette],balloon:true)
                    evolution.register(e,palette:palette,palettes:surfacePalettes,art:art,allSurfaces:true)
                }
            }
            let motion=p.balloonPosition(at:run.activeTicks)
            let pickupDistance=p.routeDistance(at:run.activeTicks)
            let center=local(generator.sample(pickupDistance),origin:origin,lateral:motion.lateral)+[0,Float(motion.height+run.floorHeight(at:pickupDistance)),0]
            // Rotate around the balloon body, so its collision center stays on the shared trajectory.
            let rotation=simd_quatf(angle:Float(motion.roll),axis:p.kind == .straw ? [1,0,0]:[0,0,1])
            e.orientation=rotation;e.position=p.kind == .straw ? center:center-rotation.act([0,0.65,0])
        }
        balloonPops.update(tick:run.activeTicks)
        let position=local(generator.sample(visualDistance),origin:origin,lateral:run.player.lateral)
        runner.position=position+[0,Float(run.player.height+run.floorHeight(at:visualDistance)),0]; runner.isEnabled=true
        if run.cause == "fell from edge" {runner.position.y -= Float(min(1.25,run.endingElapsed)*5)}
        let slide=run.player.slideTicks > 0, faint=run.pigs.count == 3 && run.endingElapsed > 51
        let stumble=cinematic ? Float(0) : Float(run.stumbleWeight)
        let stumbleAge=Float(1-run.stumbleWeight)
        let heading=simd_quatf(angle:-Float(generator.sample(visualDistance).yaw),axis:[0,1,0])
        let jumping=run.player.height>0.05 && !slide
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
            let legAngle:Float=slide ? 0.1 : jumping ? (i == 0 ? -0.65:-0.3) : activeGait ? stride*0.95*(1-stumble)+(i == 0 ? -0.5 : 0.3)*stumble : 0
            let kneeAngle:Float=slide ? -0.12 : jumping ? -0.8 : activeGait ? -(0.2+max(0,-stride)*1.2)*(1-stumble)-0.35*stumble : 0
            let armAngle:Float=slide ? 0 : jumping ? -0.85 : activeGait ? -stride*0.75*(1-stumble)-0.9*stumble : 0
            legs[i].orientation=simd_quatf(angle:legAngle,axis:[1,0,0])
            knees[i].orientation=simd_quatf(angle:kneeAngle,axis:[1,0,0])
            arms[i].orientation=simd_quatf(angle:armAngle,axis:[1,0,0])*simd_quatf(angle:(i == 0 ? -1 : 1)*(slide ? 0.08 : 0.45*stumble),axis:[0,0,1])
            elbows[i].orientation=simd_quatf(angle:slide ? 0.15 : activeGait ? 1.35 : 0,axis:[1,0,0])
        }
        updateStrawBody(run)
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
        let drift=menu ? .still : DreamCameraDrift.sample(run:run,reducedMotion:art.collage.reducedMotion)
        let direction=simd_normalize(target-cameraPosition)
        let side=simd_normalize(simd_cross(direction,SIMD3<Float>(0,1,0)))
        let translation=side*drift.side+SIMD3<Float>(0,drift.height,0)
        camera.look(at:target+translation+side*drift.aim,from:cameraPosition+translation,relativeTo:nil)
        camera.orientation=camera.orientation*simd_quatf(angle:drift.roll,axis:[0,0,1])
        art.collage.update(run:run,origin:origin,world:world,camera:camera,aspect:Float(view.bounds.width/max(1,view.bounds.height)),lowPower:lowPower,voidWeight:evolution.voidWeight(seconds:run.seconds))
        if !cinematic {
            evolution.update(seconds:run.seconds,palettes:surfacePalettes,art:art)
        }
        func count(_ entity:Entity)->Int {1+entity.children.reduce(0){$0+count($1)}}
        // Diagnostic traversal is not animation. Sample once per second in Lab
        // and telemetry, without walking the whole scene on every normal frame.
        #if DEBUG
        let now=ProcessInfo.processInfo.systemUptime
        if now-lastEntityCountTime >= 1 {renderEntities=count(anchor);lastEntityCountTime=now}
        #endif
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
    func rotateWardrobe(to angle:Float) {
        runner.orientation=simd_quatf(angle:angle,axis:[0,1,0])
    }
    func previewAvatar(equipped:[String:String],wardrobe:Bool = false,rotation:Float = 0) {
        wardrobeLight.isEnabled=true;wardrobeFill.isEnabled=wardrobe;wardrobeHalo.isEnabled=wardrobe
        art.invalidateEnvironment()
        world.children.removeAll();chunks.removeAll();hazards.removeAll();pickups.removeAll();lastRun=nil
        runner.isEnabled=true;runner.position = .zero;rotateWardrobe(to:rotation);dress(equipped)
        for e in legs+arms+knees+elbows {e.orientation=simd_quatf(angle:0,axis:[1,0,0])}
        camera.look(at:wardrobe ? [0,-0.9,0] : [0,1,0],from:wardrobe ? [0,-0.3,-6.7] : [1.4,1.5,-3.3],relativeTo:nil)
        view.environment.background = .color(UIColor(hex:"#777288"))
    }
    func preview(_ id:AssetID,palette:Int,style:Int,lod:Int,colliders:Bool = false) {
        wardrobeLight.isEnabled=false;wardrobeFill.isEnabled=false;wardrobeHalo.isEnabled=false
        art.invalidateEnvironment()
        world.children.removeAll(); chunks.removeAll(); terrainKeys.removeAll();trackAlphas.removeAll(); hazards.removeAll(); pickups.removeAll(); gallery=nil; runner.isEnabled=false; lastRun=nil
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
