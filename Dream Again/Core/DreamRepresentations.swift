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
    public var resourceExtension:String {isPlate ? "jpg":"png"}
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
        let interactive:Set<AssetID>=[.trackStraight,.trackCurve,.trackRamp,.stairsStraight,.stairsSpiral,.platform,.trackBroken,.column,.mirror,.window,.bed,.chair,.moon,.cloud,.balloon,.soccer,.eightBall,.softball,.americanFootball,.nazar,.clover,.horse,.zebra,.rabbit,.pig]
        return .init(semanticID:id,requiresGameplay3D:interactive.contains(id),representations:DreamCollageKit.assets.filter{$0.concept == id})
    }
    public static func definition(for id:AssetID)->DreamConceptDefinition {concepts[id.rawValue-1]}
}
public enum DreamMemeLibrary {public static let entries=["chicken_chef","stove_chrome","tv_cloud","telephone_banana"]}

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
    public var scaleRole:DreamScaleRole = .ordinary
}
public enum DreamCollageComposition {
    public static let slotCount=20
    public static func period(slot:Int)->Double {slot>=16 ? 640:slot<4 ? 768:slot<12 ? 384:192}
    public static func cell(distance:Double,slot:Int)->Int {Int(floor((distance+(slot>=16 ? 0:Double(slot)*period(slot:slot)/16))/period(slot:slot)))}
    public static let proofSeeds:[UInt64]=[42,117,802,2026,9001]
    public static func plate(identity:DreamIdentity,section:Int,transition:Int=0)->DreamRepresentation {
        let plates=DreamPlateLibrary.assets
        let ordinal=max(0,section)+max(0,transition)
        let cycle=ordinal/plates.count
        func deck(_ index:Int)->[DreamRepresentation] {
            var values=plates,rng=identity.stream("collage-sky-deck",index)
            for i in stride(from:values.count-1,through:1,by:-1) {values.swapAt(i,Int(rng.below(UInt64(i+1))))}
            return values
        }
        var values=deck(cycle)
        if cycle>0 && values.first?.id == deck(cycle-1).last?.id {values.swapAt(0,1)}
        return values[ordinal%plates.count]
    }

    public static func placement(identity:DreamIdentity,distance:Double,slot:Int,scaleEvent:DreamScaleEvent?=nil,framing:DreamScaleFraming?=nil)->DreamCollagePlacement {
        let scale=DreamScaleComposition.plan(identity:identity,distance:distance,override:scaleEvent,framing:framing)
        if slot>=16 {return DreamVignette.selected(identity:identity,cell:cell(distance:distance,slot:slot)).placement(identity:identity,distance:distance,part:slot-16,scaleEvent:scaleEvent)}
        let period=period(slot:slot)
        let offset=Double(slot)*period/16
        let cell=Int(floor((distance+offset)/period))
        let anchor=Double(cell)*period-offset
        var rng=identity.stream("collage-slot-\(slot)",cell)
        let families:Set<AssetID>=slot<4 ? [.moon,.cloud,.house,.arch,.rock,.water,.seaCreatures] : slot<12 ? [.horse,.tree,.house,.arch,.window,.chair,.bed,.flower,.seaCreatures,.rock] : [.cloud,.tree,.water,.ribbon,.flower]
        let choices=DreamCollageKit.assets.filter{$0.concept.map{families.contains($0)} ?? false}
        // A shuffled deck visits every eligible ingredient before repeating it in this slot.
        func deck(_ cycle:Int)->[DreamRepresentation] {
            var values=choices,r=identity.stream("collage-deck-\(slot)",cycle)
            for j in stride(from:values.count-1,through:1,by:-1) {values.swapAt(j,Int(r.below(UInt64(j+1))))}
            return values
        }
        let cycle=max(0,cell)/choices.count
        var bag=deck(cycle)
        if cycle>0 && bag.first?.id == deck(cycle-1).last?.id {bag.swapAt(0,1)}
        var asset=bag[max(0,cell)%bag.count]
        if slot==0 && scale.event != .none {
            let variants=DreamCollageKit.assets.filter{$0.concept == scale.concept}
            asset=variants[scale.scene%variants.count]
        }
        let concept=asset.concept!
        let depth=Float(period)+Float(80+rng.below(120))
        let height=depth*(concept == .moon ? 0.16 : concept == .cloud ? 0.13 : 0.12)+depth*Float(rng.below(100))/1000
        let side:Float=rng.below(2)==0 ? -1:1
        let lateral=side*depth*(0.10+Float(rng.below(160))/1000)
        let elevation=concept == .moon ? depth*(0.20+Float(rng.below(180))/1000) : concept == .cloud ? depth*Float(rng.below(200))/1000 : height*0.42-12+depth*Float(rng.below(100))/1000
        return scale.compose(.init(representation:asset,cell:cell,anchorDistance:anchor,depth:depth,lateral:lateral,elevation:elevation,height:height,mirrored:rng.below(2)==0,roll:concept == .house && rng.below(4)==0 ? .pi : 0,opacity:concept == .moon ? 0.52 : concept == .cloud ? 0.28 : slot<8 ? 0.88 : 0.96),slot:slot)
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
