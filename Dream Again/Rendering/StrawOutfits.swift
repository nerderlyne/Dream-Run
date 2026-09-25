import RealityKit
import UIKit
import simd

extension DreamRenderer {
    private func outfitMesh(_ geometry:Geometry,_ tint:UIColor,on parent:Entity,name:String,style:Int=3) {
        guard let mesh=try? geometry.resource() else {return}
        let piece=ModelEntity(mesh:mesh,materials:[factory.material(tint,style:style)])
        piece.name=name
        parent.addChild(piece)
    }

    func coconutTop(_ root:Entity) {
        let shell=UIColor(hex:"#A87549"),rim=UIColor(hex:"#E8CFAB"),twine=UIColor(hex:"#D9BD8A")
        var cups=Geometry(),edges=Geometry(),grain=Geometry(),straps=Geometry()
        for x:Float in [-0.083,0.083] {
            cups.ellipsoid([x,1.285,-0.135],[0.077,0.072,0.061],segments:24,rings:12)
            edges.tube((0...32).map { i in
                let a=Float(i)/32*2*Float.pi
                return SIMD3<Float>(x+cos(a)*0.067,1.285+sin(a)*0.061,-0.18)
            },radius:0.004,segments:6)
            for n in -2...2 {
                let offset=Float(n)*0.021
                grain.tube([[x+offset,1.34,-0.183],[x+offset*1.3,1.285,-0.195],[x+offset,1.23,-0.18]],radius:0.0024,segments:5)
            }
            let shoulder:Float=x < 0 ? -0.13:0.13
            straps.tube([[x,1.348,-0.14],[shoulder,1.415,-0.065],[shoulder,1.40,0.065],[x,1.29,0.115]],radius:0.006,segments:7)
        }
        straps.tube((0...40).map {i in
            let a=Float(i)/40*2*Float.pi
            return SIMD3<Float>(cos(a)*0.165,1.215,sin(a)*0.108)
        },radius:0.006,segments:7)
        straps.tube([[-0.07,1.29,0.115],[0,1.245,0.121],[0.07,1.29,0.115]],radius:0.005,segments:6)
        outfitMesh(cups,shell,on:root,name:"coconut-shells",style:10)
        outfitMesh(edges,rim,on:root,name:"coconut-rims",style:10)
        outfitMesh(grain,UIColor(hex:"#795033"),on:root,name:"coconut-grain",style:10)
        outfitMesh(straps,twine,on:root,name:"coconut-straps",style:10)
    }

