import RealityKit
import UIKit

/// Tiny bounded burst; no particles, textures or work queued after collection.
@MainActor final class BalloonPopEffects {
    private struct Burst {let entity:Entity;let start:UInt64}
    private var bursts:[Burst]=[]
    var activeCount:Int {bursts.count}
    private lazy var template:Entity = {
        let root=Entity()
        var g=Geometry();g.ellipsoid(.zero,[0.025,0.065,0.012],segments:6,rings:4)
        guard let mesh=try? g.resource() else{return root}
        for i in 0..<7 {
            let e=ModelEntity(mesh:mesh,materials:[UnlitMaterial(color:i%2==0 ? UIColor.white:UIColor.systemPink)])
            root.addChild(e)
        }
        return root
    }()
    func reset() {for b in bursts {b.entity.removeFromParent()};bursts.removeAll()}
    func spawn(at position:SIMD3<Float>,world:Entity,tick:UInt64) {
        if bursts.count>=12 {bursts.removeFirst().entity.removeFromParent()}
        let e=template.clone(recursive:true);e.position=position+[0,0.65,0];world.addChild(e)
        bursts.append(.init(entity:e,start:tick))
    }
    func update(tick:UInt64) {
        for b in bursts {
            let age=Float(tick>=b.start ? tick-b.start:0)/60,p=min(1,age/0.4)
            for (i,e) in b.entity.children.enumerated() {
                let a=Float(i)*2*Float.pi/7
                e.position=[cos(a)*(0.1+p*0.45),sin(a)*(0.1+p*0.45)+p*0.16,0]
                e.orientation=simd_quatf(angle:a+p*2,axis:[0,0,1]);e.scale = .init(repeating:1-p*0.7)
            }
            b.entity.components.set(OpacityComponent(opacity:1-p))
        }
        bursts.removeAll {b in if tick<b.start || tick-b.start>=24 {b.entity.removeFromParent();return true};return false}
    }
}
