import RealityKit
import simd

extension Geometry {
    /// Smooth profile loft: y, x radius, z radius, z offset. Used for tailored clothing and limbs.
    mutating func loft(_ profile:[SIMD4<Float>],segments:Int=32) {
        guard profile.count>1 else{return}
        let start=UInt32(positions.count)
        for i in profile.indices {
            let p=profile[i],before=profile[max(0,i-1)],after=profile[min(profile.count-1,i+1)]
            for j in 0...segments {
                let t=Float(j)/Float(segments)*2*Float.pi
                let tangent=SIMD3<Float>(-p.y*sin(t),0,p.z*cos(t))
                let vertical=SIMD3<Float>((after.y-before.y)*cos(t),after.x-before.x,(after.z-before.z)*sin(t)+after.w-before.w)
                positions.append([p.y*cos(t),p.x,p.z*sin(t)+p.w]);normals.append(simd_normalize(simd_cross(vertical,tangent)))
            }
        }
        for i in 0..<profile.count-1 {for j in 0..<segments {
            let a=start+UInt32(i*(segments+1)+j),b=a+UInt32(segments+1)
            indices += [a,b,a+1,a+1,b,b+1]
        }}
    }
    /// A joined implicit surface, with gradient normals. No intersecting ellipsoid seams.
    /// The small fixed grid is built once per cached prefab, never per frame.
    mutating func sculpt(_ forms:[(SIMD3<Float>,SIMD3<Float>)],min lo:SIMD3<Float>,max hi:SIMD3<Float>,step:Float,blend:Float=0.12,ripple:Float=0) {
        func field(_ p:SIMD3<Float>)->Float {
            var d:Float=100
            for (c,r) in forms {
                let q=(p-c)/r;let v=(simd_length(q)-1)*Swift.min(r.x,Swift.min(r.y,r.z))
                let h=Swift.max(blend-abs(d-v),0)/blend
                d=Swift.min(d,v)-h*h*blend*0.25
            }
            return d+ripple*sin(p.x*7+sin(p.z*5))*sin(p.y*9+p.z*3)
        }
        func normal(_ p:SIMD3<Float>)->SIMD3<Float> {
            let e:Float=0.003
            return simd_normalize(SIMD3(field(p+[e,0,0])-field(p-[e,0,0]),field(p+[0,e,0])-field(p-[0,e,0]),field(p+[0,0,e])-field(p-[0,0,e])))
        }
        let nx=Int(ceil((hi.x-lo.x)/step)),ny=Int(ceil((hi.y-lo.y)/step)),nz=Int(ceil((hi.z-lo.z)/step))
        let corners:[SIMD3<Int>]=[[0,0,0],[1,0,0],[1,1,0],[0,1,0],[0,0,1],[1,0,1],[1,1,1],[0,1,1]]
        let tetra=[[0,5,1,6],[0,1,2,6],[0,2,3,6],[0,3,7,6],[0,7,4,6],[0,4,5,6]]
        let edges=[(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]
        var values=[Float](repeating:0,count:(nx+1)*(ny+1)*(nz+1))
        func index(_ x:Int,_ y:Int,_ z:Int)->Int {(z*(ny+1)+y)*(nx+1)+x}
        for z in 0...nz {for y in 0...ny {for x in 0...nx {values[index(x,y,z)]=field(lo+SIMD3(Float(x),Float(y),Float(z))*step)}}}
        func emit(_ a:SIMD3<Float>,_ b:SIMD3<Float>,_ c:SIMD3<Float>,into g:inout Geometry) {
            let n=normal((a+b+c)/3),swap=simd_dot(simd_cross(b-a,c-a),n)<0
            let pts=swap ? [a,c,b] : [a,b,c],base=UInt32(g.positions.count)
            g.positions += pts;g.normals += pts.map{normal($0)};g.indices += [base,base+1,base+2]
        }
        for z in 0..<nz {for y in 0..<ny {for x in 0..<nx {
            let ps=corners.map{lo+SIMD3(Float(x+$0.x),Float(y+$0.y),Float(z+$0.z))*step}
            let vs=corners.map{values[index(x+$0.x,y+$0.y,z+$0.z)]}
            if vs.allSatisfy({$0>0}) || vs.allSatisfy({$0<0}) {continue}
            for t in tetra {
                var hits:[SIMD3<Float>]=[]
                for (aa,bb) in edges {let a=t[aa],b=t[bb];if (vs[a]<0) != (vs[b]<0) {hits.append(ps[a]+(ps[b]-ps[a])*(vs[a]/(vs[a]-vs[b])))}}
                if hits.count == 3 {emit(hits[0],hits[1],hits[2],into:&self)}
                if hits.count == 4 {
                    let center=hits.reduce(SIMD3<Float>.zero,+)/4,n=normal(center),u=simd_normalize(hits[0]-center),v=simd_cross(n,u)
                    hits.sort{atan2(simd_dot($0-center,v),simd_dot($0-center,u))<atan2(simd_dot($1-center,v),simd_dot($1-center,u))}
                    emit(hits[0],hits[1],hits[2],into:&self);emit(hits[0],hits[2],hits[3],into:&self)
                }
            }
        }}}
    }
}
