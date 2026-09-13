import Foundation

public enum AssetID: Int, Codable, CaseIterable, Sendable {
    case trackStraight = 1, trackCurve, trackRamp, stairsStraight, stairsCurve, stairsSpiral, platform, trackBroken, arch, column, mirror, window, roomShell, house, tower, fountain, chair, bed, tree, flower, mushroom, rock, mountain, cloud, water, moon, balloon, heart, star, soccer, eightBall, softball, americanFootball, nazar, ribbon, curtain, clover, rail, horse, zebra, rabbit, pig
}
public enum Encounter: String, Codable, CaseIterable, Sendable { case breathing, dodge, rolling, gap, slide, jump, mirror, drop }
public struct RouteSample: Codable, Equatable, Sendable {
    public var x: Double; public var y: Double; public var z: Double; public var yaw: Double
}
public struct SafeDropContract: Codable, Equatable, Sendable {
    public var departure: Double
    public var landing: Double
    public var lowerBy: Double = 3
    public var validated: Bool { landing > departure && landing - departure <= 18 && lowerBy == 3 }
}
public struct HazardDescription: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var asset: AssetID
    public var encounter: Encounter
    public var distance: Double
    public var lateral: Double
    public var radius: Double
    public var height: Double
    public var speed: Double = 0
    public var spawnTick: UInt64 = 0
    public var resolved = false
    public var pig: PigDecision? = nil
    public func position(at tick: UInt64) -> Double { distance - Double(tick >= spawnTick ? tick - spawnTick : 0) / 60 * speed }
    public var fatal: Bool { asset == .rabbit || asset == .nazar || encounter == .slide }
}
public struct PickupDescription: Codable, Equatable, Identifiable, Sendable {
    public var id: String; public var distance: Double; public var lateral: Double; public var height: Double = 0.9
}
public struct SceneryPlacement: Codable, Equatable, Sendable {
    public var asset: AssetID; public var distance: Double; public var lateral: Double; public var scale: Double
}
public struct ChunkDescription: Codable, Equatable, Identifiable, Sendable {
    public var id: Int
    public var routeFamily: AssetID
    public var start: Double
    public var hazards: [HazardDescription]
    public var pickups: [PickupDescription]
    public var scenery: [SceneryPlacement]
    public var recipe: Int
    public var gap: ClosedRange<Double>?
    public var drop: SafeDropContract?
    public var candidateAttempts=1
    public var fallbackReason:String?
    public var end: Double { start + 24 }
}
public struct WorldGenerator: Sendable {
    public let identity: DreamIdentity
    public init(_ identity: DreamIdentity) { self.identity = identity }
    // Bounded analytic route: all modules use the same endpoint function. Curvature < 1/24 m.
    public func sample(_ s: Double) -> RouteSample {
        let nonnegative=max(0,s), block=Int(nonnegative/1800), within=nonnegative-Double(block)*1800
        let radius=100.0, loopLength=2*Double.pi*radius
        let loopProgress=max(0,min(loopLength,within-1080)),angle=loopProgress/radius
        let inLoop=within >= 1080 && within < 1080+loopLength
        var shape=identity.stream("route",0)
        let sign=shape.below(2) == 0 ? -1.0 : 1.0
        let x=5*sin(s/120)+sign*radius*(1-cos(angle))
        let z = -s + Double(block)*loopLength + loopProgress-radius*sin(angle)
        let dx=5.0/120*cos(s/120)+(inLoop ? sign*sin(angle) : 0)
        let dz=inLoop ? -cos(angle) : -1
        var y=2.5*sin(s/100)+Double(block)*(loopLength*0.05-3)+loopProgress*0.05
        if within >= 900 { y -= 3*min(1,(within-900)/16) }
        return RouteSample(x:x,y:y,z:z,yaw:atan2(dx,-dz))
    }

