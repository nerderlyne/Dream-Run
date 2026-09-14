import simd

/// Truncate an icosahedron into the classic twelve pentagons and twenty hexagons.
/// Project subdivided panels onto a sphere, leaving narrow recessed stitching gaps.
enum SoccerPanels {
    static var faces:[[SIMD3<Float>]] {
        let t:Float=(1+sqrt(5))/2
        var v:[SIMD3<Float>]=[]
        for a:Float in [-1,1] {for b:Float in [-t,t] {
            v += [[0,a,b],[a,b,0],[b,0,a]]
        }}
        func adjacent(_ a:Int,_ b:Int)->Bool {a != b && abs(simd_distance(v[a],v[b])-2)<0.001}
        func cut(_ a:Int,_ b:Int)->SIMD3<Float> {(v[a]*2+v[b])/3}
        func ordered(_ points:[SIMD3<Float>])->[SIMD3<Float>] {
            let center=points.reduce(.zero,+)/Float(points.count),normal=simd_normalize(center)
            let u=simd_normalize(points[0]-center),w=simd_cross(normal,u)
            return points.sorted {atan2(simd_dot($0-center,w),simd_dot($0-center,u)) < atan2(simd_dot($1-center,w),simd_dot($1-center,u))}
        }
        var result=v.indices.map {a in ordered(v.indices.filter{adjacent(a,$0)}.map{cut(a,$0)})}
        for a in 0..<10 {for b in (a+1)..<11 where adjacent(a,b) {for c in (b+1)..<12 where adjacent(a,c) && adjacent(b,c) {
            result.append(ordered([cut(a,b),cut(b,a),cut(b,c),cut(c,b),cut(c,a),cut(a,c)]))
        }}}
        return result
    }
    static func make(lod:Int)->(white:Geometry,black:Geometry) {
        var white=Geometry(),black=Geometry()
        for face in faces {
            let center=face.reduce(.zero,+)/Float(face.count)
            let inset=face.map{center+($0-center)*0.975}
            var panel=Geometry()
            func triangle(_ a:SIMD3<Float>,_ b:SIMD3<Float>,_ c:SIMD3<Float>,_ depth:Int) {
                if depth>0 {
                    let ab=(a+b)/2,bc=(b+c)/2,ca=(c+a)/2
                    triangle(a,ab,ca,depth-1);triangle(ab,b,bc,depth-1)
                    triangle(ca,bc,c,depth-1);triangle(ab,bc,ca,depth-1)
                } else {
                    let base=UInt32(panel.positions.count)
                    for p in [a,b,c] {let n=simd_normalize(p);panel.positions.append(n*0.45+[0,0.45,0]);panel.normals.append(n)}
                    panel.indices += [base,base+1,base+2]
                }
            }
            for i in inset.indices {triangle(center,inset[i],inset[(i+1)%inset.count],lod==2 ? 1:2)}
            if face.count==5 {append(panel,to:&black)} else {append(panel,to:&white)}
        }
        return (white,black)
    }
    private static func append(_ source:Geometry,to target:inout Geometry) {
        let base=UInt32(target.positions.count)
        target.positions += source.positions;target.normals += source.normals
        target.indices += source.indices.map{$0+base}
    }
}
