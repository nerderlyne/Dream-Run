import Foundation

/// Atmospheric image reuse is a separate compositional role, not a semantic scale event.
/// These translucent fragments transform the canvas while semantic props keep their hierarchy.
public enum DreamAtmosphere {
    public static let slotCount=3
    public static func period(slot:Int)->Double {[1280,1024,768][slot]}
    public static func offset(slot:Int)->Double {period(slot:slot)*Double(slot+1)/4}
    public static func cell(distance:Double,slot:Int)->Int {Int(floor((distance+offset(slot:slot))/period(slot:slot)))}
    public static func weight(density:Float,slot:Int,lowPower:Bool=false)->Float {
        if lowPower && slot>0 {return 0}
        let threshold:[Float]=[0,0.32,0.65]
        return max(0,min(1,(density-threshold[slot])/0.25))
    }
    public static func placement(identity:DreamIdentity,distance:Double,slot:Int)->DreamCollagePlacement {
        let period=period(slot:slot),cell=cell(distance:distance,slot:slot)
        let groups=[
            ["house_brutal","window_aqua","arch_ruined","house_photo","window_pink","house_stilt"],
            ["tree_oak","tree_fuzzy","tree_blue","flower_orchid","jellyfish_lilac","tree_dead"],
            ["ribbon_iridescent","fog_lavender","cloud_tower","water_curtain","fog_silver","cloud_pink"]
        ]
        var rng=identity.stream("atmospheric-collage-\(slot)",cell)
        let choices=groups[slot]
        let selectedID=choices[Int(rng.below(UInt64(choices.count)))]
        let asset=DreamCollageKit.assets.first{$0.id == selectedID}!
        let depth=Float(period)+Float(180+rng.below(180))
        // Longest dimension frequently spans a substantial part of the frame, even
        // before approach. Alpha preserves superposition instead of an opaque landmark.
        let extent:Float=[0.72,0.62,0.95][slot]+Float(rng.below(20))/100
        let height=depth*extent/max(1,asset.aspect)
        let side:Float=(slot+Int(rng.below(2)))%2==0 ? -1:1
        let lateral=side*depth*(slot==2 ? 0.035:0.19)
        let elevation:Float=slot==2 ? depth*0.03:slot==0 ? depth*0.10:depth*0.18
        return .init(representation:asset,cell:cell,anchorDistance:Double(cell)*period-offset(slot:slot),depth:depth,lateral:lateral,elevation:elevation,height:height,mirrored:rng.below(2)==0,roll:Float(Int(rng.below(21))-10)*0.012,opacity:[0.27,0.22,0.20][slot])
    }
}
