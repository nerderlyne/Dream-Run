import RealityKit
import UIKit
import simd

/// Presentation only. Does not consume gameplay RNG or add collision/reward objects.
/// Every placed world object uses an existing AssetID; the sky is an environment material.
@MainActor final class DreamArtDirection {
    private var appliedEnvironment:String?
    private(set) var environmentApplications=0
    func invalidateEnvironment() {appliedEnvironment=nil}
    private var skyCache:[Int:EnvironmentResource]=[:]
    let skyDome=ModelEntity(mesh:.generateSphere(radius:6000),materials:[UnlitMaterial(color:.white)])
    private var skyTextures:[Int:TextureResource]=[:]
    let cloudBanks=CloudBank()
    let horizon=Entity()
    private var horizonKey=""
    private var hazeOriginals:[ObjectIdentifier:[PhysicallyBasedMaterial]]=[:]
    private var lastHazePosition=SIMD3<Float>(repeating:Float.greatestFiniteMagnitude)
    func resetHaze() {horizonKey="";hazeQueue.removeAll();hazeCursor=0;hazeCenters.removeAll();hazeAmounts.removeAll();hazeOriginals.removeAll();lastHazePosition=SIMD3(repeating:Float.greatestFiniteMagnitude)}
    private var hazeQueue:[ModelEntity]=[]
    private var hazeCursor=0
    private var hazeCenters:[ObjectIdentifier:SIMD3<Float>]=[:]
    private var hazeAmounts:[ObjectIdentifier:Float]=[:]
    func haze(_ world:Entity,camera:SIMD3<Float>,color:UIColor) {
        if hazeCursor >= hazeQueue.count {
            guard simd_distance(camera,lastHazePosition)>2 else{return}
            lastHazePosition=camera;hazeQueue.removeAll(keepingCapacity:true);hazeCursor=0
            func collect(_ e:Entity,scenery:Bool) {
                let enabled=scenery || e.name == "scenery"
                if enabled,e.name != "atmosphere-cloud",let model=e as? ModelEntity {hazeQueue.append(model)}
                for child in e.children {collect(child,scenery:enabled)}
            }
            collect(world,scenery:false)
            let live=Set(hazeQueue.map{ObjectIdentifier($0)})
            hazeOriginals=hazeOriginals.filter{live.contains($0.key)}
            hazeCenters=hazeCenters.filter{live.contains($0.key)}
            hazeAmounts=hazeAmounts.filter{live.contains($0.key)}
        }
        // Bound CPU/material work per frame instead of updating the entire landscape in a burst.
        for _ in 0..<4 where hazeCursor < hazeQueue.count {
            let model=hazeQueue[hazeCursor];hazeCursor += 1
            guard model.parent != nil,let component=model.model else {continue}
            let key=ObjectIdentifier(model)
            if hazeOriginals[key] == nil {hazeOriginals[key]=component.materials.compactMap{$0 as? PhysicallyBasedMaterial}}
            guard let original=hazeOriginals[key],!original.isEmpty else {continue}
            if hazeCenters[key] == nil {hazeCenters[key]=model.visualBounds(relativeTo:model).center}
            let center=model.convert(position:hazeCenters[key]!,to:nil)
            let distance=simd_distance(center,camera)
            let t=max(0,min(0.88,1-exp(-max(0,distance-35)/155)))
            if let previous=hazeAmounts[key],abs(previous-t)<0.015 {continue}
            hazeAmounts[key]=t
            var fr:CGFloat=0,fg:CGFloat=0,fb:CGFloat=0,a:CGFloat=0
            color.artSRGB.getRed(&fr,green:&fg,blue:&fb,alpha:&a)
            model.model?.materials=original.map {base in
                var m=base
                m.emissiveColor = .init(color:color);m.emissiveIntensity=t*0.5
                m.metallic.scale *= 1-t;m.roughness.scale += (1-m.roughness.scale)*t
                var r:CGFloat=0,g:CGFloat=0,b:CGFloat=0
                base.baseColor.tint.artSRGB.getRed(&r,green:&g,blue:&b,alpha:&a)
                let f=CGFloat(t)
                m.baseColor.tint=UIColor(red:r*(1-f)+fr*f,green:g*(1-f)+fg*f,blue:b*(1-f)+fb*f,alpha:1)
                return m
            }
        }
    }
    func environment(palette:Int,definition:PaletteDefinition,view:ARView,enabled:Bool) {
        let key="\(palette)/\(enabled)"
        guard appliedEnvironment != key else {return}
        appliedEnvironment=key;environmentApplications += 1
        skyDome.isEnabled=enabled && palette != 5
        guard enabled && palette != 5 else {view.environment.background = .color(UIColor(hex:definition.sky));return}
        if let cached=skyCache[palette] {view.environment.background = .skybox(cached);view.environment.lighting.resource=cached;applySkyTexture(palette);return}
            let format=UIGraphicsImageRendererFormat();format.scale=1
            let image=UIGraphicsImageRenderer(size:CGSize(width:1024,height:512),format:format).image { ctx in
                let c=ctx.cgContext,night=[2,4].contains(palette)
                let colors=[UIColor(hex:definition.sky).cgColor,UIColor(hex:definition.sky).cgColor,UIColor(hex:definition.fog).cgColor,UIColor(hex:definition.sky).cgColor,UIColor(hex:definition.sky).cgColor] as CFArray
                if let g=CGGradient(colorsSpace:CGColorSpaceCreateDeviceRGB(),colors:colors,locations:[0,0.2,0.5,0.8,1]) {c.drawLinearGradient(g,start:.zero,end:CGPoint(x:0,y:512),options:[])}
                // Layered banks of luminous cloud, painted procedurally into the environment.
                // Long-distance cloud light is baked; nearby cloud geometry receives scene light.
                for group in 0..<36 {
                    let gx=Double((group*197)%1024),gy=Double(90+(group*43)%270)
                    for lobe in 0..<18 {
                        let phase=Double(group*71+lobe*47),x=gx+sin(phase)*55,y=gy+cos(phase*0.79)*14
                        let r=Double(12+(group*7+lobe*11)%25)
                        let cream=UIColor(hex:night ? "#ADA2BB" : "#FFF4F0")
                        let shade=UIColor(hex:definition.fog)
                        c.saveGState();c.translateBy(x:x,y:y);c.scaleBy(x:1.7,y:0.75)
                        if let g=CGGradient(colorsSpace:CGColorSpaceCreateDeviceRGB(),colors:[cream.withAlphaComponent(0.48).cgColor,shade.withAlphaComponent(0.2).cgColor,shade.withAlphaComponent(0).cgColor] as CFArray,locations:[0,0.65,1]) {c.drawRadialGradient(g,startCenter:CGPoint(x:-r*0.2,y:-r*0.3),startRadius:0,endCenter:.zero,endRadius:r,options:[])}
                        c.restoreGState()
                    }
                }
                if night {for i in 0..<550 {c.setFillColor(UIColor(white:1,alpha:CGFloat(0.15+Double(i%7)*0.06)).cgColor);c.fillEllipse(in:CGRect(x:Double((i*277)%1024),y:Double((i*113)%230),width:i%9 == 0 ? 1.4 : 0.6,height:i%9 == 0 ? 1.4 : 0.6))}}
            }
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--art-review") {try? image.pngData()?.write(to:URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("sky-\(palette).png"))}
        #endif
        guard let cg=image.cgImage,let environment=try? EnvironmentResource(equirectangular:cg) else{appliedEnvironment=nil;return}
        if skyCache.count>=4 {skyCache.removeAll();skyTextures.removeAll()};skyCache[palette]=environment
        skyTextures[palette]=try? TextureResource.generate(from:cg,options:.init(semantic:.color));applySkyTexture(palette)
        view.environment.background = .skybox(environment)
        view.environment.lighting.resource=environment;view.environment.lighting.intensityExponent = -0.5
    }
    private func applySkyTexture(_ palette:Int) {
        guard let texture=skyTextures[palette] else{return}
        var material=UnlitMaterial(applyPostProcessToneMap:false);material.color = .init(tint:.white,texture:.init(texture));material.faceCulling = .none
        skyDome.model?.materials=[material]
    }
    func decorate(_ root:Entity,chunk:ChunkDescription,generator:WorldGenerator,origin:RouteSample,palette:Int,factory:PrefabFactory,lowPower:Bool) {
        let p=factory.palettes[palette],id=chunk.id,night=palette == 4 || palette == 5,aqua=palette == 1 || palette == 6
        func point(_ distance:Double,_ lateral:Double,_ y:Float)->SIMD3<Float> {
            let s=generator.sample(distance)
            return [Float(s.x-origin.x+lateral*cos(s.yaw)),Float(s.y-origin.y)+y,Float(s.z-origin.z+lateral*sin(s.yaw))]
        }
        func place(_ family:AssetID,_ offset:Double,_ lateral:Double,_ scale:SIMD3<Float>,_ y:Float=0,_ style:Int=0,_ turn:Float=0) {
            let e=family == .cloud ? cloudBanks.make(tint:UIColor(hex:palette == 0 ? "#F4EFF2" : p.fog)) : factory.build(family,palette:palette,style:style,lod:lowPower ? 2 : 1)
            let bounds=e.visualBounds(relativeTo:e)
            let radius=Double(max(bounds.extents.x*scale.x,bounds.extents.z*scale.z))/2
            let clearLateral=lateral == 0 ? 0 : (lateral<0 ? -1.0 : 1.0)*max(abs(lateral),radius+9)
            e.name="scenery";e.scale=scale;e.position=point(chunk.start+offset,clearLateral,y)
            e.orientation=simd_quatf(angle:-Float(generator.sample(chunk.start+offset).yaw)+turn,axis:[0,1,0]);root.addChild(e)
        }
        let rhythm=abs(id%8),side:Double=id%3 == 0 ? -1 : 1
        if palette == 5 {
            if rhythm%3 == 0 {place(.tree,17,side*10,[1.1,1.5,1.1],-0.4,9)}
            if rhythm == 6 {place(.horse,12,-14,[1.5,1.5,1.5],-0.5,1)}
            return
        }
        // A continuous water plane gives the route a place in space, below all real gaps.
        var water=Geometry()
        let waterY:Float=aqua ? -4.5 : -16
        let a=point(chunk.start,-100,waterY),b=point(chunk.start+24,-100,waterY),c=point(chunk.start+24,100,waterY),d=point(chunk.start,100,waterY)
        water.quad(a,d,c,b)
        if let mesh=try? water.resource() {let e=ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:aqua ? p.accent_b : p.fog),style:8)]);e.name="scenery";root.addChild(e)}
        if !aqua {
            place(.cloud,12,side*(30+Double(rhythm)*3),[14,11,10],-3,0)
            if rhythm%3 == 1 && !lowPower {place(.cloud,19,-side*70,[24,16,18],-5,0)}
        }
        if aqua {
            if rhythm == 0 || rhythm == 3 {place(.roomShell,15,side*25,[2.5,2.3,2.5],-4.5,0)}
            if rhythm%2 == 0 {place(.column,7,-side*9,[1.5,2.5,1.5],-4.5,6)}
            if rhythm == 5 {place(.rock,9,8,[4,2,3],-3.5,6)}
        } else {
            if rhythm == 0 {place(.window,18,-19,[4,4.8,4],-4,4)}
            if rhythm == 4 {place(.window,18,0,[3,3.5,3],-0.2,4)}
            if rhythm == 2 || rhythm == 5 {place(.tree,14,side*10,[1.15,1.45,1.15],-1,0)}
            if rhythm == 6 {place(.rabbit,14,-5,[1.5,1.5,1.5],0,3)}
        }
        // One isolated architectural landmark per 192 m, supported by surrounding cloud/water.
        if rhythm == 7 {
            place(night ? .moon : .stairsSpiral,20,side*50,night ? [9,9,9] : [1.8,2.8,1.8],night ? 26 : -4,4,0.4)
        }
    }
}

