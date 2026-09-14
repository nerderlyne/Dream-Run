import Foundation
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers
let manifest=try JSONSerialization.jsonObject(with:Data(contentsOf:URL(fileURLWithPath:CommandLine.arguments[1]))) as! [[String:Any]]
for entry in manifest {
    let id=entry["id"] as! String,path=entry["source"] as! String
    let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil)!
    let original=CGImageSourceCreateImageAtIndex(source,0,nil)!
    let ratio=min(1,480.0/Double(max(original.width,original.height)))
    let w=Int(Double(original.width)*ratio),h=Int(Double(original.height)*ratio)
    let context=CGContext(data:nil,width:w+32,height:h+32,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.interpolationQuality = .high
    context.draw(original,in:CGRect(x:16,y:16,width:w,height:h))
    let image=context.makeImage()!
    let url=URL(fileURLWithPath:"Dream Again/Resources/DreamCollage/\(id).png")
    let destination=CGImageDestinationCreateWithURL(url as CFURL,UTType.png.identifier as CFString,1,nil)!
    CGImageDestinationAddImage(destination,image,nil)
    guard CGImageDestinationFinalize(destination) else{fatalError("PNG write failed")}
    print(id)
}
