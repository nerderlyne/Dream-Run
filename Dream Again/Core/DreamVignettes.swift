import Foundation

/// Four independently layered ingredients, one coherent seeded occurrence.
public enum DreamVignette:Int,CaseIterable,Sendable {
    case horseAtHome,seaGarden,uninvitedMonuments,borrowedAddress,littleLostThings
    public var title:String { ["Horse at home","Sea garden","Uninvited monuments","Borrowed address","Little lost things"][rawValue] }
    public var ingredients:[String] {
        switch self {
        case .horseAtHome:return ["owner_horse_running","owner_house_pink","owner_cloud_white","owner_seagull"]
        case .seaGarden:return ["owner_jellyfish_blue","owner_orchid_purple","owner_tree_bare","owner_ribbon_iridescent"]
        case .uninvitedMonuments:return ["owner_trojan_horse","owner_moai","owner_moon_full","owner_arch_stone"]
        case .borrowedAddress:return ["owner_house_miniature","owner_house_keys","owner_jupiter","owner_sun"]
        case .littleLostThings:return ["owner_candy_cane","owner_dog","owner_orange","owner_mouth"]
        }
    }
    public static func selected(identity:DreamIdentity,cell:Int)->Self {
        var bag=allCases,rng=identity.stream("vignette-bag",cell/5)
        for i in stride(from:bag.count-1,through:1,by:-1) {bag.swapAt(i,Int(rng.below(UInt64(i+1))))}
        return bag[max(0,cell)%5]
    }
    public func ingredients(identity:DreamIdentity,cell:Int)->[String] {
        ingredients
    }
    public func placement(identity:DreamIdentity,distance:Double,part:Int,scaleEvent:DreamScaleEvent?=nil)->DreamCollagePlacement {
        let cell=Int(floor(distance/640)),anchor=Double(cell)*640
        var rng=identity.stream("vignette-position",cell)
        let side:Float=rng.below(2)==0 ? -1:1
        let heights:[Float]=self == .littleLostThings ? [44,48,29,24]:[90,52,85,43]
        let offsets:[SIMD2<Float>]=self == .littleLostThings ? [[-18,16],[17,0],[57,47],[-45,48]]:[[0,38],[23,-15],[-35,30],[58,49]]
        let asset=DreamCollageKit.assets.first{$0.id == ingredients(identity:identity,cell:cell)[part]}!
        let scale=DreamScaleComposition.plan(identity:identity,distance:distance,override:scaleEvent)
        let composed=scale.compose(.init(representation:asset,cell:cell,anchorDistance:anchor,depth:500+Float(part)*9,lateral:side*(52+offsets[part].x),elevation:55+offsets[part].y,height:heights[part],mirrored:side<0,roll:self == .uninvitedMonuments && part==0 ? .pi:0,opacity:part==2 && self != .littleLostThings ? 0.65:1),slot:16+part)
        return composed
    }
}

public struct DreamScenicMotion:Equatable,Sendable {
    public let offset:SIMD2<Float>
    public let roll:Float
    public let scale:Float
    public static func sample(id:String,seconds:Double,slot:Int,reduced:Bool=false)->Self {
        guard !reduced else{return .init(offset:.zero,roll:0,scale:1)}
        let phase=Double(SplitMix64.fnv(id)%1000)/1000*2*Double.pi
        let t=seconds*0.22+phase
        if id.contains("jellyfish") || id.contains("bubbles") {return .init(offset:[Float(sin(t))*2,Float(sin(t*0.6))*6],roll:Float(sin(t))*0.03,scale:1+Float(sin(t*1.5))*0.025)}
        let drift:Float=id.contains("whale") || id.contains("manta") ? 9:3
        return .init(offset:[Float(sin(t))*drift,Float(cos(t*0.7))*2.5],roll:Float(sin(t*0.6))*0.025,scale:1)
    }
}
