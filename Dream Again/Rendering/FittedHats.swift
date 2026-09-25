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
            // Open-bottom kraft bag slips over the entire head. +Z is the rear,
            // facing the chase camera; the marker smile belongs on that face.
            let a:SIMD3<Float>=[-0.17,-0.255,-0.15],b:SIMD3<Float>=[0.17,-0.248,-0.15]
            let c:SIMD3<Float>=[0.165,0.19,-0.145],d:SIMD3<Float>=[-0.168,0.182,-0.145]
            let e:SIMD3<Float>=[-0.17,-0.255,0.155],f:SIMD3<Float>=[0.17,-0.248,0.155]
            let g:SIMD3<Float>=[0.165,0.19,0.15],h:SIMD3<Float>=[-0.168,0.182,0.15]
            var paper=Geometry();paper.quad(a,d,c,b);paper.quad(e,f,g,h)
            paper.quad(a,e,h,d);paper.quad(b,c,g,f);paper.quad(d,h,g,c)
            add(paper,UIColor(hex:"#AF804B"),0)
            var folds=Geometry()
            folds.tube([[-0.17,-0.24,0.156],[0,-0.236,0.158],[0.17,-0.233,0.156]],radius:0.003,segments:6)
            folds.tube([[-0.17,-0.20,0.025],[-0.164,0.11,0],[-0.166,0.18,-0.04]],radius:0.0025,segments:6)
            folds.tube([[0.17,-0.20,0.025],[0.164,0.11,0],[0.166,0.18,-0.04]],radius:0.0025,segments:6)
            folds.tube([[-0.16,0.186,0.10],[0,0.192,0.09],[0.16,0.194,0.10]],radius:0.003,segments:6)
            add(folds,UIColor(hex:"#805934"),0)
            var marker=Geometry()
            marker.tube([[-0.072,0.022,0.161],[-0.077,0.004,0.162],[-0.069,-0.015,0.163]],radius:0.01,segments:8)
            marker.tube([[0.064,0.029,0.161],[0.071,0.012,0.162],[0.068,-0.008,0.163]],radius:0.009,segments:8)
            marker.tube((0...14).map {i in
                let t=Float(i)/14
                return [-0.092+t*0.181,-0.079-0.053*sin(t * .pi)+0.003*sin(t*23),0.163]
            },radius:0.008,segments:8)
            add(marker,UIColor(hex:"#C32220"),0)
            if let ink=Array(root.children).last {
                ink.name="red-smiley-back";ink.scale.z=0.03;ink.position.z=0.156
                ink.components.set(DynamicLightShadowComponent(castsShadow:false))
            }
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
        case "flower_crown":
            ring(0.025,0.127,0.117,0.008,UIColor(hex:"#7C9E82"))
            var leaves=Geometry(),coral=Geometry(),cream=Geometry(),lilac=Geometry(),centres=Geometry()
            for i in 0..<10 {
                let a=Float(i)/10*2*Float.pi
                let radial=SIMD3<Float>(cos(a),0,sin(a))
                let tangent=SIMD3<Float>(-sin(a),0,cos(a))
                let center=SIMD3<Float>(cos(a)*0.131,0.03+Float(i%3-1)*0.009,sin(a)*0.121)
                leaves.ellipsoid(center+tangent*0.03-radial*0.008,[0.021,0.01,0.013],segments:8,rings:5)
                leaves.ellipsoid(center-tangent*0.028-radial*0.008,[0.021,0.01,0.013],segments:8,rings:5)
                for petal in 0..<5 {
                    let t=Float(petal)/5*2*Float.pi
                    let offset=tangent*cos(t)*0.021+SIMD3<Float>(0,sin(t)*0.021,0)
                    let position=center+offset+radial*0.01
                    switch i%3 {
                    case 0: coral.ellipsoid(position,[0.016,0.017,0.015],segments:8,rings:5)
                    case 1: cream.ellipsoid(position,[0.016,0.017,0.015],segments:8,rings:5)
                    default: lilac.ellipsoid(position,[0.016,0.017,0.015],segments:8,rings:5)
                    }
                }
                centres.ellipsoid(center+radial*0.021,[0.006,0.006,0.006],segments:8,rings:5)
            }
            add(leaves,UIColor(hex:"#A4BFA2"),10)
            add(coral,UIColor(hex:"#E7A5A5"))
            add(cream,UIColor(hex:"#F5DFBA"))
            add(lilac,UIColor(hex:"#BEB0D5"))
            add(centres,gold,10)
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
