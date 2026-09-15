import RealityKit
import UIKit
import simd

/// Render-only continuation of the registered route families. No hazards, pickups or RNG state.
@MainActor final class DistantPathRenderer {
    let root=Entity()
    private struct Section {var start:Double;var entity:Entity;var color:UIColor;var alpha:Float = -1}
    private var sections:[Int:Section]=[:]
    private let sectionLength=384.0
    private let distanceAhead=6144.0
    func reset() {root.removeFromParent();root.children.removeAll();sections.removeAll()}
    func rebase(by shift:SIMD3<Float>) {
        for section in sections.values {section.entity.position += shift}
    }
    func update(run:RunState,origin:RouteSample,palette:PaletteDefinition,world:Entity) {
        if root.parent == nil {world.addChild(root)}
        guard let nearEnd=run.chunks.map(\.end).max() else {return}
        let first=Int(nearEnd/sectionLength),last=Int((run.distance+distanceAhead)/sectionLength)
        for id in Array(sections.keys) where id < first || id > last {sections.removeValue(forKey:id)?.entity.removeFromParent()}
        let generator=WorldGenerator(run.identity)
        for id in first...last {
            let start=max(nearEnd,Double(id)*sectionLength),end=Double(id+1)*sectionLength
            guard start < end else {continue}
            if sections[id]?.start == start {continue}
            sections.removeValue(forKey:id)?.entity.removeFromParent()
            var geometry=Geometry(),rim=Geometry(),s=start
            var cachedChunk:ChunkDescription?
            func point(_ sample:RouteSample,_ lateral:Double)->SIMD3<Float> {
                [Float(sample.x-origin.x+lateral*cos(sample.yaw)),Float(sample.y-origin.y),Float(sample.z-origin.z+lateral*sin(sample.yaw))]
            }
            while s < end {
                let next=min(s+4,end),middle=(s+next)/2,index=Int(middle/24)
                if cachedChunk?.id != index {cachedChunk=generator.chunk(index,tutorial:run.mode == .tutorial)}
                let local=middle.truncatingRemainder(dividingBy:1800)
                let gap=cachedChunk?.gap.map{$0.lowerBound < next && $0.upperBound > s} ?? false
                if run.pigs.count == 3 || (!gap && !(local >= 900 && local < 916)) {
                    let a=generator.sample(s),b=generator.sample(next)
                    let width=cachedChunk?.halfWidth ?? 2
                    let leftA=point(a,-width),rightA=point(a,width),leftB=point(b,-width),rightB=point(b,width)
                    geometry.quad(leftA,rightA,rightB,leftB)
                    // A remote uphill ribbon must remain visible from below too.
                    rim.tube([leftA,leftB],radius:0.035,segments:3);rim.tube([rightA,rightB],radius:0.035,segments:3)
                }
                s=next
            }
            let entity=Entity();entity.name="distant-route"
            var sectionColor=UIColor(hex:palette.sky)
            if !geometry.positions.isEmpty,let mesh=try? geometry.resource() {
                // Suppress subpixel checker shimmer; blend the far end into the existing sky.
                let distance=max(0,(start+end)/2-run.distance)
                let fade=min(1,max(0,(distance-1800)/3600))
                let track=blend(UIColor(hex:palette.track_light),UIColor(hex:palette.track_dark),0.5)
                let color=blend(track,UIColor(hex:palette.sky),fade);sectionColor=color
                var material=UnlitMaterial(color:color);material.blending = .transparent(opacity:.init(floatLiteral:1));material.faceCulling = .none
                let model=ModelEntity(mesh:mesh,materials:[material]);model.name="distant-base";entity.addChild(model)
                if let edgeMesh=try? rim.resource() {entity.addChild(ModelEntity(mesh:edgeMesh,materials:[UnlitMaterial(color:UIColor(hex:palette.accent_b))]))}
            }
            root.addChild(entity);sections[id]=Section(start:start,entity:entity,color:sectionColor)
        }
        for (id,section) in sections {
            let alpha=TrackTranslucency.opacity(identity:run.identity,distance:run.distance,seconds:run.seconds,visual:run.visual,transitions:run.mirrorCount+run.dropCount,ahead:section.start-run.distance)
            if abs(section.alpha-alpha.base)>0.012 {
                section.entity.findEntity(named:"distant-base")?.components.set(OpacityComponent(opacity:alpha.base));sections[id]?.alpha=alpha.base
            }
        }
        if run.pigs.count == 3 {
            let amount=min(1,run.endingElapsed/45)
            for section in sections.values {
                for child in section.entity.children {
                    if let model=child as? ModelEntity {model.model?.materials=[UnlitMaterial(color:blend(section.color,UIColor(hex:"#F4F3EF"),amount))]}
                }
            }
        }
    }
    private func blend(_ a:UIColor,_ b:UIColor,_ t:Double)->UIColor {
        var ar:CGFloat=0,ag:CGFloat=0,ab:CGFloat=0,aa:CGFloat=0,br:CGFloat=0,bg:CGFloat=0,bb:CGFloat=0,ba:CGFloat=0
        a.getRed(&ar,green:&ag,blue:&ab,alpha:&aa);b.getRed(&br,green:&bg,blue:&bb,alpha:&ba)
        let f=CGFloat(t)
        return UIColor(red:ar+(br-ar)*f,green:ag+(bg-ag)*f,blue:ab+(bb-ab)*f,alpha:1)
    }
}
