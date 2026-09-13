import RealityKit
import UIKit
import simd

extension DreamRenderer {
    /// All dimensions are metres relative to the brow/crown fitting line (1.73 m).
    /// These are wearable meshes, never scaled world prefabs.
    func fittedHat(_ id:String)->Entity {
        let root=Entity();root.name="fitted-\(id)"
        let pearl=UIColor(hex:"#E8DDD0"),ink=UIColor(hex:"#454252"),rose=UIColor(hex:"#BD819A"),gold=UIColor(hex:"#D3B57A")
        func add(_ g:Geometry,_ color:UIColor,_ style:Int=3) {
            if let mesh=try? g.resource() {root.addChild(ModelEntity(mesh:mesh,materials:[factory.material(color,style:style)]))}
        }
        func ring(_ y:Float,_ rx:Float,_ rz:Float,_ radius:Float,_ color:UIColor) {
            var g=Geometry();g.tube((0...64).map {i in let a=Float(i)/64*2*Float.pi;return [cos(a)*rx,y,sin(a)*rz]},radius:radius,segments:12);add(g,color)
        }
        func dome(_ color:UIColor,_ height:Float=0.15) {
            var g=Geometry();g.loft([[-0.025,0.148,0.133,0],[0.025,0.153,0.14,0],[height*0.67,0.13,0.118,0],[height,0.065,0.058,0],[height+0.008,0.001,0.001,0]],segments:64);add(g,color)
            ring(-0.015,0.149,0.134,0.008,color)
        }
        switch id {
        case "paper_hat":
            var g=Geometry();g.loft([[-0.02,0.156,0.135,0],[0.025,0.16,0.135,0],[0.16,0.15,0.008,0],[0.18,0.001,0.001,0]],segments:48);add(g,pearl,0)
            g=Geometry();g.loft([[-0.035,0.165,0.14,0],[0.012,0.165,0.14,0]],segments:48);add(g,pearl,0)
        case "nightcap":
            var g=Geometry();g.loft([[-0.02,0.15,0.135,0],[0.06,0.148,0.13,0],[0.18,0.105,0.09,0.015],[0.25,0.055,0.05,0.055],[0.19,0.008,0.008,0.14]],segments:48);add(g,UIColor(hex:"#A299BD"))
            ring(0,0.15,0.135,0.018,pearl)
            g=Geometry();g.ellipsoid([0,0.185,0.145],[0.035,0.035,0.035]);add(g,pearl)
        case "bucket_hat":
            dome(pearl,0.135)
            var g=Geometry();g.loft([[-0.08,0.23,0.21,0],[-0.045,0.20,0.18,0],[0,0.15,0.14,0]],segments:64);add(g,pearl)
            ring(0.018,0.153,0.141,0.013,rose)
        case "checker_cap":
            // Soft checked beret, no baseball peak.
            dome(ink,0.12)
            var g=Geometry();g.ellipsoid([0.025,0.075,0.008],[0.19,0.085,0.16],segments:48,rings:24);add(g,pearl)
            for i in 0..<16 {let a=Float(i)/16*2*Float.pi;var stitch=Geometry();stitch.tube([[cos(a)*0.16,0.108,sin(a)*0.13],[cos(a)*0.12,0.14,sin(a)*0.10]],radius:0.008);add(stitch,ink)}
            ring(-0.01,0.15,0.135,0.012,ink)
        case "bow":
            ring(0,0.143,0.13,0.012,rose)
            var g=Geometry();g.ellipsoid([-0.065,0.1,0.075],[0.065,0.04,0.025]);g.ellipsoid([0.065,0.1,0.075],[0.065,0.04,0.025]);g.ellipsoid([0,0.1,0.075],[0.022,0.028,0.025]);add(g,rose)
        case "moon_hat","beyond_crown","lucky_pig_hat","balloon_hat":
            ring(0,0.145,0.132,0.014,id == "balloon_hat" ? rose : gold)
            if id == "moon_hat" {
                var g=Geometry();g.tube((0...32).map {i in let a=Float(i)/32*1.55*Float.pi+0.2;return [cos(a)*0.065,0.11+sin(a)*0.065,-0.108]},radius:0.012);add(g,pearl,4)
            } else if id == "beyond_crown" {
                for i in 0..<7 {let a=Float(i)/7*2*Float.pi;var g=Geometry();g.tube([[cos(a)*0.145,0,sin(a)*0.132],[cos(a)*0.15,0.08+(i%2 == 0 ? 0.03 : 0),sin(a)*0.14]],radius:0.008);add(g,gold,2)}
            } else if id == "balloon_hat" {
                var g=Geometry();g.tube([[0.12,0,0],[0.16,0.12,0],[0.13,0.24,0]],radius:0.003);add(g,gold,2)
                g=Geometry();g.ellipsoid([0.13,0.28,0],[0.045,0.06,0.045]);add(g,rose,1)
            } else {
                for x:Float in [-0.085,0,0.085] {
                    var g=Geometry();g.ellipsoid([x,0.048,-0.105],[0.035,0.032,0.023]);g.ellipsoid([x,0.043,-0.128],[0.017,0.012,0.009]);g.ellipsoid([x-0.024,0.077,-0.104],[0.01,0.018,0.007]);g.ellipsoid([x+0.024,0.077,-0.104],[0.01,0.018,0.007]);add(g,rose,1)
                }
                var g=Geometry();for x:Float in [-0.014,0.014] {for y:Float in [0.102,0.126] {g.ellipsoid([x,y,-0.111],[0.017,0.016,0.008])}};add(g,UIColor(hex:"#8CA68B"))
            }
        case "eight_ball_hat":
            dome(ink,0.13)
            var g=Geometry();g.ellipsoid([0,0.075,-0.131],[0.042,0.042,0.009]);add(g,pearl,0)
            for y:Float in [0.064,0.086] {var g=Geometry();g.tube((0...24).map {i in let a=Float(i)/24*2*Float.pi;return [cos(a)*0.012,y+sin(a)*0.012,-0.141]},radius:0.004);add(g,ink)}
        case "tiny_house_hat":
            dome(UIColor(hex:"#A4BEB5"),0.12)
            var g=Geometry();g.box([0,0.09,-0.13],[0.065,0.055,0.012]);add(g,pearl)
            g=Geometry();g.polygon([[-0.043,0],[0.043,0],[0,0.038]],center:[0,0.12,-0.14],depth:0.009);add(g,rose)
        default: dome(pearl)
        }
        return root
    }
}