extension DreamArtDirection {
    /// Landscape layer beyond the collision stream. Bounded and separately cached.
    /// No extra world families, gameplay draws, spawn decisions, or collision entities.
    func landscape(run:RunState,origin:RouteSample,palette:Int,factory:PrefabFactory,world:Entity,lowPower:Bool) {
        let section=Int(run.distance/192),p=factory.palettes[palette]
        let key="\(run.id)/\(section)/\(palette)/\(run.visual)/\(lowPower)"
        if horizon.parent == nil {world.addChild(horizon)}
        if key != horizonKey {
            horizon.children.removeAll();horizonKey=key
            let generator=WorldGenerator(run.identity)
            // Different seeds compose different landscape rhythms; this local stream never
            // touches the simulation's route, hazard, pickup, or pig streams.
            var rng=run.identity.stream("landscape-art-v1",section)
            let count=lowPower ? 14 : 26
            for i in 0..<count {
                let layer=i%3,depth=Double(160+layer*210)+Double(rng.below(190))
                let sample=generator.sample(Double(section)*192+depth)
                let sign:Float=i%2 == 0 ? -1 : 1
                let family:AssetID
                if palette == 5 {family=i%3 == 0 ? .tree : .moon}
                else if palette == 1 || palette == 6 {family=i%5 == 0 ? .window : i%3 == 0 ? .roomShell : i%3 == 1 ? .column : .cloud}
                else if palette == 4 {family=i%3 == 0 ? .mountain : i%3 == 1 ? .moon : .cloud}
                else {family=i%4 == 0 ? .window : i%4 == 1 ? .stairsSpiral : .cloud}
                let scale:Float=family == .cloud ? Float(24+layer*18) : family == .window ? Float(8+layer*5) : family == .stairsSpiral ? Float(3+layer*2) : Float(8+layer*7)
                let e=family == .cloud ? cloudBanks.make(tint:UIColor(hex:palette == 0 ? "#F4EFF2" : p.fog)) : factory.build(family,palette:palette,style:family == .cloud ? 0 : layer == 1 ? 4 : 6,lod:lowPower ? 2 : 1)
                e.name="scenery";e.scale=SIMD3(repeating:scale)
                let lateral=sign*(Float(depth)*0.16+Float(rng.below(25)))
                e.position=[Float(sample.x-origin.x)+lateral,Float(sample.y-origin.y)+(family == .cloud ? Float(depth)*0.22+Float(rng.below(25)) : Float(depth)*0.1),Float(sample.z-origin.z)]
                if family != .cloud {e.orientation=simd_quatf(angle:Float(rng.below(30))/100-0.15,axis:[0,1,0])}
                horizon.addChild(e)
            }
        }
        // Density breathes, then follows the locked nonterminal three-hour transformation.
        let cycle=run.seconds.truncatingRemainder(dividingBy:10800)
        let density:Double
        switch run.visual {
        case .deepStripping: density=max(0,(1-cycle/240))
        case .deepSparse: density=0.04
        case .deepRebuilding: density=min(1,max(0,(cycle-300)/300))
        default: density=palette == 5 ? 0.08 : 0.68+0.32*cos(run.seconds/190)
        }
        for (i,e) in horizon.children.enumerated() {e.isEnabled=Double(i)/Double(max(1,horizon.children.count)) < density && run.pigs.count < 3}
    }
}
