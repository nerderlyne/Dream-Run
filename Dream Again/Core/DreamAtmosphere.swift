import Foundation

/// Atmospheric image reuse is a separate compositional role, not a semantic scale event.
/// These translucent fragments transform the canvas while semantic props keep their hierarchy.
public enum DreamAtmosphericArrangement:Int,CaseIterable,Sendable {
    case aperture,canopy,submerged,suspended
}

public struct DreamAtmosphericComposition:Equatable,Sendable {
    public let arrangement:DreamAtmosphericArrangement
    public let side:Float
    public static func plan(identity:DreamIdentity,distance:Double)->Self {
        var rng=identity.stream("atmospheric-arrangement",Int(max(0,distance)/1280))
        return .init(arrangement:DreamAtmosphericArrangement(rawValue:Int(rng.below(4)))!,side:rng.below(2)==0 ? -1:1)
    }
    /// Dense silhouettes need a quieter walking surface; open water can carry more pattern.
    public var solidTrackWeight:UInt64 {arrangement == .submerged ? 40:65}
}

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
        // Sample the arrangement at this card's birth, not every frame. Staggered
        // replacement preserves gradual evolution instead of rebuilding the whole scene.
        let composition=DreamAtmosphericComposition.plan(identity:identity,distance:Double(cell)*period)
        let primary:[String],secondary:[String]
        switch composition.arrangement {
        case .aperture:
            primary=["owner_arch_stone","owner_house_pink","owner_house_miniature","owner_house_keys"]
            secondary=["owner_tree_bare","owner_tree_green"]
        case .canopy:
            primary=["owner_tree_green","owner_tree_bare","owner_orchid_purple","owner_cloud_white"]
            secondary=["owner_house_miniature","owner_arch_stone"]
        case .submerged:
            primary=["owner_jellyfish_blue","owner_ribbon_iridescent","owner_seagull"]
            secondary=["owner_arch_stone","owner_house_pink"]
        case .suspended:
            primary=["owner_house_pink","owner_house_miniature","owner_moai","owner_house_keys","owner_seagull"]
            secondary=["owner_tree_green","owner_tree_bare","owner_orchid_purple"]
        }
        let groups=[primary,secondary,["owner_cloud_white","owner_ribbon_iridescent","owner_jellyfish_blue"]]
        var rng=identity.stream("atmospheric-collage-\(slot)",cell)
        let choices=groups[slot]
        let selectedID=choices[Int(rng.below(UInt64(choices.count)))]
        let asset=DreamCollageKit.assets.first{$0.id == selectedID}!
        let depth=Float(period)+Float(180+rng.below(180))
        // Longest dimension frequently spans a substantial part of the frame, even
        // before approach. Alpha preserves superposition instead of an opaque landmark.
        let extent:Float=[composition.arrangement == .canopy ? 1.0:0.80,0.64,0.95][slot]+Float(rng.below(16))/100
        let height=depth*extent/max(1,asset.aspect)
        let side=slot==1 ? -composition.side:composition.side
        let lateral=side*depth*(slot==2 ? 0.035:slot==0 ? 0.21:0.28)
        let primaryElevation:Float
        switch composition.arrangement {
        case .aperture:primaryElevation=0.14
        case .canopy:primaryElevation=0.32
        case .submerged:primaryElevation = -0.02
        case .suspended:primaryElevation=0.30
        }
        let elevation=depth*(slot==0 ? primaryElevation:slot==1 ? 0.16:0.03)
        // A legible anchor, a quieter counterweight, and a barely perceived veil.
        // All remain large: hierarchy comes from placement and contrast, not miniaturization.
        return .init(representation:asset,cell:cell,anchorDistance:Double(cell)*period-offset(slot:slot),depth:depth,lateral:lateral,elevation:elevation,height:height,mirrored:rng.below(2)==0,roll:Float(Int(rng.below(21))-10)*0.012,opacity:[0.32,0.12,0.09][slot])
    }
}