    func officeJacket(_ root:Entity) {
        let ink=UIColor(hex:"#454353"),pearl=UIColor(hex:"#E9E4DC")
        var coat=Geometry()
        coat.loft([[0.995,0.177,0.121,0],[1.075,0.172,0.116,0],
                   [1.33,0.177,0.116,0],[1.455,0.15,0.105,0]],segments:40)
        outfitMesh(coat,ink,on:root,name:"office-jacket",style:3)
        var shirt=Geometry()
        shirt.quad([-0.068,1.42,-0.125],[-0.067,1.065,-0.137],
                   [0.067,1.065,-0.137],[0.068,1.42,-0.125])
        shirt.quad([0.068,1.42,-0.125],[0.067,1.065,-0.137],
                   [-0.067,1.065,-0.137],[-0.068,1.42,-0.125])
        outfitMesh(shirt,pearl,on:root,name:"office-shirt")
        var lapels=Geometry()
        lapels.quad([-0.158,1.43,-0.113],[-0.085,1.11,-0.152],
                    [-0.015,1.27,-0.154],[-0.064,1.40,-0.137])
        lapels.quad([0.064,1.40,-0.137],[0.015,1.27,-0.154],
                    [0.085,1.11,-0.152],[0.158,1.43,-0.113])
        lapels.quad([-0.064,1.40,-0.137],[-0.015,1.27,-0.154],
                    [-0.085,1.11,-0.152],[-0.158,1.43,-0.113])
        lapels.quad([0.158,1.43,-0.113],[0.085,1.11,-0.152],
                    [0.015,1.27,-0.154],[0.064,1.40,-0.137])
        outfitMesh(lapels,UIColor(hex:"#646172"),on:root,name:"office-lapels")
        var tie=Geometry()
        tie.polygon([[-0.023,0.04],[0.023,0.04],[0,0.012],[0.019,-0.14],
                     [0,-0.17],[-0.019,-0.14]],center:[0,1.36,-0.157],depth:0.007)
        outfitMesh(tie,UIColor(hex:"#B58EA4"),on:root,name:"office-tie",style:10)
        var buttons=Geometry()
        for y:Float in [1.07,1.16] {buttons.ellipsoid([0,y,-0.159],[0.006,0.006,0.005],segments:8,rings:5)}
        outfitMesh(buttons,UIColor(hex:"#DCC69C"),on:root,name:"office-buttons",style:2)

        for limb in arms {
            var upper=Geometry()
            upper.loft([[-0.275,0.055,0.058,0],[-0.04,0.061,0.061,0],
                        [0.012,0.063,0.065,0]],segments:20)
            outfitMesh(upper,ink,on:limb,name:"outfit-office-upper-sleeve")
        }
        for limb in elbows {
            var lower=Geometry()
            lower.loft([[-0.24,0.047,0.05,0],[-0.01,0.052,0.054,0],
                        [0.055,0.057,0.059,0]],segments:20)
            outfitMesh(lower,ink,on:limb,name:"outfit-office-lower-sleeve")
            var cuff=Geometry()
            cuff.loft([[-0.255,0.049,0.052,0],[-0.235,0.049,0.052,0]],segments:20)
            outfitMesh(cuff,pearl,on:limb,name:"outfit-office-cuff")
        }
    }

    func tuxedoPants(_ root:Entity) {
        let ink=UIColor(hex:"#3D3B4A"),stripe=UIColor(hex:"#B9A8B6")
        var waist=Geometry()
        waist.loft([[0.98,0.147,0.105,0],[1.045,0.153,0.108,0]],segments:40)
        outfitMesh(waist,ink,on:root,name:"tuxedo-waist")
        for (index,limb) in legs.enumerated() {
            let sign:Float=index == 0 ? -1:1
            var upper=Geometry()
            upper.loft([[-0.445,0.07,0.075,0],[-0.15,0.077,0.08,0],
                        [0.018,0.078,0.08,0]],segments:20)
            outfitMesh(upper,ink,on:limb,name:"outfit-tuxedo-upper-leg")
            var seam=Geometry()
            seam.tube([[sign*0.075,0.005,0],[sign*0.075,-0.2,0],
                       [sign*0.069,-0.43,0]],radius:0.004,segments:5)
            outfitMesh(seam,stripe,on:limb,name:"outfit-tuxedo-upper-stripe")
        }
        for (index,limb) in knees.enumerated() {
            let sign:Float=index == 0 ? -1:1
            var lower=Geometry()
            lower.loft([[-0.46,0.059,0.064,0],[-0.008,0.063,0.066,0],
                        [0.055,0.074,0.077,0]],segments:20)
            outfitMesh(lower,ink,on:limb,name:"outfit-tuxedo-lower-leg")
            var seam=Geometry()
            seam.tube([[sign*0.062,-0.01,0],[sign*0.057,-0.4,0]],radius:0.004,segments:5)
            outfitMesh(seam,stripe,on:limb,name:"outfit-tuxedo-lower-stripe")
            var shoe=Geometry()
            shoe.ellipsoid([0,-0.44,-0.068],[0.08,0.064,0.12],segments:20,rings:10)
            outfitMesh(shoe,UIColor(hex:"#302E3B"),on:limb,name:"outfit-tuxedo-shoe",style:2)
        }
    }
}
