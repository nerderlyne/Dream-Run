#!/usr/bin/env swift
import AppKit

struct RepostCard {
    let id:String
    let source:String
    let handle:String
    let stamp:String
    let body:String
    let reply:String
    let tint:NSColor
}

let cards:[RepostCard] = [
    .init(id:"repost_chicken_recipe",source:"chicken_chef",handle:"no_subject",stamp:"03:17:04",body:"the chicken was already cooking when i arrived",reply:">>2048  it has never learned a recipe",tint:NSColor(calibratedRed:0.91,green:0.69,blue:0.67,alpha:1)),
    .init(id:"repost_whale_carpet",source:"whale_opal",handle:"deadlink_88",stamp:"00:00:13",body:"found the whale beneath the carpet again",reply:"reposted 17 times",tint:NSColor(calibratedRed:0.62,green:0.78,blue:0.82,alpha:1)),
    .init(id:"repost_seahorse_memory",source:"seahorse_gold",handle:"salt_user",stamp:"04:44:02",body:"does anyone remember when this was a horse",reply:">> nobody remembers the land",tint:NSColor(calibratedRed:0.85,green:0.74,blue:0.46,alpha:1)),
    .init(id:"repost_pink_horse",source:"horse_pink",handle:"guest_000",stamp:"tomorrow",body:"same horse. smaller moon. no explanation.",reply:"image reuploaded 31 times",tint:NSColor(calibratedRed:0.88,green:0.62,blue:0.76,alpha:1)),
    .init(id:"repost_ocean_phone",source:"telephone_banana",handle:"anonymous",stamp:"02:11:52",body:"phone rang. there was ocean on the line",reply:">> do not answer it twice",tint:NSColor(calibratedRed:0.88,green:0.80,blue:0.48,alpha:1)),
    .init(id:"repost_weather_tv",source:"tv_cloud",handle:"archived_weather",stamp:"23:59:59",body:"television grew weather overnight",reply:"attachment recovered from cache",tint:NSColor(calibratedRed:0.60,green:0.70,blue:0.84,alpha:1)),
    .init(id:"repost_roomless_chair",source:"chair_velvet",handle:"roomless",stamp:"12:04:08",body:"the chair keeps waiting where the room should be",reply:">> seat occupied by previous version",tint:NSColor(calibratedRed:0.72,green:0.57,blue:0.72,alpha:1)),
    .init(id:"repost_jelly_memory",source:"jellyfish_lilac",handle:"unknown",stamp:"05:20:17",body:"this image remembers being underwater",reply:"compression level: inherited",tint:NSColor(calibratedRed:0.68,green:0.62,blue:0.83,alpha:1))
]

let root=URL(fileURLWithPath:FileManager.default.currentDirectoryPath)
let directory=root.appendingPathComponent("Dream Again/Resources/DreamCollage")

func font(_ size:CGFloat,_ weight:NSFont.Weight = .regular)->NSFont {
    NSFont.monospacedSystemFont(ofSize:size,weight:weight)
}
func text(_ value:String,in rect:NSRect,font:NSFont,color:NSColor) {
    let style=NSMutableParagraphStyle();style.lineBreakMode = .byWordWrapping
    (value as NSString).draw(in:rect,withAttributes:[.font:font,.foregroundColor:color,.paragraphStyle:style])
}
func compressed(_ source:NSImage,tint:NSColor,index:Int)->NSImage {
    let tiny=NSImage(size:NSSize(width:92,height:92))
    tiny.lockFocus()
    tint.withAlphaComponent(0.30).setFill();NSRect(x:0,y:0,width:92,height:92).fill()
    NSGraphicsContext.current?.imageInterpolation = .low
    let scale=max(92/source.size.width,92/source.size.height)
    let size=NSSize(width:source.size.width*scale,height:source.size.height*scale)
    source.draw(in:NSRect(x:(92-size.width)/2+CGFloat(index%3-1)*5,y:(92-size.height)/2,width:size.width,height:size.height),from:.zero,operation:.sourceOver,fraction:0.92)
    tiny.unlockFocus()
    guard let tiff=tiny.tiffRepresentation,let rep=NSBitmapImageRep(data:tiff),
          let jpg=rep.representation(using:.jpeg,properties:[.compressionFactor:0.13+Double(index%3)*0.04]),
          let result=NSImage(data:jpg) else {return tiny}
    return result
}

for (index,card) in cards.enumerated() {
    let sourceURL=directory.appendingPathComponent(card.source).appendingPathExtension("png")
    guard let source=NSImage(contentsOf:sourceURL) else {fatalError("Missing \(sourceURL.path)")}
    let degraded=compressed(source,tint:card.tint,index:index)
    let canvas=NSImage(size:NSSize(width:512,height:384))
    canvas.lockFocus()
    NSColor.clear.setFill();NSRect(x:0,y:0,width:512,height:384).fill()
    let panel=NSRect(x:16,y:16,width:480,height:352)
    NSColor(calibratedWhite:0.90,alpha:0.96).setFill();panel.fill()
    card.tint.withAlphaComponent(0.78).setFill();NSRect(x:16,y:330,width:480,height:38).fill()
    NSColor(calibratedWhite:0.16,alpha:0.80).setStroke()
    let border=NSBezierPath(rect:panel);border.lineWidth=3;border.stroke()
    NSGraphicsContext.current?.imageInterpolation = .none
    degraded.draw(in:NSRect(x:34,y:66,width:244,height:244),from:.zero,operation:.sourceOver,fraction:1)
    // A displaced, low-alpha duplicate makes the repost history visible without a watermark.
    degraded.draw(in:NSRect(x:43,y:57,width:244,height:244),from:.zero,operation:.sourceOver,fraction:0.13)
    text("/dream/archive/  \(card.handle)",in:NSRect(x:29,y:337,width:300,height:22),font:font(14,.bold),color:.black)
    text(card.stamp,in:NSRect(x:374,y:337,width:105,height:22),font:font(13),color:.black)
    text(card.body,in:NSRect(x:296,y:194,width:176,height:110),font:font(16,.medium),color:NSColor(calibratedWhite:0.10,alpha:1))
    text(card.reply,in:NSRect(x:296,y:91,width:176,height:82),font:font(13),color:NSColor(calibratedRed:0.28,green:0.34,blue:0.25,alpha:1))
    text("IMG_\(String(format:"%04d",index*137+41)).JPG  38 KB",in:NSRect(x:32,y:32,width:400,height:20),font:font(11),color:NSColor(calibratedWhite:0.35,alpha:1))
    for y in stride(from:20,to:368,by:6) {
        NSColor(calibratedWhite:index%2 == 0 ? 0:1,alpha:0.022).setFill()
        NSRect(x:18,y:y,width:476,height:1).fill()
    }
    canvas.unlockFocus()
    guard let tiff=canvas.tiffRepresentation,let bitmap=NSBitmapImageRep(data:tiff),
          let png=bitmap.representation(using:.png,properties:[:]) else {fatalError("Could not encode \(card.id)")}
    let output=directory.appendingPathComponent(card.id).appendingPathExtension("png")
    try png.write(to:output,options:.atomic)
    print(card.id)
}
