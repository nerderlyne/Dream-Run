import Foundation
import ImageIO
import CoreGraphics

// Read-only alpha audit: an alpha channel alone does not prove a useful cutout.
for path in CommandLine.arguments.dropFirst() {
    guard let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil),
          let image=CGImageSourceCreateImageAtIndex(source,0,nil) else {fatalError("Cannot decode \(path)")}
    let w=image.width,h=image.height
    var pixels=[UInt8](repeating:0,count:w*h*4)
    let ctx=CGContext(data:&pixels,width:w,height:h,bitsPerComponent:8,bytesPerRow:w*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.draw(image,in:CGRect(x:0,y:0,width:w,height:h))
    var clear=0,solid=0,partial=0,edge=0,minX=w,minY=h,maxX=0,maxY=0
    var occupiedCount=0,occupiedAlphaSum=0
    for y in 0..<h {for x in 0..<w {
        let a=pixels[(y*w+x)*4+3]
        if a == 0 {clear += 1} else if a == 255 {solid += 1} else {partial += 1}
        if a > 16 {minX=min(minX,x);minY=min(minY,y);maxX=max(maxX,x);maxY=max(maxY,y);occupiedCount+=1;occupiedAlphaSum+=Int(a)}
        if (x==0 || y==0 || x==w-1 || y==h-1) && a > 16 {edge += 1}
    }}
    let report:[String:Any] = ["file":path,"width":w,"height":h,"clearFraction":Double(clear)/Double(w*h),"solidFraction":Double(solid)/Double(w*h),"partialFraction":Double(partial)/Double(w*h),"occupiedEdgePixels":edge,"alphaBounds":[minX,minY,maxX,maxY],"meanOccupiedAlpha":Double(occupiedAlphaSum)/Double(max(1,occupiedCount))]
    let data=try JSONSerialization.data(withJSONObject:report,options:[.sortedKeys])
    print(String(decoding:data,as:UTF8.self))
}
