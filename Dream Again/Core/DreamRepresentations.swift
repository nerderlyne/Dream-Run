import Foundation

public enum DreamVisualMedium:String,Codable,CaseIterable,Sendable {
    case photographic, surrealCGI, painterly, graphic, liminal, void
}
public enum DreamDepthLayer:String,Codable,CaseIterable,Sendable {case gameplay,near,midground,background}

/// Metadata for a single ingredient. Pixel bounds use a top-left origin, inclusive maxima.
public struct DreamRepresentation:Codable,Equatable,Sendable {
    public let id:String
    public let concept:AssetID?
    public let medium:DreamVisualMedium
    public let orientation:String
    public let moods:[String]
    public let paletteTags:[String]
    public let depths:[DreamDepthLayer]
    public let backgroundOnly:Bool
    public let interactive:Bool
    public let rarity:Int
    public let alphaBounds:[Int]
    public let pixelSize:[Int]
    public let recommendedScaleRange:[Double]
    public var resource:String {id}
    public var isPlate:Bool {concept == nil}
    public var aspect:Float {Float(pixelSize[0])/Float(pixelSize[1])}
}

public struct DreamConceptDefinition:Sendable {
    public let semanticID:AssetID
    public let requiresGameplay3D:Bool
    public let representations:[DreamRepresentation]
    public var proceduralRepresentationID:String {"\(semanticID)-3d"}
}
public enum DreamRepresentationRegistry {
    public static let concepts:[DreamConceptDefinition] = AssetID.allCases.map { id in
        let interactive:Set<AssetID>=[.trackStraight,.trackCurve,.trackRamp,.stairsStraight,.stairsCurve,.stairsSpiral,.platform,.trackBroken,.column,.mirror,.window,.bed,.chair,.moon,.cloud,.balloon,.soccer,.eightBall,.softball,.americanFootball,.nazar,.clover,.horse,.zebra,.rabbit,.pig]
        return .init(semanticID:id,requiresGameplay3D:interactive.contains(id),representations:DreamCollageKit.assets.filter{$0.concept == id})
    }
    public static func definition(for id:AssetID)->DreamConceptDefinition {concepts[id.rawValue-1]}
}
public enum DreamMemeLibrary {public static let entries:[String]=[]}

/// A stable slot description. All positions derive from distance cells, never load timing.
public struct DreamCollagePlacement:Equatable,Sendable {
    public let representation:DreamRepresentation
    public let cell:Int
    public let anchorDistance:Double
    public let depth:Float
    public let lateral:Float
    public let elevation:Float
    public let height:Float
    public let mirrored:Bool
    public let roll:Float
    public let opacity:Float
}
public enum DreamCollageComposition {
    public static let slotCount=16
    public static let proofSeeds:[UInt64]=[42,117,802,2026,9001]
    public static func plate(identity:DreamIdentity,section:Int,transition:Int=0)->DreamRepresentation {
        var rng=identity.stream("collage-sky",section)
        let plates=DreamCollageKit.assets.filter(\.isPlate)
        let initial=Int(rng.below(UInt64(plates.count)))
        return plates[(initial+transition*4)%plates.count]
    }
    public static func placement(identity:DreamIdentity,distance:Double,slot:Int)->DreamCollagePlacement {
        let period=slot<4 ? 768.0 : slot<12 ? 384.0 : 192.0
        let offset=Double(slot)*period/Double(slotCount)
        let cell=Int(floor((distance+offset)/period))
        let anchor=Double(cell)*period-offset
        var rng=identity.stream("collage-slot-\(slot)",cell)
        let families:[AssetID]=slot == 0 ? [.moon] : slot<4 ? [.moon,.cloud,.cloud,.house,.arch] : slot<12 ? [.horse,.horse,.tree,.tree,.house,.arch,.window] : [.cloud,.cloud,.tree]
        let concept=families[Int(rng.below(UInt64(families.count)))]
        let choices=DreamCollageKit.assets.filter{$0.concept == concept}
        // Inverse rarity weights; iteration order is checked in the kit contract.
        let weights=choices.map{max(1,12/$0.rarity)},total=weights.reduce(0,+)
        var pick=Int(rng.below(UInt64(total))),index=0
        for i in choices.indices {if pick<weights[i] {index=i;break};pick-=weights[i]}
        let asset=choices[index]
        let depth=Float(period)+Float(80+rng.below(120))
        let height=depth*(concept == .moon ? 0.16 : concept == .cloud ? 0.13 : 0.12)+depth*Float(rng.below(100))/1000
        let side:Float=rng.below(2)==0 ? -1:1
        let lateral=side*depth*(0.10+Float(rng.below(160))/1000)
        let elevation=concept == .moon ? depth*(0.20+Float(rng.below(180))/1000) : concept == .cloud ? depth*Float(rng.below(200))/1000 : height*0.42-12+depth*Float(rng.below(100))/1000
        return .init(representation:asset,cell:cell,anchorDistance:anchor,depth:depth,lateral:lateral,elevation:elevation,height:height,mirrored:rng.below(2)==0,roll:concept == .house && rng.below(4)==0 ? .pi : 0,opacity:concept == .moon ? 0.52 : concept == .cloud ? 0.28 : slot<8 ? 0.88 : 0.96)
    }
    public static func density(seconds:Double,visual:VisualPhase,voidWeight:Double)->Float {
        let cycle=seconds.truncatingRemainder(dividingBy:10800)
        switch visual {
        case .luckyWhite,.deepSparse:return 0
        case .deepStripping:return Float(max(0,1-cycle/240))
        case .deepRebuilding:return Float(min(1,max(0,(cycle-300)/300)))
        default:return Float((0.64+0.36*cos(seconds/190))*(1-voidWeight))
        }
    }
}
