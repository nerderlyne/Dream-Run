import RealityKit
import UIKit
import simd

struct Geometry {
    var positions: [SIMD3<Float>] = []
    var normals: [SIMD3<Float>] = []
    var indices: [UInt32] = []
    mutating func triangle(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>) {
        let n = simd_cross(b-a,c-a), normal = simd_length_squared(n) > 0.0000001 ? simd_normalize(n) : SIMD3<Float>(0,1,0)
        let base=UInt32(positions.count); positions += [a,b,c]; normals += [normal,normal,normal]; indices += [base,base+1,base+2]
    }
    mutating func quad(_ a: SIMD3<Float>,_ b: SIMD3<Float>,_ c: SIMD3<Float>,_ d: SIMD3<Float>) { triangle(a,b,c); triangle(a,c,d) }
    mutating func box(_ center: SIMD3<Float>, _ size: SIMD3<Float>) {
        let a=center-size/2,b=center+size/2
        let p:[SIMD3<Float>]=[[a.x,a.y,a.z],[b.x,a.y,a.z],[b.x,b.y,a.z],[a.x,b.y,a.z],[a.x,a.y,b.z],[b.x,a.y,b.z],[b.x,b.y,b.z],[a.x,b.y,b.z]]
        for q in [[0,3,2,1],[4,5,6,7],[0,4,7,3],[1,2,6,5],[3,7,6,2],[0,1,5,4]] { quad(p[q[0]],p[q[1]],p[q[2]],p[q[3]]) }
    }
    mutating func ellipsoid(_ center: SIMD3<Float>, _ scale: SIMD3<Float>, segments: Int = 16, rings: Int = 10) {
        let base=UInt32(positions.count)
        for y in 0...rings { let phi=Float(y)/Float(rings)*Float.pi
            for x in 0...segments { let theta=Float(x)/Float(segments)*2*Float.pi; let unit=SIMD3<Float>(sin(phi)*cos(theta),cos(phi),sin(phi)*sin(theta)); positions.append(center+unit*scale); normals.append(simd_normalize(unit/scale)) }
        }
        for y in 0..<rings { for x in 0..<segments { let a=base+UInt32(y*(segments+1)+x), b=a+UInt32(segments+1); indices += [a,a+1,b,a+1,b+1,b] } }
    }
    mutating func tube(_ points: [SIMD3<Float>], radius: Float, segments: Int = 8) {
        guard points.count > 1 else { return }
        for i in 0..<points.count-1 {
            let a=points[i],b=points[i+1],direction=simd_normalize(b-a)
            let right=simd_normalize(simd_cross(direction,abs(direction.y)>0.95 ? SIMD3<Float>(1,0,0) : SIMD3<Float>(0,1,0))), up=simd_cross(direction,right)
            for j in 0..<segments { let t=Float(j)/Float(segments)*2*Float.pi,u=Float(j+1)/Float(segments)*2*Float.pi, p=(right*cos(t)+up*sin(t))*radius,q=(right*cos(u)+up*sin(u))*radius; quad(a+p,a+q,b+q,b+p) }
        }
    }
    mutating func polygon(_ points: [SIMD2<Float>], center: SIMD3<Float>, depth: Float) {
        for i in points.indices {
            let j=(i+1)%points.count, p=points[i],q=points[j], a=center+SIMD3<Float>(p.x,p.y,depth/2), b=center+SIMD3<Float>(q.x,q.y,depth/2), c=center+SIMD3<Float>(q.x,q.y,-depth/2), d=center+SIMD3<Float>(p.x,p.y,-depth/2)
            triangle(center+[0,0,depth/2],a,b); triangle(center-[0,0,depth/2],c,d); quad(a,d,c,b)
        }
    }
    func resource() throws -> MeshResource {
        var d=MeshDescriptor(name:"Original procedural geometry"); d.positions=MeshBuffers.Positions(positions); d.normals=MeshBuffers.Normals(normals); d.textureCoordinates=MeshBuffers.TextureCoordinates(positions.map{SIMD2<Float>($0.x*0.25+$0.z*0.17,$0.y*0.25+$0.z*0.17)}); d.primitives = .triangles(indices)
        return try MeshResource.generate(from:[d])
    }
}
extension UIColor {
    convenience init(hex: String) { let n=UInt32(hex.replacingOccurrences(of:"#",with:""),radix:16) ?? 0xEFE7EB; self.init(red:CGFloat((n>>16)&255)/255,green:CGFloat((n>>8)&255)/255,blue:CGFloat(n&255)/255,alpha:1) }
}
@MainActor final class PrefabFactory {
    var cache: [String:Entity] = [:]
    var triangleCounts: [String:Int] = [:]
    var textures:[Int:TextureResource]=[:]
    var materials:[String:SimpleMaterial]=[:]
    let palettes: [PaletteDefinition]
    init(palettes: [PaletteDefinition]) { self.palettes=palettes }
    func material(_ color: UIColor, style: Int) -> SimpleMaterial {
        let key="\(color.description):\(style)"
        if let cached=materials[key] {return cached}
        var result=SimpleMaterial(color:style == 5 ? color.withAlphaComponent(0.6) : color,roughness:style == 1 || style == 5 ? 0.16 : style == 2 || style == 4 ? 0.3 : style == 3 ? 0.98 : 0.64,isMetallic:style == 2 || style == 4)
        if [3,4,6].contains(style) {
            if textures[style] == nil {
                let format=UIGraphicsImageRendererFormat();format.scale=1
                let image=UIGraphicsImageRenderer(size:CGSize(width:96,height:96),format:format).image {context in
                    for y in 0..<96 {for x in 0..<96 {
                        let noise=Double((x*73+y*199+x*y*7)%97)/97
                        let wave=sin(Double(x)*0.13+sin(Double(y)*0.1)*2)
                        let level=style == 6 ? 0.73+0.27*abs(wave) : style == 3 ? 0.76+noise*0.24 : 0.9+0.1*wave
                        let c=style == 4 ? UIColor(red:level,green:0.94,blue:1,alpha:1) : UIColor(white:level,alpha:1)
                        context.cgContext.setFillColor(c.cgColor);context.cgContext.fill(CGRect(x:x,y:y,width:1,height:1))
                    }}
                }
                if let cg=image.cgImage {textures[style]=try? TextureResource.generate(from:cg,options:.init(semantic:.color))}
            }
            if let texture=textures[style] {result.color = .init(tint:color,texture:.init(texture))}
        }
        if materials.count >= 128 {materials.removeAll(keepingCapacity:true)};materials[key]=result;return result
    }
    func build(_ id: AssetID, palette: Int = 0, style: Int = 0, lod: Int = 0) -> Entity {
        let key="\(id.rawValue):\(palette):\(style):\(lod)"
        if let cached=cache[key] { return cached.clone(recursive:true) }
        let p=palettes[palette % palettes.count], root=Entity()
        var body=Geometry(),trim=Geometry(),dark=Geometry(),semantic=Geometry()
        var bodyColor=UIColor(hex:p.accent_a),trimColor=UIColor(hex:p.accent_b),darkColor=UIColor(hex:p.track_dark),semanticColor=UIColor.white
        let segments=lod == 0 ? 16 : lod == 1 ? 10 : 6
        func sphere(_ g: inout Geometry,_ c: SIMD3<Float>,_ s: SIMD3<Float>) { g.ellipsoid(c,s,segments:segments,rings:max(4,segments/2)) }
        func ring(_ g: inout Geometry,_ center: SIMD3<Float>,_ radius: Float,_ tube: Float, vertical: Bool = false) {
            let points=(0...24).map { i -> SIMD3<Float> in let t=Float(i)/24*2*Float.pi; return center + (vertical ? SIMD3<Float>(cos(t)*radius,sin(t)*radius,0) : SIMD3<Float>(cos(t)*radius,0,sin(t)*radius)) }; g.tube(points,radius:tube)
        }
        func heart(_ g: inout Geometry,_ center: SIMD3<Float>,_ scale: Float) {
            let pts=(0..<32).map { i -> SIMD2<Float> in let t=Float(i)/32*2*Float.pi; return SIMD2<Float>(16*pow(sin(t),3),13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t))*scale/18 }; g.polygon(pts.reversed(),center:center,depth:scale*0.35)
        }
        switch id {
        case .trackStraight,.trackCurve,.trackRamp,.stairsStraight,.stairsCurve,.stairsSpiral,.platform,.trackBroken:
            let stairs=[AssetID.stairsStraight,.stairsCurve,.stairsSpiral].contains(id), curve=[AssetID.trackCurve,.stairsCurve,.stairsSpiral].contains(id)
            for n in 0..<24 {
                if id == .trackBroken && (10...13).contains(n) { continue }
                let s=Float(n),x=curve ? 24*(1-cos(s/24)) : 0, y=stairs || id == .trackRamp ? s*0.13 : 0
                body.box([x,y-0.22,-s],[4,0.4,1.02])
                for j in 0..<4 { let c=SIMD3<Float>(x+Float(j)-1.5,y,-s); if (n+j)%2 == 0 { trim.box(c,[1,0.035,1]) } else { dark.box(c,[1,0.035,1]) } }
            }
            trimColor=UIColor(hex:p.track_light)
        case .arch,.mirror:
            for x:Float in [-2.2,2.2] { body.box([x,1.6,0],[0.35,3.2,0.45]); trim.box([x,0.12,0],[0.6,0.24,0.7]) }
            body.tube((0...24).map { let t=Float($0)/24*Float.pi; return SIMD3<Float>(2.2*cos(t),3.2+2.2*sin(t),0) },radius:0.22)
            if id == .mirror { dark.box([0,2.5,-0.1],[4.2,5,0.06]); darkColor = .black; trim.tube([[-1.7,0.5,0.02],[-1.5,4,0.02],[-0.8,4.5,0.02]],radius:0.018) }
        case .column:
            body.tube([[0,0.2,0],[0,3.8,0]],radius:0.32,segments:12)
            for y:Float in [0.15,3.8,4] { trim.box([0,y,0],[0.95,0.2,0.95]) }
        case .window:
            for x:Float in [-1.5,1.5] { body.box([x,2,0],[0.15,4,0.2]) }
            for y:Float in [0,4] { body.box([0,y,0],[3.15,0.15,0.2]) }
            for sign:Float in [-1,1] { let x=sign*2.1; for y:Float in [0,1.4,2.7,4] { trim.tube([[sign*1.5,y,0],[x,y,0.9]],radius:0.06) }; trim.tube([[x,0,0.9],[x,4,0.9]],radius:0.06) }
        case .roomShell:
            for x:Float in [-5,5] { body.box([x,3,-2],[0.4,6,8]) }
            body.box([0,5.5,-5.8],[10,1,0.4]); for x:Float in [-3.5,3.5] { body.box([x,2.5,-5.8],[3,5,0.4]) }
        case .house:
            body.box([0,1,0],[2.6,2,2]); trim.polygon([[-1.6,0],[1.6,0],[0,1.3]],center:[0,2,0],depth:2.4)
            dark.box([0,0.6,1.01],[0.5,1.2,0.04]); for x:Float in [-0.8,0.8] { dark.box([x,1.35,1.02],[0.5,0.6,0.04]); trim.box([x,1.35,1.05],[0.06,0.6,0.04]) }
        case .tower:
            for n in 0..<5 { let y=Float(n)*1.8, width=2.2-Float(n)*0.25; body.box([0,y+0.8,0],[width,1.6,width]); trim.box([0,y+1.65,0],[width+0.3,0.15,width+0.3]); dark.box([0,y+0.8,width/2+0.01],[0.35,0.7,0.03]) }
        case .fountain:
            body.tube([[0,0,0],[0,2.5,0]],radius:0.2)
            for n in 0..<3 { let y=Float(n)*0.9,r=1.6-Float(n)*0.45; sphere(&body,[0,y+0.15,0],[r,0.15,r]); ring(&trim,[0,y+0.3,0],r,0.09) }
        case .chair,.bed:
            let bed=id == .bed, width:Float=bed ? 1.8 : 0.9, depth:Float=bed ? 2.6 : 0.9
            body.box([0,0.7,0],[width,0.2,depth]); body.box([0,1.3,-depth/2],[width,bed ? 0.9 : 1.3,0.15])
            for x in [-width/2+0.1,width/2-0.1] { for z in [-depth/2+0.1,depth/2-0.1] { trim.box([x,0.35,z],[0.1,0.7,0.1]) } }
            if bed { sphere(&trim,[0,0.92,-0.8],[0.7,0.15,0.35]); body.box([0,0.85,0.4],[1.78,0.18,1.5]) }
        case .tree:
            body.tube([[0,0,0],[0.15,2,0],[-0.15,3.7,0],[0.2,5,0]],radius:0.16)
            for n in 0..<5 { let t=Float(n)*2.4, y=1.7+Float(n)*0.5; let end=SIMD3<Float>(cos(t)*1.7,y+1.5,sin(t)*1.2); body.tube([[0,y,0],end],radius:0.08); if palette != 5 && palette != 4 { sphere(&trim,end,[1.15,0.8,0.9]) } }
        case .flower:
            body.tube([[0,0,0],[0.2,1.5,0],[0,3,0]],radius:0.07); bodyColor=UIColor(hex:"#829F89")
            for n in 0..<8 { let a=Float(n)*Float.pi/4; sphere(&trim,[cos(a)*0.65,3+sin(a)*0.65,0],[0.48,0.48,0.14]) }; sphere(&semantic,[0,3,0.15],[0.38,0.38,0.17]); semanticColor=UIColor(hex:"#E6CA8A")
            sphere(&body,[0.35,1.5,0],[0.6,0.18,0.15])
        case .mushroom:
            sphere(&body,[0,0.8,0],[0.3,0.85,0.3]); sphere(&trim,[0,1.7,0],[1.1,0.5,1.1])
            for n in 0..<7 { let t=Float(n)*2.4; sphere(&semantic,[cos(t)*0.65,2.05,sin(t)*0.65],[0.12,0.04,0.12]) }
        case .rock,.mountain:
            let count=id == .mountain ? 5 : 3
            for n in 0..<count { let t=Float(n)*2.4; body.ellipsoid([cos(t)*0.5,0.5+Float(n)*0.15,sin(t)*0.4],[0.8, id == .mountain ? 2+Float(n)*0.4 : 0.7,0.85],segments:7,rings:4) }
        case .cloud:
            for n in 0..<6 { let t=Float(n)*2.4; sphere(&body,[cos(t)*1.2,0.3+Float(n%3)*0.25,sin(t)*0.7],[1.1,0.7,0.9]) }; bodyColor=UIColor(hex:p.fog)
        case .water:
            body.box([0,-0.05,0],[24,0.1,24]); bodyColor=UIColor(hex:p.accent_b)
            for n in 0..<8 { let z=Float(n)*3-10; trim.tube((0...10).map { [Float($0)*2-10,0.015,z+sin(Float($0))*0.1] },radius:0.015) }
        case .moon:
            sphere(&body,[0,1.1,0],[1.1,1.1,1.1]); bodyColor=UIColor(hex:"#EEE6CD")
            for n in 0..<5 { let a=Float(n)*2.1; sphere(&trim,[cos(a)*0.6,1.1+sin(a)*0.6,0.91],[0.14,0.11,0.04]) }
        case .balloon:
            sphere(&body,[0,0.65,0],[0.3,0.4,0.3]); body.polygon([[-0.06,0],[0.06,0],[0,0.1]],center:[0,0.19,0],depth:0.08); trim.tube([[0,0.22,0],[0.025,0,0],[-0.04,-0.23,0],[0,-0.45,0]],radius:0.012); ring(&semantic,[0,0.03,0],0.39,0.018)
        case .heart: heart(&body,[0,1,0],1)
        case .star:
            let pts=(0..<10).map { n -> SIMD2<Float> in let t=Float(n)*Float.pi/5+Float.pi/2,r:Float=n%2 == 0 ? 1 : 0.44; return [cos(t)*r,sin(t)*r] }; body.polygon(pts,center:[0,1,0],depth:0.22)
        case .soccer,.eightBall,.softball,.americanFootball,.nazar:
            let radius:Float=id == .nazar ? 0.7 : 0.45
            sphere(&body,[0,radius,0],id == .americanFootball ? [0.65,0.35,0.35] : [radius,radius,radius])
            if id == .nazar {
                bodyColor=UIColor(hex:"#174CAF"); trimColor=UIColor(hex:"#0A225F"); semanticColor=UIColor(hex:"#85D5EF"); darkColor = .black
                sphere(&trim,[0,radius,0.59],[0.5,0.5,0.14]); sphere(&dark,[0,radius,0.726],[0.18,0.18,0.035]); sphere(&semantic,[0,radius,0.699],[0.25,0.25,0.045])
                var white=Geometry(); sphere(&white,[0,radius,0.665],[0.37,0.37,0.055]); if let mesh=try? white.resource() { root.addChild(ModelEntity(mesh:mesh,materials:[material(.white,style:1)])) }
            } else if id == .eightBall {
                bodyColor = .black; trimColor = .white; darkColor = .black
                for sign:Float in [-1,1] { sphere(&trim,[0,radius,sign*0.423],[0.23,0.23,0.035]); for y:Float in [radius-0.075,radius+0.075] { ring(&dark,[0,y,sign*0.46],0.072,0.025,vertical:true) } }
            } else if id == .soccer {
                bodyColor = .white; trimColor = UIColor(hex:"#292733")
                for n in 0..<10 { let a=Float(n)*2.4, y=Float(n%3-1)*0.23; sphere(&trim,[cos(a)*0.37,radius+y,sin(a)*0.37],[0.13,0.13,0.08]) }
            } else if id == .softball {
                bodyColor=UIColor(hex:"#D9E969"); trimColor = .white
                for sign:Float in [-1,1] { trim.tube((0...24).map { n in let a=Float(n)/24*2*Float.pi; return [sign*0.2+0.07*cos(a*2),radius+0.39*cos(a),0.39*sin(a)] },radius:0.018) }
            } else {
                bodyColor=UIColor(hex:"#915C45"); trimColor = .white
                trim.tube([[-0.25,radius+0.24,0.22],[0.25,radius+0.24,0.22]],radius:0.022)
                for n in 0..<5 { trim.box([Float(n)*0.1-0.2,radius+0.24,0.23],[0.035,0.12,0.03]) }
            }
        case .ribbon:
            body.tube((0...32).map { let t=Float($0)/32*2*Float.pi; return [sin(t)*1.4,1+sin(2*t)*0.7,cos(t)*0.15] },radius:0.16)
        case .curtain:
            for sign:Float in [-1,1] { for n in 0..<8 { sphere(&body,[sign*(0.65+Float(n)*0.19),2,Float(n%2)*0.09],[0.13,1.7,0.12]) } }; trim.box([0,3.8,0],[4.5,0.12,0.18])
        case .clover:
            bodyColor=UIColor(hex:"#71AC7B"); body.tube([[0,0,0],[0,0.65,0]],radius:0.035)
            for n in 0..<4 { let t=Float(n)*Float.pi/2+Float.pi/4; heart(&body,[cos(t)*0.28,0.8+sin(t)*0.28,0],0.3) }
        case .rail:
            for n in 0..<9 { body.tube([[Float(n)*0.5-2,0,0],[Float(n)*0.5-2,1,0]],radius:0.045) }; trim.box([0,1,0],[4.3,0.12,0.16])
        case .horse,.zebra:
            bodyColor=id == .zebra ? UIColor(hex:"#F2ECE7") : UIColor(hex:p.accent_a); darkColor=UIColor(hex:"#36323C")
            // Belly bottom .85, legs outside ±1.65: the central .58 m slide capsule visibly fits.
            sphere(&body,[0,1.5,0],[2.0,0.65,0.6]); sphere(&body,[1.65,2.05,0],[0.42,0.85,0.4]); sphere(&body,[1.95,2.7,0.05],[0.63,0.3,0.32])
            for x:Float in [-1.7,1.7] { for z:Float in [-0.43,0.43] { body.tube([[x,0,z],[x,1.4,z]],radius:0.12); dark.box([x,0.08,z],[0.28,0.16,0.27]) } }
            dark.tube([[-1.85,1.7,0],[-2.3,1,0],[-2.4,0.55,0]],radius:0.12)
            dark.tube([[1.25,1.65,-0.2],[1.35,2.5,-0.2],[1.65,2.95,-0.2]],radius:0.16)
            for z:Float in [-0.2,0.2] { sphere(&body,[1.8,3.05,z],[0.12,0.3,0.1]); sphere(&dark,[2.14,2.8,z*1.55],[0.06,0.06,0.04]) }
            if id == .zebra { for n in 0..<12 { let x=Float(n)*0.28-1.55; dark.tube((0...12).map { let t=Float($0)/12*Float.pi*2; return [x+0.08*sin(t*2),1.5+0.65*cos(t),0.605*sin(t)] },radius:0.065) } }
        case .rabbit:
            sphere(&body,[0,0.38,0],[0.35,0.38,0.42]); sphere(&body,[0,0.69,0.2],[0.25,0.25,0.24])
            for x:Float in [-0.13,0.13] { sphere(&body,[x,1.04,0.18],[0.085,0.33,0.07]); sphere(&trim,[x,1.06,0.235],[0.043,0.23,0.018]); sphere(&dark,[x,0.75,0.41],[0.026,0.035,0.02]) }; sphere(&body,[0,0.38,-0.42],[0.16,0.16,0.16]); bodyColor=UIColor(hex:"#EFE4E2"); trimColor=UIColor(hex:"#DDA3B7")
        case .pig:
            bodyColor=UIColor(hex:"#E8ADB9"); trimColor=UIColor(hex:"#CE859B"); darkColor=UIColor(hex:"#51404B")
            sphere(&body,[0,0.4,0],[0.42,0.32,0.52]); sphere(&body,[0,0.52,0.38],[0.32,0.28,0.3]); sphere(&trim,[0,0.48,0.66],[0.21,0.14,0.09])
            for x:Float in [-0.22,0.22] { for z:Float in [-0.27,0.27] { body.box([x,0.13,z],[0.14,0.26,0.14]) }; body.polygon([[-0.1,0],[0.1,0],[0,0.23]],center:[x,0.73,0.36],depth:0.08); sphere(&dark,[x*0.65,0.62,0.63],[0.026,0.03,0.02]); sphere(&dark,[x*0.3,0.48,0.747],[0.025,0.035,0.012]) }
            trim.tube((0...24).map { let t=Float($0)/24*Float.pi*4; return [0.07*cos(t),0.43+0.07*sin(t),-0.52-Float($0)*0.006] },radius:0.02)
        }
        var count=0
        for (g,color) in [(body,bodyColor),(trim,trimColor),(dark,darkColor),(semantic,semanticColor)] where !g.positions.isEmpty {
            do { let chosen:any Material = style == 7 ? UnlitMaterial(color:color) : material(color,style:style)
                let entity=ModelEntity(mesh:try g.resource(),materials:[chosen]); root.addChild(entity); count += g.indices.count/3 }
            catch { assertionFailure("Procedural mesh \(id): \(error)") }
        }
        root.name="asset:\(id.rawValue)"; triangleCounts[key]=count
        if cache.count >= 168 { cache.removeAll(keepingCapacity:true) }; cache[key]=root
        return root.clone(recursive:true)
    }
}
