import RealityKit
import UIKit

/// Registered cloud family (#24), rendered as a shaded, soft-edged impostor at landscape scale.
/// Original procedural texture; no reference photograph is shipped or sampled.
@MainActor final class CloudBank {
    private var texture:TextureResource?
    private var opacity:TextureResource?
    private var mesh:MeshResource?
    func make(tint:UIColor)->Entity {
        if texture == nil {
            let format=UIGraphicsImageRendererFormat();format.scale=1
            let image=UIGraphicsImageRenderer(size:CGSize(width:512,height:256),format:format).image {context in
                let c=context.cgContext
                // Back-to-front cloud lobes. Offset highlights give the bank an internal light direction.
                for row in 0..<3 {for i in 0..<48 {
                    let x=Double(40+(i*137)%430),profile=sqrt(max(0,1-pow((x-256)/250,2)))
                    let y=170-profile*Double(20+(i*17)%70)+Double(row)*9
                    let radius=Double(25+(i*23)%34)
                    let colors=[UIColor(red:1,green:0.98,blue:0.97,alpha:0.92).cgColor,UIColor(red:0.77,green:0.78,blue:0.85,alpha:0.7).cgColor,UIColor(red:0.66,green:0.66,blue:0.76,alpha:0).cgColor] as CFArray
                    c.saveGState();c.translateBy(x:x,y:y);c.scaleBy(x:1.25,y:0.85)
                    if let g=CGGradient(colorsSpace:CGColorSpaceCreateDeviceRGB(),colors:colors,locations:[0,0.64,1]) {c.drawRadialGradient(g,startCenter:CGPoint(x:-radius*0.2,y:-radius*0.45),startRadius:0,endCenter:.zero,endRadius:radius,options:[])}
                    c.restoreGState()
                }}
            }
            if let cg=image.cgImage {
                var bytes=[UInt8](repeating:0,count:512*256*4)
                if let ctx=CGContext(data:&bytes,width:512,height:256,bitsPerComponent:8,bytesPerRow:512*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) {
                    ctx.draw(cg,in:CGRect(x:0,y:0,width:512,height:256))
                    var mask=[UInt8](repeating:255,count:bytes.count)
                    for y in 0..<256 {for x in 0..<512 {
                        let edge=max(0,min(1,min(Float(min(x,511-x))/50,Float(min(y,255-y))/35)))
                        let fade=edge*edge*(3-2*edge),i=(y*512+x)*4
                        let a=UInt8(Float(bytes[i+3])*fade)
                        for c in 0..<4 {bytes[i+c]=UInt8(Float(bytes[i+c])*fade)}
                        mask[i]=a;mask[i+1]=a;mask[i+2]=a
                    }}
                    func resource(_ data:[UInt8],alpha:CGImageAlphaInfo)->TextureResource? {
                        guard let provider=CGDataProvider(data:Data(data) as CFData),let bitmap=CGImage(width:512,height:256,bitsPerComponent:8,bitsPerPixel:32,bytesPerRow:512*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGBitmapInfo(rawValue:alpha.rawValue),provider:provider,decode:nil,shouldInterpolate:true,intent:.defaultIntent) else{return nil}
                        return try? TextureResource.generate(from:bitmap,options:.init(semantic:.color))
                    }
                    texture=resource(bytes,alpha:.premultipliedLast);opacity=resource(mask,alpha:.noneSkipLast)
                }
            }
            var d=MeshDescriptor(name:"Cloud bank impostor")
            d.positions = .init([[-2.5,-1.25,0],[2.5,-1.25,0],[2.5,1.25,0],[-2.5,1.25,0]])
            d.normals = .init(Array(repeating:SIMD3<Float>(0,0,1),count:4));d.textureCoordinates = .init([[0,0],[1,0],[1,1],[0,1]]);d.primitives = .triangles([0,1,2,0,2,3]);mesh=try? MeshResource.generate(from:[d])
        }
        let root=Entity();root.name="asset:24"
        if let texture,let opacity,let mesh {
            var m=PhysicallyBasedMaterial();m.baseColor = .init(tint:tint,texture:.init(texture));m.roughness=1.0;m.specular=0.0
            m.blending = .transparent(opacity:.init(scale:1,texture:.init(opacity)));m.faceCulling = .none
            m.emissiveColor = .init(color:tint,texture:.init(texture));m.emissiveIntensity=0.14
            let model=ModelEntity(mesh:mesh,materials:[m]);model.name="atmosphere-cloud";root.addChild(model);root.components.set(BillboardComponent())
        }
        return root
    }
}
