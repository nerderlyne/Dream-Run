import RealityKit
import UIKit
import simd

extension DreamRenderer {
    /// One articulated reed body shared by every cosmetic look. Fibres are real geometry,
    /// grouped into a few meshes per limb, never hundreds of independent entities.
    func buildStrawDoll() {
        legs.removeAll();knees.removeAll();arms.removeAll();elbows.removeAll()
        runner.children.removeAll()
        func bundle(_ center:SIMD3<Float>,_ length:Float,_ radius:SIMD2<Float>,_ seed:Int,_ oval:Bool=false)->Entity {
            let root=Entity();root.name="straw-bundle"
            var reeds=[Geometry(),Geometry(),Geometry()],core=Geometry()
            let count=oval ? 64 : length>0.3 ? 42:26
            func width(_ t:Float)->Float {
                if oval {return sqrt(max(0.012,1-pow(t*2-1,2)))}
                return 0.76+0.2*sin(t * .pi)+0.035*cos(t*6 * .pi)
            }
            core.loft((0...12).map {i in let t=Float(i)/12;return SIMD4<Float>(center.y+(t-0.5)*length,radius.x*width(t)*0.96,radius.y*width(t)*0.96,center.z)},segments:32)
            if let mesh=try? core.resource() {
                let e=ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:"#947342"),style:10)])
                e.position.x=center.x;root.addChild(e)
            }
            for i in 0..<count {
                let a=Float(i)/Float(count)*2 * .pi,phase=Float(i*17+seed*11)
                let points=(0...10).map {j->SIMD3<Float> in
                    let t=Float(j)/10,w=width(t),ripple=sin(t*15+phase)*0.002
                    return center+[cos(a)*(radius.x*w+ripple),(t-0.5)*length+sin(phase)*0.003,sin(a)*(radius.y*w+ripple)]
                }
                reeds[i%3].tube(points,radius:oval ? 0.0037:0.0035,segments:6)
            }
            for (i,g) in reeds.enumerated() {
                if let mesh=try? g.resource() {let e=ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:["#D8B97B","#BA9659","#E8D099"][i]),style:10)]);e.name="straw-fibres";root.addChild(e)}
            }
            return root
        }
        func tie(_ root:Entity,_ y:Float,_ radius:SIMD2<Float>,turns:Int=3) {
            var g=Geometry()
            g.tube((0...turns*32).map {i in let a=Float(i)/32*2 * Float.pi;return SIMD3<Float>(cos(a)*radius.x,y+(Float(i)/Float(turns*32)-0.5)*0.025,sin(a)*radius.y)},radius:0.004,segments:6)
            if let mesh=try? g.resource() {let e=ModelEntity(mesh:mesh,materials:[factory.material(UIColor(hex:"#755431"),style:10)]);e.name="twine-binding";root.addChild(e)}
        }
        let torso=bundle([0,1.2,0],0.48,[0.16,0.097],1);torso.name="straw-torso"
        tie(torso,1.04,[0.139,0.087],turns:4);tie(torso,1.4,[0.14,0.087]);runner.addChild(torso)
        let neck=bundle([0,1.47,0],0.13,[0.054,0.052],2);tie(neck,1.48,[0.054,0.052]);runner.addChild(neck)
        let head=bundle([0,1.675,0],0.35,[0.137,0.126],3,true);head.name="straw-head";runner.addChild(head)
        for (i,sign) in [Float(-1),1].enumerated() {
            let leg=Entity(),knee=Entity(),arm=Entity(),elbow=Entity()
            leg.name=i == 0 ? "hip.L":"hip.R";leg.position=[sign*0.092,0.96,0]
            leg.addChild(bundle([0,-0.22,0],0.45,[0.061,0.066],10+i));tie(leg,-0.39,[0.052,0.057])
            knee.name=i == 0 ? "knee.L":"knee.R";knee.position=[0,-0.45,0]
            knee.addChild(bundle([0,-0.21,0],0.43,[0.05,0.052],12+i));tie(knee,-0.04,[0.043,0.045]);tie(knee,-0.37,[0.045,0.047])
            let foot=bundle(.zero,0.2,[0.05,0.054],14+i)
            foot.position=[0,-0.43,-0.045];foot.orientation=simd_quatf(angle:.pi/2,axis:[1,0,0]);knee.addChild(foot)
            leg.addChild(knee);runner.addChild(leg);legs.append(leg);knees.append(knee)
            arm.name=i == 0 ? "shoulder.L":"shoulder.R";arm.position=[sign*0.207,1.38,0]
            arm.addChild(bundle([0,-0.13,0],0.29,[0.049,0.052],20+i));tie(arm,-0.035,[0.045,0.048])
            elbow.name=i == 0 ? "elbow.L":"elbow.R";elbow.position=[0,-0.275,0]
            elbow.addChild(bundle([0,-0.13,0],0.28,[0.037,0.041],22+i));tie(elbow,-0.025,[0.034,0.037]);tie(elbow,-0.22,[0.033,0.037])
            arm.addChild(elbow);runner.addChild(arm);arms.append(arm);elbows.append(elbow)
        }
        headAttachment.name="hat.socket";headAttachment.position=[0,1.73,0];runner.addChild(headAttachment)
    }

    func strawCostume(feminine:Bool,color:UIColor) {
        runner.findEntity(named:"straw-costume")?.removeFromParent()
        let root=Entity();root.name="straw-costume"
        func add(_ g:Geometry,_ tint:UIColor,_ style:Int=3,_ name:String="cloth-overlay") {
            if let mesh=try? g.resource() {let e=ModelEntity(mesh:mesh,materials:[factory.material(tint,style:style)]);e.name=name;root.addChild(e)}
        }
        var sash=Geometry();sash.loft([[1.02,0.147,0.096,0],[1.065,0.15,0.099,0]],segments:40);add(sash,color)
        var ribbon=Geometry()
        ribbon.tube([[0,1.04,0.102],[-0.072,1.075,0.13],[-0.09,1.025,0.125],[0,1.04,0.102],[0.07,1.08,0.13],[0.085,1.025,0.125],[0,1.04,0.102]],radius:0.009,segments:8)
        ribbon.tube([[-0.014,1.04,0.115],[-0.04,0.93,0.13],[-0.065,0.9,0.14]],radius:0.008,segments:6)
        ribbon.tube([[0.014,1.04,0.115],[0.055,0.925,0.135]],radius:0.008,segments:6);add(ribbon,color)
        if feminine {
            var skirt=Geometry();skirt.loft([[0.77,0.225,0.165,0],[0.84,0.217,0.16,0],[1.03,0.147,0.098,0]],segments:48)
            add(skirt,UIColor(hex:"#C5A86B"),10,"straw-skirt")
            var pleats=Geometry()
            for i in 0..<40 {let a=Float(i)/40*2 * Float.pi;pleats.tube([[cos(a)*0.148,1.02,sin(a)*0.1],[cos(a)*0.218,0.83,sin(a)*0.163],[cos(a)*0.23,0.755,sin(a)*0.169]],radius:0.0035,segments:5)}
            add(pleats,UIColor(hex:"#E4CA8E"),10)
            var apron=Geometry();apron.quad([-0.108,1.015,0.101],[-0.152,0.835,0.168],[0.152,0.835,0.168],[0.108,1.015,0.101]);add(apron,color,3,"ribbon-apron")
            var lace=Geometry()
            for i in 0..<14 {let x=Float(i)*0.022-0.143;lace.tube([[x,0.836,0.172],[x+0.01,0.825,0.174],[x+0.022,0.836,0.172]],radius:0.0025,segments:5)}
            add(lace,UIColor(hex:"#F8EAD5"),3)
        }
        runner.addChild(root)
    }
}
