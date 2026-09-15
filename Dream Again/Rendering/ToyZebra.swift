import RealityKit
import simd

extension PrefabFactory {
    /// Painted stripes share the toy's surface; no floating hoops or protruding ribbing.
    func toyZebra(body:inout Geometry,dark:inout Geometry,trim:inout Geometry,segments:Int) {
        func painted(_ center:SIMD3<Float>,_ size:SIMD3<Float>,bands:Float,vertical:Bool=false) {
            let rings=Int(bands)*2
            for i in 0..<rings {for j in 0..<segments {
                func vertex(_ a:Int,_ b:Int)->(SIMD3<Float>,SIMD3<Float>) {
                    let q=Float(a)/Float(rings)*Float.pi,v=Float(b)/Float(segments)*2*Float.pi
                    let u=q+0.035*sin(v*3+q*7)*sin(q)
                    var n=SIMD3<Float>(cos(u),sin(u)*cos(v),sin(u)*sin(v))
                    if vertical {n=SIMD3<Float>(-n.y,n.x,n.z)}
                    return (center+n*size,simd_normalize(n/size))
                }
                let black=(i/2)%2 == 0
                var g=Geometry()
                for (a,b) in [(i,j),(i+1,j),(i+1,j+1),(i,j+1)] {let (p,n)=vertex(a,b);g.positions.append(p);g.normals.append(n)}
                g.indices=[0,1,2,0,2,3]
                if black {append(g,to:&dark)} else {append(g,to:&body)}
            }}
        }
        // Four stout legs and a raised belly leave the central slide opening unobstructed.
        painted([0,1.52,0],[1.78,0.62,0.57],bands:22)
        painted([1.37,2.02,0],[0.39,0.78,0.35],bands:14,vertical:true)
        painted([1.68,2.65,0],[0.52,0.32,0.34],bands:12)
        dark.ellipsoid([2.04,2.52,0],[0.35,0.25,0.33],segments:24,rings:16)
        for x:Float in [-1.45,1.45] {for z:Float in [-0.4,0.4] {
            painted([x,0.65,z],[0.16,0.58,0.16],bands:12,vertical:true)
            dark.ellipsoid([x,0.12,z],[0.2,0.13,0.21],segments:20,rings:12)
        }}
        for z:Float in [-0.23,0.23] {
            body.ellipsoid([1.45,3.05,z],[0.13,0.3,0.12],segments:20,rings:12)
            dark.ellipsoid([1.49,3.07,z],[0.08,0.2,0.125],segments:16,rings:10)
            dark.ellipsoid([1.81,2.76,z*1.42],[0.072,0.085,0.035],segments:20,rings:12)
            body.ellipsoid([1.82,2.79,z*1.54],[0.022,0.025,0.01],segments:12,rings:8)
            trim.ellipsoid([2.29,2.56,z*0.72],[0.025,0.04,0.05],segments:12,rings:8)
        }
        dark.polygon([[-0.2,0],[0.02,0.8],[0.28,1.3],[0.4,1.24],[0.18,0.68],[0.05,0]],center:[1.02,1.7,0],depth:0.16)
        dark.tube([[-1.65,1.65,0],[-1.95,1.48,0],[-2.06,1.02,0]],radius:0.055,segments:10)
        dark.ellipsoid([-2.06,0.94,0],[0.13,0.22,0.12],segments:16,rings:10)
    }
    private func append(_ source:Geometry,to target:inout Geometry) {
        let base=UInt32(target.positions.count)
        target.positions += source.positions;target.normals += source.normals
        target.indices += source.indices.map{$0+base}
    }
}
