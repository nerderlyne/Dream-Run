import RealityKit
import UIKit

/// Presentation clock: ordinary chapters overlap; simulation palette IDs remain versioned targets.
struct PaletteTransition {
    var from:Int
    var to:Int
    var started:Double
    var accelerated:Bool
    func fraction(at seconds:Double,order:Int=0)->Float {
        let delay=accelerated ? Double(order%12)*0.035 : Double(order%12)*0.8
        let duration=accelerated ? 1.4 : 10.0
        let x=Float(max(0,min(1,(seconds-started-delay)/duration)))
        return x*x*(3-2*x)
    }
    func skyFraction(at seconds:Double)->Float {fraction(at:seconds,order:6)}
}

@MainActor final class PaletteEvolution {
    private struct Surface {
        let model:ModelEntity
        var original:[PhysicallyBasedMaterial]
        let roles:[Int]
        let order:Int
        var applied:Float = -1
    }
    private var surfaces:[Surface]=[]
    private var cursor=0
    private(set) var transition:PaletteTransition?
    private(set) var target=0
    private(set) var updatesLastFrame=0
    private var serial=0
    private var fogFrom=UIColor.white,fogTo=UIColor.white
    private(set) var fog=UIColor.white
    func reset(palette:Int,definition:PaletteDefinition) {
        surfaces.removeAll();cursor=0;serial=0;target=palette;transition=nil
        fog=UIColor(hex:definition.fog);fogFrom=fog;fogTo=fog
    }
    func request(_ palette:Int,seconds:Double,accelerated:Bool,palettes:[PaletteDefinition],art:DreamArtDirection) {
        guard palette != target else {return}
        fogFrom=fog
        let definition=palettes[palette]
        fogTo=UIColor(hex:definition.fog)
        transition=PaletteTransition(from:target,to:palette,started:seconds,accelerated:accelerated)
        target=palette
        surfaces.removeAll{$0.model.parent == nil}
        for i in surfaces.indices {surfaces[i].original=art.baseMaterials(of:surfaces[i].model);surfaces[i].applied = -1}
    }
    func register(_ entity:Entity,palette:Int,palettes:[PaletteDefinition],art:DreamArtDirection,allSurfaces:Bool=false) {
        func visit(_ e:Entity,scenery:Bool) {
            let scene=allSurfaces || scenery || e.name == "scenery"
            if let model=e as? ModelEntity,(scene || e.name.hasPrefix("palette:")),let materials=model.model?.materials as? [PhysicallyBasedMaterial],!materials.isEmpty {
                let colors=swatches(palettes[palette])
                let explicit=["palette:light":0,"palette:dark":1,"palette:rim":3,"palette:deck":4][e.name]
                let roles=materials.map {m in explicit ?? colors.indices.min{distance(m.baseColor.tint,colors[$0]) < distance(m.baseColor.tint,colors[$1])}!}
                surfaces.append(Surface(model:model,original:materials,roles:roles,order:serial));serial += 1
            }
            for child in e.children {visit(child,scenery:scene)}
        }
        visit(entity,scenery:false)
        // Streaming owns the root. Do not retain retired chunk trees through their leaf models.
        surfaces.removeAll {surface in
            var parent:Entity?=surface.model
            while let e=parent {if e is AnchorEntity {return false};parent=e.parent}
            return true
        }
    }
    func update(seconds:Double,palettes:[PaletteDefinition],art:DreamArtDirection) {
        updatesLastFrame=0
        guard let transition else{return}
        let colors=swatches(palettes[target])
        // At most four material submissions, regardless of scene density.
        for _ in 0..<min(4,surfaces.count) {
            if cursor>=surfaces.count {cursor=0}
            let i=cursor;cursor += 1
            let t=transition.fraction(at:seconds,order:surfaces[i].order)
            guard abs(t-surfaces[i].applied)>0.035 || (t == 1 && surfaces[i].applied != 1) else{continue}
            let surface=surfaces[i]
            let materials=surface.original.enumerated().map {index,base in
                var m=base;m.baseColor.tint=blend(base.baseColor.tint,colors[surface.roles[index]],t)
                return m
            }
            art.replaceBaseMaterials(of:surface.model,with:materials)
            surfaces[i].applied=t
            if t == 1 {surfaces[i].original=materials}
            updatesLastFrame += 1
        }
        let skyProgress=transition.skyFraction(at:seconds)
        fog=blend(fogFrom,fogTo,skyProgress)
    }
    func voidWeight(seconds:Double)->Double {
        guard let transition else{return target == 5 ? 1 : 0}
        let a=transition.from == 5 ? 1.0 : 0,b=transition.to == 5 ? 1.0 : 0
        return a+(b-a)*Double(transition.skyFraction(at:seconds))
    }
    private func swatches(_ p:PaletteDefinition)->[UIColor] {[p.track_light,p.track_dark,p.accent_a,p.accent_b,p.fog].map{UIColor(hex:$0)}}
    private func distance(_ a:UIColor,_ b:UIColor)->CGFloat {
        let x=a.artSRGB.cgColor.components!,y=b.artSRGB.cgColor.components!
        return (0..<3).reduce(0){$0+(x[$1]-y[$1])*(x[$1]-y[$1])}
    }
    private func blend(_ a:UIColor,_ b:UIColor,_ t:Float)->UIColor {
        let x=a.artSRGB.cgColor.components!,y=b.artSRGB.cgColor.components!,f=CGFloat(t)
        return UIColor(red:x[0]+(y[0]-x[0])*f,green:x[1]+(y[1]-x[1])*f,blue:x[2]+(y[2]-x[2])*f,alpha:1)
    }
}
