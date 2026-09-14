import RealityKit
import UIKit
import simd

extension DreamRenderer {
    /// Interactive art is authored to the same dimensions as its route-space collision contract.
    func obstacleModel(_ h:HazardDescription)->Entity? {
        guard h.encounter == .lightning || h.encounter == .swing || h.encounter == .step || h.requiresJump || h.asset == .window && h.encounter == .slide else{return nil}
        let root=Entity();root.name="encounter:\(h.encounter.rawValue)"
        func add(_ geometry:Geometry,_ color:String,_ name:String,_ unlit:Bool=false) {
            if let mesh=try? geometry.resource() {
                let material:any Material=unlit ? UnlitMaterial(color:UIColor(hex:color)):factory.material(UIColor(hex:color),style:11)
                let e=ModelEntity(mesh:mesh,materials:[material]);e.name=name;root.addChild(e)
            }
        }
        if h.encounter == .step {return root} // The raised staircase is the actual chunk surface.
        if h.encounter == .lightning {
            var ring=Geometry(),dark=Geometry(),bolt=Geometry()
            let points=(0...48).map {i in let a=Float(i)/48*2*Float.pi;return SIMD3<Float>(cos(a)*0.65,0.035,sin(a)*0.65)}
            dark.tube(points,radius:0.06,segments:5);ring.tube(points.map{$0+[0,0.08,0]},radius:0.035,segments:5)
            add(dark,"#282039","strike-outline",true);add(ring,"#FFF1AE","strike-warning",true)
            bolt.tube([[0,7,0],[0.2,5.8,0],[-0.35,4.9,0],[0.23,3.8,0],[-0.16,2.5,0],[0.22,1.4,0],[0,0.04,0]],radius:0.055,segments:6)
            bolt.tube([[0.23,3.8,0],[0.9,3.2,0],[1.15,2.4,0]],radius:0.025,segments:5)
            add(bolt,"#EEE5FF","lightning-bolt",true)
            let cloud=factory.build(.cloud,palette:0,lod:2);cloud.scale=[1.1,1.4,1];cloud.position=[0,7,0]
            for child in cloud.children {if let model=child as? ModelEntity {model.model?.materials=[factory.material(UIColor(hex:"#898599"),style:0)]}}
            root.addChild(cloud)
        } else if h.encounter == .swing {
            var moon=Geometry(),tether=Geometry(),craters=Geometry()
            moon.ellipsoid([0,0.85,0],[0.38,0.38,0.38],segments:32,rings:20)
            for i in 0..<5 {let a=Float(i)*2.1;craters.ellipsoid([cos(a)*0.2,0.85+sin(a)*0.2,0.32],[0.065,0.05,0.035],segments:12,rings:8)}
            add(craters,"#B2A990","moon-craters")
            tether.tube([[0,0,0],[0,1,0]],radius:0.025,segments:6)
            add(moon,"#FFF0BC","swing-moon");add(tether,"#CBB29A","moon-ribbon")
        } else if h.asset == .window {
            var frame=Geometry(),trim=Geometry()
            for x:Float in [-2.05,2.05] {frame.box([x,1.7,0],[0.16,1.7,0.2])}
            for y:Float in [0.95,2.5] {frame.box([0,y,0],[4.25,0.2,0.2])}
            for x:Float in [-0.65,0.65] {trim.box([x,1.75,0],[0.04,1.3,0.07])}
            add(frame,"#E9B6C8","low-window");add(trim,"#EBCF94","window-trim")
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
            e.findEntity(named:"strike-outline")?.isEnabled=visible
        }
        if let ribbon=e.findEntity(named:"moon-ribbon") {
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
            if let mesh=try? marks.resource() {root.addChild(ModelEntity(mesh:mesh,materials:[UnlitMaterial(color:UIColor(hex:"#F1B665"))]))}
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
                    if let mesh=try? tile.resource() {holder.addChild(ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:n%2 == 0 ? palette.track_light:palette.track_dark),style:11)]))}
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
