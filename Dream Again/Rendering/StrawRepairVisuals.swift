import RealityKit
import UIKit
import simd

/// Bounded avatar fragments, shared mesh; repair bales are bundled humanoid straw, not scenery.
@MainActor final class StrawBurstEffects {
    private struct Burst {let root:Entity;let start:Double;let repair:Bool;let large:Bool}
    private var bursts:[Burst]=[]
    private lazy var mesh:MeshResource = .generateBox(size:[0.012,0.19,0.012])
    func reset() {for b in bursts {b.root.removeFromParent()};bursts=[]}
    func spawn(at point:SIMD3<Float>,world:Entity,time:Double,repair:Bool,large:Bool=false) {
        if bursts.count>=5 {bursts.removeFirst().root.removeFromParent()}
        let root=Entity();root.name="straw-fragments";root.position=point;world.addChild(root)
        for i in 0..<(large ? 48:20) {
            root.addChild(ModelEntity(mesh:mesh,materials:[SimpleMaterial(color:UIColor(hex:i%2 == 0 ? "#D8B97B":"#947342"),roughness:0.9,isMetallic:false)]))
        }
        bursts.append(.init(root:root,start:time,repair:repair,large:large))
    }
    func update(time:Double) {
        for b in bursts {
            let p=Float(max(0,min(1,(time-b.start)/(b.large ? 2.2:0.75)))),f=b.repair ? 1-p:p
            for (i,e) in b.root.children.enumerated() {
                let a=Float(i)*2.39996,r:Float=(b.large ? 2.2:0.75)*f
                e.position=[cos(a)*r,(0.3+Float(i%7)*0.2)*f+(b.large ? f*1.5:0),sin(a)*r]
                e.orientation=simd_quatf(angle:a+f*9,axis:simd_normalize(SIMD3<Float>(1,Float(i%3),0.5)))
            }
            b.root.components.set(OpacityComponent(opacity:1-p*p))
        }
        bursts.removeAll {b in if time-b.start>(b.large ? 2.2:0.75) || time<b.start {b.root.removeFromParent();return true};return false}
    }
}

extension DreamRenderer {
    func strawBale()->Entity {
        let root=Entity();root.name="straw-repair-bale"
        var hay=Geometry(),fibres=Geometry(),twine=Geometry()
        hay.box([0,0.65,0],[0.55,0.42,0.4])
        for i in 0..<22 {
            let x=Float(i)/21*0.52-0.26
            fibres.tube([[x,0.44,0.207],[x+0.008*sin(Float(i)),0.66,0.215],[x,0.86,0.207]],radius:0.006,segments:4)
        }
        for x:Float in [-0.16,0.16] {
            twine.tube([[x,0.43,-0.21],[x,0.87,-0.21],[x,0.87,0.22],[x,0.43,0.22],[x,0.43,-0.21]],radius:0.018,segments:5)
        }
        for (g,color) in [(hay,"#B89554"),(fibres,"#E8D099"),(twine,"#685238")] {
            if let mesh=try? g.resource() {root.addChild(ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:color),style:10)]))}
        }
        return root
    }
    func updateStrawBody(_ run:RunState) {
        let missing=run.player.missingLimbs,time=run.seconds+run.endingElapsed
        if missing != lastStrawState {
            let repair=missing.count<lastStrawState.count
            strawBursts.spawn(at:runner.position+[0,1.1,0],world:world,time:time,repair:repair,large:missing.count == 4)
            lastStrawState=missing
        }
        for i in 0..<2 {
            arms[i].isEnabled = !missing.contains(i == 0 ? .leftArm:.rightArm)
            legs[i].isEnabled = !missing.contains(i == 0 ? .leftLeg:.rightLeg)
        }
        if missing.count == 3 && run.phase == .running {runner.position.y += Float(abs(sin(run.seconds*13)))*0.1}
        let unravel=run.cause == "unravelled" && [.waking,.finished].contains(run.phase)
        runner.components.set(OpacityComponent(opacity:unravel ? Float(max(0,1-run.endingElapsed/0.45)):1))
        if unravel {runner.position.y += Float(run.endingElapsed)*0.4}
        strawBursts.update(time:time)
    }
}
