import Foundation

/// Original dream imagery made to resemble an image-board repost history. These are
/// cultural apparitions, not imported internet memes or another world family.
public enum DreamRepostKit {
    public static let assets:[DreamRepresentation] = [
        "repost_chicken_recipe","repost_whale_carpet","repost_seahorse_memory","repost_pink_horse",
        "repost_ocean_phone","repost_weather_tv","repost_roomless_chair","repost_jelly_memory"
    ].map {
        .init(id:$0,concept:.culturalApparitions,medium:.graphic,orientation:"forumRepost",moods:["dreamlike","uncanny","archived"],paletteTags:["compressed"],depths:[.midground,.background],backgroundOnly:true,interactive:false,rarity:5,alphaBounds:[16,16,495,367],pixelSize:[512,384],recommendedScaleRange:[18,120])
    }

    public static func selected(identity:DreamIdentity,cell:Int,count:Int=2)->[DreamRepresentation] {
        var values=assets,rng=identity.stream("repost-thread",cell)
        for i in stride(from:values.count-1,through:1,by:-1) {values.swapAt(i,Int(rng.below(UInt64(i+1))))}
        return Array(values.prefix(max(0,min(count,values.count))))
    }
}
