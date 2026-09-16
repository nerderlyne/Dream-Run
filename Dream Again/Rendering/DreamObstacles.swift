import RealityKit
import UIKit
import simd

extension DreamRenderer {
    /// Keep material finish and geometry, but share the traversal palette and its gradual evolution.
    func coordinatePalette(_ root:Entity,definition p:PaletteDefinition,balloon:Bool=false) {
        var ordinal=0
        func visit(_ e:Entity) {
            if let model=e as? ModelEntity,let materials=model.model?.materials as? [PhysicallyBasedMaterial] {
                model.model?.materials=materials.map { original in
                    var m=original
                    let roles=balloon ? [p.accent_a,p.track_light]:[p.track_dark,p.track_light,p.accent_b,p.track_dark]
                    m.baseColor.tint=UIColor(hex:roles[ordinal % roles.count]);ordinal += 1
                    return m
                }
            }
            for child in e.children {visit(child)}
        }
        visit(root)
    }
    /// Interactive art is authored to the same dimensions as its route-space collision contract.
    func obstacleModel(_ h:HazardDescription)->Entity? {
        guard h.encounter == .lightning || h.encounter == .swing || h.encounter == .step || h.requiresJump || h.asset == .window && h.encounter == .slide else{return nil}
        let root=Entity();root.name="encounter:\(h.encounter.rawValue)"
        func add(_ geometry:Geometry,_ color:String,_ name:String,_ unlit:Bool=false,style:Int=11) {
            if let mesh=try? geometry.resource() {
                let material:any Material=unlit ? UnlitMaterial(color:UIColor(hex:color)):factory.material(UIColor(hex:color),style:style)
                let e=ModelEntity(mesh:mesh,materials:[material]);e.name=name;root.addChild(e)
            }
        }
        if h.encounter == .step {return root} // The raised staircase is the actual chunk surface.
        if h.encounter == .lightning {
            var warning=Geometry(),bolt=Geometry(),rain=Geometry()
            // Broken, dim ground fissures preserve a dodge cue without a target-circle graphic.
            for i in 0..<5 {
                let a=Float(i)*1.256
                warning.tube([[cos(a)*0.2,0.045,sin(a)*0.2],[cos(a+0.12)*0.44,0.045,sin(a+0.12)*0.44],[cos(a)*0.64,0.045,sin(a)*0.64]],radius:0.012,segments:5)
            }
            add(warning,"#B8C3D5","strike-warning",true)
            bolt.tube([[0,7,0],[0.2,5.8,0],[-0.35,4.9,0],[0.23,3.8,0],[-0.16,2.5,0],[0.22,1.4,0],[0,0.04,0]],radius:0.045,segments:6)
            bolt.tube([[0.23,3.8,0],[0.9,3.2,0],[1.15,2.4,0]],radius:0.02,segments:5)
            add(bolt,"#EEE5FF","lightning-bolt",true)
            root.addChild(storm.cloud())
            for i in 0..<90 {
                let x=Float(sin(Double(i)*2.399))*2.8,z=Float(cos(Double(i)*4.13))*1.6,y=Float(i%13)*0.34+0.8
                rain.tube([[x,y,z],[x-0.08,y-0.5,z]],radius:0.006,segments:3)
            }
            add(rain,"#8A9AAE","storm-rain",true)
            // Opaque, irregular char rather than translucent concentric target rings.
            var char=Geometry(),embers=Geometry(),charge=Geometry()
            for i in 0..<32 {
                func point(_ n:Int)->SIMD3<Float> {
                    let a=Float(n%32)/32*2*Float.pi,r:Float=1.05+0.22*sin(Float(n%32)*7.3)
                    return [max(-1.88-Float(h.lateral),min(1.88-Float(h.lateral),cos(a)*r)),0.035,sin(a)*r*1.4]
                }
                char.triangle([0,0.035,0],point(i+1),point(i))
            }
            add(char,"#201D25","storm-char",style:0)
            for i in 0..<7 {
                let x=Float(i-3)*0.16
                embers.tube([[x,0.047,-0.65],[x+0.16,0.047,-0.2],[x-0.08,0.047,0.25]],radius:0.012,segments:3)
            }
            add(embers,"#A96149","storm-embers",true)
            for i in 0..<5 {
                let x=Float(i-2)*1.2,y:Float=6+Float(i%2)*0.5
                charge.tube([[x-0.6,y,0.15],[x-0.2,y+0.3,0.16],[x+0.1,y-0.1,0.15],[x+0.6,y+0.2,0.16]],radius:0.025,segments:4)
            }
            add(charge,"#B9CBFF","storm-charge",true)
            let flash=PointLight();flash.name="storm-flash";flash.position=[0,3,0];flash.light.color=UIColor(hex:"#CADFFF");flash.light.attenuationRadius=12;flash.light.intensity=0;root.addChild(flash)
        } else if h.encounter == .swing {
            var head=Geometry(),spikes=Geometry(),chain=Geometry(),collar=Geometry()
            let center=SIMD3<Float>(0,0.85,0)
            head.ellipsoid(center,[0.235,0.235,0.235],segments:32,rings:20)
            for i in 0..<14 {
                let y=1-2*(Float(i)+0.5)/14,a=Float(i)*2.399963
                let direction=SIMD3<Float>(sqrt(1-y*y)*cos(a),y,sqrt(1-y*y)*sin(a))
                let right=simd_normalize(simd_cross(direction,abs(y)>0.9 ? SIMD3<Float>(1,0,0):SIMD3<Float>(0,1,0)))
                let up=simd_cross(direction,right),base=center+direction*0.195,tip=center+direction*0.38
                for j in 0..<12 {
                    let t=Float(j)/12*2*Float.pi,u=Float(j+1)/12*2*Float.pi
                    spikes.triangle(base+(right*cos(t)+up*sin(t))*0.085,base+(right*cos(u)+up*sin(u))*0.085,tip)
                }
            }
            collar.tube((0...24).map {i in let a=Float(i)/24*2*Float.pi;return center+[cos(a)*0.24,0,sin(a)*0.24]},radius:0.025,segments:8)
            for i in 0..<20 {
                let y=Float(i)/20
                chain.tube((0...12).map {j in
                    let a=Float(j)/12*2*Float.pi
                    return i%2 == 0 ? [cos(a)*0.044,y+sin(a)*0.026,0]:[0,y+sin(a)*0.026,cos(a)*0.044]
                },radius:0.012,segments:6)
            }
            add(head,"#B90825","mace-latex-head",style:1)
            add(spikes,"#E31335","mace-spikes",style:1)
            add(collar,"#410616","mace-collar",style:2)
            add(chain,"#30212A","mace-chain",style:2)
        } else if h.asset == .window {
            var frame=Geometry(),bars=Geometry(),hardware=Geometry(),lock=Geometry()
            for x:Float in [-2.05,2.05] {frame.box([x,1.72,0],[0.16,1.74,0.24])}
            for y:Float in [0.95,2.5] {frame.box([0,y,0],[4.25,0.2,0.24])}
            for i in -6...6 {let x=Float(i)*0.3;bars.tube([[x,1.05,0],[x,2.4,0]],radius:0.038,segments:12)}
            for y:Float in [1.42,2.12] {frame.box([0,y,0],[4,0.065,0.13])}
            lock.box([0.65,1.73,0.1],[0.27,0.3,0.08])
            hardware.ellipsoid([0.65,1.76,0.15],[0.035,0.035,0.012],segments:12,rings:8)
            hardware.box([0.65,1.71,0.15],[0.025,0.065,0.024])
            for x:Float in [-2.05,2.05] {for y:Float in [1.18,2.22] {
                lock.box([x,y,0.08],[0.23,0.2,0.15])
                hardware.ellipsoid([x,y,0.17],[0.036,0.036,0.018],segments:12,rings:8)
            }}
            add(frame,"#4D535A","jail-door-frame",style:2);add(bars,"#79818B","jail-door-bars",style:2)
            add(lock,"#AF9D72","jail-door-lock",style:2);add(hardware,"#161820","jail-door-hardware")
        } else {
            var furniture=Geometry(),trim=Geometry()
            if h.asset == .bed {furniture.box([0,0.4,0],[4,0.4,1.2])}
            else {for x:Float in [-1.3,0,1.3] {
                furniture.box([x,0.28,0],[1.25,0.16,1.2])
                furniture.box([x,0.47,0.5],[1.25,0.26,0.15])
            }}
            for x:Float in [-1.7,1.7] {for z:Float in [-0.45,0.45] {trim.box([x,0.15,z],[0.13,0.3,0.13])}}
            if h.asset == .bed {trim.ellipsoid([-1.2,0.55,0],[0.45,0.08,0.42],segments:20,rings:10)}
            else {for x:Float in [-1,0,1] {trim.box([x,0.57,0],[0.65,0.06,1.0])}}
            add(furniture,"#C19CAF","sleeping-furniture");add(trim,"#F5E1C7","furniture-detail")
        }
        return root
    }
    func animateObstacle(_ e:Entity,h:HazardDescription,run:RunState) {
        if h.asset == .window && h.encounter == .slide {
            // Descend into the slide position well before the capsule reaches the frame.
            e.position.y += Float(max(0,min(1,(h.distance-run.distance-26)/24)))*3
        }
        if h.encounter == .lightning {
            e.findEntity(named:"lightning-bolt")?.isEnabled=h.striking(at:run.activeTicks)
            let visible=h.strikeTick == UInt64.max || run.activeTicks<h.strikeTick+24
            e.findEntity(named:"strike-warning")?.isEnabled=visible
            e.findEntity(named:"strike-warning")?.components.set(OpacityComponent(opacity:0.28+0.12*Float(sin(run.seconds*4))))
            let t=Float(run.seconds),buzz=pow(max(0,sin(t*17+Float(h.distance.truncatingRemainder(dividingBy:17)))),12)
            let approach=Float(max(0,min(1,(40-(h.distance-run.distance))/30)))
            if let cloud=e.findEntity(named:"storm-cloud") {
                cloud.orientation=camera.orientation(relativeTo:e)*simd_quatf(angle:0.025*sin(t*1.7),axis:[0,0,1])
                cloud.scale=[12*(1+0.045*sin(t*2.1)),8*(1+0.035*cos(t*2.7)),1]
                cloud.position=[0.16*sin(t*1.9),7.3+0.12*sin(t*2.3),0]
                if let scud=cloud.findEntity(named:"storm-scud") {
                    scud.position=[0.055*sin(t*0.9),-0.05+0.02*cos(t*1.4),0.025]
                    scud.scale=[1.04+0.04*cos(t*1.1),0.8+0.06*sin(t*1.3),1]
                    scud.components.set(OpacityComponent(opacity:0.16+0.1*buzz))
                }
            }
            if let charge=e.findEntity(named:"storm-charge") {
                charge.components.set(OpacityComponent(opacity:buzz*(0.35+0.65*approach)))
                charge.scale.x=1+0.08*sin(t*23)
            }
            e.findEntity(named:"storm-embers")?.components.set(OpacityComponent(opacity:h.striking(at:run.activeTicks) ? 0.9:0.18+0.10*buzz))
            if let rain=e.findEntity(named:"storm-rain") {rain.position.y = -Float(run.seconds.truncatingRemainder(dividingBy:0.7))*1.4;rain.components.set(OpacityComponent(opacity:0.25+0.18*approach))}
            (e.findEntity(named:"storm-flash") as? PointLight)?.light.intensity=h.striking(at:run.activeTicks) ? 14000:1200*buzz*approach
        }
        if let ribbon=e.findEntity(named:"mace-chain") {
            let offset=Float(h.lateral(at:run.activeTicks)-h.lateral)
            let direction=SIMD3<Float>(-offset,3.3,0)
            ribbon.position=[0,0.85,0];ribbon.scale=[1,simd_length(direction),1]
            ribbon.orientation=simd_quatf(from:[0,1,0],to:simd_normalize(direction))
        }
    }
    func terrainDecorations(_ c:ChunkDescription,root:Entity,generator:WorldGenerator,origin:RouteSample,palette:PaletteDefinition) {
        if let gap=c.gap {
            var marks=Geometry()
            for distance in [gap.lowerBound-0.4,gap.upperBound+0.4] {
                let sample=generator.sample(distance)
                let center=local(sample,origin:origin),right=SIMD3<Float>(Float(cos(sample.yaw)),0,Float(sin(sample.yaw)))
                for x:Float in [-1.5,-0.5,0.5,1.5] {
                    marks.triangle(center+right*(x-0.18)+[0,0.045,0.2],center+right*(x+0.18)+[0,0.045,0.2],center+right*x+[0,0.045,-0.2])
                }
            }
            if let mesh=try? marks.resource() {let model=ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:palette.accent_b),style:11)]);model.name="palette:rim";root.addChild(model)}
            if c.collapsing {
                let tiles=Entity();tiles.name="collapsing-tiles"
                for n in Int(floor(gap.lowerBound))..<Int(ceil(gap.upperBound)) {
                    var tile=Geometry(),crack=Geometry()
                    let sa=generator.sample(Double(n)),sb=generator.sample(Double(n+1))
                    let a=local(sa,origin:origin),b=local(sb,origin:origin)
                    let ra=SIMD3<Float>(Float(cos(sa.yaw)),0,Float(sin(sa.yaw))),rb=SIMD3<Float>(Float(cos(sb.yaw)),0,Float(sin(sb.yaw)))
                    tile.quad(a-ra*2,a+ra*2,b+rb*2,b-rb*2)
                    crack.tube([a+[-1.9,0.02,-0.3],a+[-0.7,0.02,-0.7],a+[0.2,0.02,-0.3],a+[1.9,0.02,-0.6]],radius:0.018,segments:4)
                    let holder=Entity();holder.name="tile:\(n)"
                    if let mesh=try? tile.resource() {let model=ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:n%2 == 0 ? palette.track_light:palette.track_dark),style:11)]);model.name=n%2 == 0 ? "palette:light":"palette:dark";holder.addChild(model)}
                    if let mesh=try? crack.resource() {holder.addChild(ModelEntity(mesh:mesh,materials:[UnlitMaterial(color:UIColor(hex:"#302232"))]))}
                    tiles.addChild(holder)
                }
                root.addChild(tiles)
            }
        }
    }
    func animateTerrain(_ run:RunState) {
        for c in run.chunks where c.collapsing {
            guard let start=c.gap?.lowerBound,let tiles=chunks[c.id]?.findEntity(named:"collapsing-tiles") else{continue}
            let progress=max(0,run.distance-(start-7))
            for (i,tile) in tiles.children.enumerated() {
                tile.position.y = -Float(max(0,progress-Double(i)*0.3)*0.7)
                tile.isEnabled=tile.position.y > -12
            }
        }
    }
}
