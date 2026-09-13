import RealityKit
import UIKit

/// Render-only vocabulary. Style indices retain their existing saved/Lab meanings.
@MainActor final class DreamMaterials {
    private var cache:[String:PhysicallyBasedMaterial]=[:]
    private var maps:[String:TextureResource]=[:]
    func make(_ tint:UIColor,style:Int)->PhysicallyBasedMaterial {
        let key="\(tint.description)/\(style)"
        if let m=cache[key] {return m}
        var m=PhysicallyBasedMaterial();m.baseColor = .init(tint:tint)
        m.roughness = .init(floatLiteral:0.72);m.specular = .init(floatLiteral:0.28)
        switch style {
        case 1: // Glazed ceramic.
            m.roughness=0.2;m.clearcoat=0.8;m.clearcoatRoughness=0.12
        case 2: // Brushed pale metal.
            m.metallic=0.88;m.roughness=0.24;m.anisotropyLevel=0.45
        case 3: // Woven velvet; deliberately no fake polygon-scale noise.
            m.roughness=0.95;m.sheen = .init(tint:UIColor(white:0.7,alpha:1))
        case 4: // Pearl / nacre.
            m.metallic=0.38;m.roughness=0.24;m.clearcoat=0.75;m.clearcoatRoughness=0.16
        case 5: // Frosted glass; environment reflection, not screen-space refraction.
            m.metallic=0.12;m.roughness=0.18;m.clearcoat=1.0
            m.blending = .transparent(opacity:.init(floatLiteral:0.55))
        case 6: m.roughness=0.38;m.clearcoat=0.18 // honed stone
        case 7: // Light emitting glaze remains lit and dimensional.
            m.roughness=0.3;m.emissiveColor = .init(color:tint);m.emissiveIntensity=0.35
        case 8: m.roughness=0.12;m.clearcoat=1.0;m.metallic=0.3 // wet stone / water
        case 9: m.roughness=1.0;m.specular=0.0 // absorptive void
        default: break
        }
        if [0,3,4,6,8].contains(style) {
            m.baseColor.texture = texture(style:style,normal:false).map{.init($0)}
            m.normal = .init(texture:texture(style:style,normal:true).map{.init($0)})
        }
        if cache.count >= 160 {cache.removeAll(keepingCapacity:true)}
        cache[key]=m;return m
    }
    private func texture(style:Int,normal:Bool)->TextureResource? {
        let key="\(style)/\(normal)";if let t=maps[key] {return t}
        let n=256
        var pixels=[UInt8](repeating:255,count:n*n*4)
            func field(_ x:Double,_ y:Double)->Double {
                let a=x/256*Double.pi*2,b=y/256*Double.pi*2
                switch style {
                case 8: return sin(a*5+sin(b*3))*0.5+sin(b*7+cos(a*2))*0.25
                case 6: return sin(a*3+sin(b*2)+0.4*sin(b*7))*0.4
                case 4: return sin(a+sin(b))*0.35
                default: return sin(a*39)*sin(b*43)*0.12+sin(a*17+b*23)*0.08
                }
            }
            for y in 0..<n {for x in 0..<n {
                let value=field(Double(x),Double(y));let color:UIColor
                if normal {
                    let strength=style == 8 ? 0.65 : style == 6 ? 0.12 : 0.18
                    let dx=(field(Double(x+1),Double(y))-value)*strength
                    let dy=(field(Double(x),Double(y+1))-value)*strength
                    color=UIColor(red:0.5-dx,green:0.5-dy,blue:1,alpha:1)
                } else if style == 4 {
                    color=UIColor(red:0.94+value*0.12,green:0.95-value*0.06,blue:0.98,alpha:1)
                } else {
                    let v=style == 8 ? 0.88+pow(max(0,value),8)*0.12 : 0.94+value*0.06
                    color=UIColor(white:v,alpha:1)
                }
                var r:CGFloat=0,g:CGFloat=0,b:CGFloat=0,a:CGFloat=0
                color.getRed(&r,green:&g,blue:&b,alpha:&a)
                let offset=(y*n+x)*4
                pixels[offset]=UInt8(max(0,min(255,r*255)))
                pixels[offset+1]=UInt8(max(0,min(255,g*255)))
                pixels[offset+2]=UInt8(max(0,min(255,b*255)))
            }}
        guard let provider=CGDataProvider(data:Data(pixels) as CFData),
              let cg=CGImage(width:n,height:n,bitsPerComponent:8,bitsPerPixel:32,bytesPerRow:n*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGBitmapInfo(rawValue:CGImageAlphaInfo.noneSkipLast.rawValue),provider:provider,decode:nil,shouldInterpolate:true,intent:.defaultIntent),
              let t=try? TextureResource.generate(from:cg,options:.init(semantic:normal ? .normal : .color)) else{return nil}
        maps[key]=t;return t
    }
}