    public func chunk(_ index: Int, tutorial: Bool = false) -> ChunkDescription {
        let start = Double(index) * 24
        var route = identity.stream("route", 0), rng = identity.stream("hazards", index / 2), scenery = identity.stream("scenery", index)
        let families: [AssetID] = [.trackStraight,.trackCurve,.trackRamp,.stairsStraight,.stairsCurve,.stairsSpiral,.platform]
        var mood=identity.stream("mood",0)
        let recipe=(Int(mood.below(6))+index/18)%6
        var result = ChunkDescription(id: index, routeFamily: families[(Int(route.below(7))+index/2)%7], start: start, hazards: [], pickups: [], scenery: [], recipe: recipe)
        let anchor = Double(index / 2) * 48 + 36
        if index % 2 == 1 && start > 72 {
            var order:[Encounter]=[.dodge,.rolling,.gap,.slide,.jump,.breathing]
            var ordering=identity.stream("hazardOrder",index/12)
            for j in stride(from:5,through:1,by:-1) {order.swapAt(j,Int(ordering.below(UInt64(j+1))))}
            let e=order[(index/2)%6]
            let asset: AssetID = e == .dodge ? .rabbit : e == .slide ? (rng.below(2) == 0 ? .zebra : .horse) : e == .jump ? .column : [.soccer,.eightBall,.softball,.americanFootball,.nazar][Int(rng.below(5))]
            if e == .gap {
                result.gap = (anchor - 1.8)...(anchor + 1.8); result.routeFamily = .trackBroken
            } else if e != .breathing {
                result.hazards.append(HazardDescription(id: "h:\(index)", asset: asset, encounter: e, distance: anchor, lateral: (e == .slide || e == .jump) ? 0 : (rng.below(2) == 0 ? -0.8 : 0.8), radius: asset == .nazar ? 0.7 : 0.45, height: e == .slide ? 2.4 : e == .jump ? 0.45 : asset == .rabbit ? 0.8 : 0.9, speed: e == .rolling ? 4 : 0))
            }
        }
        // Safe transitions own a wide, hazard-free horizon on either side.
        let local = start.truncatingRemainder(dividingBy: 1800)
        if local >= 1080 && local < 1708 {result.routeFamily = .stairsSpiral}
        if local >= 792 && local <= 1008 || local <= 72 && start >= 1800 { result.hazards = []; result.gap = nil }
        if local == 888 { result.drop = SafeDropContract(departure: start + 12, landing: start + 28) }
        if local == 0 && start >= 1800 { result.hazards = [HazardDescription(id: "mirror:\(index)", asset: .mirror, encounter: .mirror, distance: start + 12, lateral: 0, radius: 2, height: 4)] }
        if result.gap == nil && result.hazards.isEmpty {
            for n in 0..<2 { result.pickups.append(PickupDescription(id: "b:\(index):\(n)", distance: start + 8 + Double(n)*8, lateral: [-0.9,0,0.9][Int(scenery.below(3))])) }
        }
        if let drop=result.drop {
            result.pickups=[]
            for n in 0..<4 { result.pickups.append(PickupDescription(id:"drop-balloon:\(index):\(n)",distance:drop.departure+Double(n)*4,lateral:0)) }
        }
        let recipes: [[AssetID]] = [[.cloud,.window,.house,.heart],[.water,.column,.roomShell,.fountain],[.rail,.moon,.star,.arch],[.tree,.horse,.rock],[.chair,.bed,.tower,.curtain],[.flower,.mushroom,.mountain,.ribbon]]
        for n in 0..<2 {
            let list = recipes[result.recipe]
            result.scenery.append(SceneryPlacement(asset: list[(index*2+n)%list.count], distance: start + Double(n*12), lateral: (n == 0 ? -1 : 1) * Double(8 + scenery.below(8)), scale: 1.8 + Double(scenery.below(4))))
        }
        if tutorial && start < 432 {
            result.hazards = []; result.gap = nil; result.routeFamily = .trackStraight
            if index == 5 { result.gap = 132...134; result.routeFamily = .trackBroken }
            if index == 9 { result.hazards = [HazardDescription(id: "tutorial:slide", asset: .zebra, encounter: .slide, distance: 228, lateral: 0, radius: 2, height: 2.4)] }
            if index == 13 { result.hazards = [HazardDescription(id: "tutorial:rabbit", asset: .rabbit, encounter: .dodge, distance: 324, lateral: 0.7, radius: 0.35, height: 0.8)] }
        }
        return result
    }
    public func supported(_ s: Double, tutorial: Bool = false) -> Bool {
        let c = chunk(max(0, Int(s / 24)), tutorial: tutorial)
        return c.gap.map { !$0.contains(s) } ?? true
    }
}
public enum VisualPhase: String, Codable, Sendable {
    case ordinary, deepStripping, deepSparse, deepRebuilding, beyond, luckyWhite
    public static func at(seconds: Double) -> Self {
        guard seconds >= 10800 else { return .ordinary }
        let elapsed = seconds.truncatingRemainder(dividingBy: 10800)
        if elapsed < 240 { return .deepStripping }; if elapsed < 300 { return .deepSparse }; if elapsed < 600 { return .deepRebuilding }; return .beyond
    }
}
public struct FairnessValidator {
    public static func validate(_ chunk: ChunkDescription) -> Bool {
        guard chunk.hazards.count <= 1, chunk.drop?.validated != false else { return false }
        if let gap = chunk.gap { guard gap.upperBound-gap.lowerBound <= 4.8 else { return false } }
        return chunk.hazards.allSatisfy { h in
            if h.encounter == .slide { return h.height >= 0.85 }
            if h.encounter == .jump { return h.height <= 0.45 }
            return abs(h.lateral) + h.radius + 0.28 < 2 || h.encounter == .mirror
        }
    }
}

/// Both adapters use the same normalized-angle mapping; no sensor reads enter the core.
public enum SteeringNormalizer {
    public static func normalize(degrees:Double,sensitivity:Double = 1,deadzone:Double = 1.5,fullScaleDegrees:Double = 18) -> Double {
        guard degrees.isFinite, sensitivity.isFinite, deadzone.isFinite, fullScaleDegrees.isFinite, fullScaleDegrees > 1 else { return 0 }
        let zone=max(0,min(min(10,fullScaleDegrees-1),deadzone)),magnitude=max(0,abs(degrees)-zone)
        return max(-1,min(1,(degrees < 0 ? -1 : 1)*magnitude/(fullScaleDegrees-zone)*max(0.5,min(1.5,sensitivity))))
    }
}
