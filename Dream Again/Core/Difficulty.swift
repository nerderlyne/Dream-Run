import Foundation

/// Active time drives speed; distance drives the repeatable encounter layout.
public enum DreamDifficulty {
    public static func speed(seconds:Double)->Double {
        let t=max(0,seconds)
        if t<120 {return 12.25+3.75*t/120}
        if t<300 {return 16+3*(t-120)/180}
        return min(22,19+3*(t-300)/300)
    }
    public static func tier(distance:Double)->Int {distance<1200 ? 0:distance<4500 ? 1:2}
}

public struct DreamStep:Codable,Equatable,Sendable {
    public var start:Double
    public var ascendingRun:Bool = false
    public func height(at distance:Double)->Double {
        let x=distance-start
        if ascendingRun {
            if x<0 || x>=84 {return 0}
            if x<60 {return 0.72*Double(min(3,Int(x/24)+1))}
            // A gradual recovery descent after three distinct raised landings.
            return 2.16*(84-x)/24
        }
        if x<0 || x>=12 {return 0}
        if x<9 {return 0.72}
        return max(0,0.72-0.24*floor(x-8))
    }
}

public enum DreamObstacle:String,CaseIterable,Sendable {
    case stairs,brokenFloor,exposedBridge,window,moon,collapse,furniture,volley,lightning,animals,floatingStairs
    public var title:String {
        switch self {
        case .stairs:return "Impossible stairs"
        case .brokenFloor:return "Broken floor"
        case .exposedBridge:return "Exposed bridge"
        case .window:return "Descending jail door"
        case .moon:return "Swinging mace"
        case .collapse:return "Collapsing tiles"
        case .furniture:return "Sleeping furniture"
        case .volley:return "Ball volley"
        case .lightning:return "Lightning"
        case .animals:return "Dream animals"
        case .floatingStairs:return "Floating stairs"
        }
    }
}

extension WorldGenerator {
    public func obstacle(_ index:Int)->DreamObstacle {
        var choices=DreamObstacle.allCases
        var rng=identity.stream("encounter-sequence",index/(choices.count*2))
        for j in stride(from:choices.count-1,through:1,by:-1) {choices.swapAt(j,Int(rng.below(UInt64(j+1))))}
        return choices[(index/2)%choices.count]
    }
    public func encounterChunk(_ index:Int,kind:DreamObstacle,tier:Int)->ChunkDescription {
        let start=Double(index)*24,anchor=start+12
        var c=ChunkDescription(id:index,routeFamily:.trackStraight,start:start,hazards:[],pickups:[],scenery:[],recipe:0)
        func hazard(_ asset:AssetID,_ encounter:Encounter,_ x:Double=0,_ height:Double=0.8,_ radius:Double=0.45,_ offset:Double=0)->HazardDescription {
            .init(id:"dream:\(index):\(Int(offset))",asset:asset,encounter:encounter,distance:anchor+offset,lateral:x,radius:radius,height:height)
        }
        switch kind {
        case .stairs,.floatingStairs:
            c.routeFamily = .stairsStraight;c.step=DreamStep(start:anchor)
            c.hazards=[hazard(.stairsStraight,.step,0,0.72,0.15,-0.6)]
            if kind == .floatingStairs {c.gap=(anchor-(tier == 0 ? 3:4))...anchor}
        case .brokenFloor,.collapse:
            let length=[4.0,6.0,6.0][min(2,tier)]
            c.routeFamily = .trackBroken;c.gap=(anchor-length/2)...(anchor+length/2)
            c.collapsing=kind == .collapse
        case .exposedBridge:
            c.halfWidth=1.2
            c.hazards=[hazard(.eightBall,.rolling,index%4<2 ? -0.68:0.68,0.8,0.45,12)]
            c.hazards[0].speed=8
        case .window:
            c.hazards=[hazard(.window,.slide,0,2.6,0.22)]
        case .moon:
            c.hazards=[hazard(.moon,.swing,0,1.23,0.38)]
            c.hazards[0].motionPhase=Double(index%4)*Double.pi/2
        case .furniture:
            c.hazards=[hazard(index%4<2 ? .bed:.chair,.jump,0,0.6,0.65)]
        case .volley:
            c.hazards=[hazard(.soccer,.rolling,-0.72),hazard(.softball,.rolling,0.72,0.8,0.45,13)]
            for i in c.hazards.indices {c.hazards[i].speed=tier == 2 ? 10:8}
        case .lightning:
            c.hazards=[hazard(.cloud,.lightning,0,8,0.5)]
        case .animals:
            c.hazards=[index%4<2 ? hazard(.rabbit,.dodge,0.68):hazard(.zebra,.slide,0,2.4,0.6)]
        }
        return c
    }

    /// Three separate jumps, 24 m apart (at least 1.09 s at the speed cap),
    /// followed by a full recovery chunk. This owns the entire encounter horizon.
    public func jumpSequenceChunk(_ index:Int)->ChunkDescription? {
        let slot=index%12,first=index-slot+4
        guard (4...7).contains(slot) else {return nil}
        let beginning=Double(first)*24,ending=beginning+96
        // Keep complete sequences outside the mirror's protected approach/exit.
        guard Int(beginning/1800) == Int(ending/1800),
              beginning<1800 || beginning.truncatingRemainder(dividingBy:1800)>72,
              ending.truncatingRemainder(dividingBy:1800)<1752 else {return nil}
        var rng=identity.stream("jump-sequence",index/12)
        let variant=Int(rng.below(3)),ordinal=slot-4
        var c=ChunkDescription(id:index,routeFamily:.trackStraight,start:Double(index)*24,hazards:[],pickups:[],scenery:[],recipe:0)
        let tier=DreamDifficulty.tier(distance:beginning)
        if variant < 2 {
            c.routeFamily = .stairsStraight
            c.step=DreamStep(start:beginning+12,ascendingRun:true)
            if ordinal<3 {
                c.hazards=[HazardDescription(id:"ascending:\(index)",asset:.stairsStraight,encounter:.step,distance:c.start+11.4,lateral:0,radius:0.15,height:0.72)]
                // Missing treads end at the next raised landing. Later courses
                // put air between every flight, rather than adding generic hurdles.
                if variant == 1 || tier == 2 || (tier == 1 && ordinal>0) {
                    let length:Double = (tier == 2 || variant == 1 && tier>0) ? 4:3
                    c.gap=(c.start+12-length)...(c.start+12)
                }
            }
        } else if ordinal<3 {
            let kind:DreamObstacle = ordinal == 1 ? .brokenFloor:.furniture
            c=encounterChunk(index,kind:kind,tier:DreamDifficulty.tier(distance:c.start))
        }
        return c
    }
}

/// Shared test/certification driver; it uses the same published hazard trajectories as rendering.
public enum EncounterOracle {
    public static func input(_ s:RunState)->InputFrame {
        var input=InputFrame()
        let upcoming=s.hazards.filter{!$0.resolved && $0.position(at:s.activeTicks)>s.distance-1 && $0.position(at:s.activeTicks)<s.distance+70}.sorted{$0.position(at:s.activeTicks)<$1.position(at:s.activeTicks)}
        if let h=upcoming.first {
            let distance=h.position(at:s.activeTicks)-s.distance
            if h.encounter == .slide {input.slide=distance<max(s.speed*0.29,h.radius+0.28+s.speed/60+0.15) && distance>0 && s.player.slideTicks == 0}
            else if h.requiresJump {input.jump=distance<s.speed*0.25 && distance>0 && s.player.grounded}
            else if h.encounter != .mirror {
                let arrival=s.activeTicks+UInt64(max(0,distance/(s.speed+h.speed)*60))
                // Keep the chosen side until the whole capsule has passed the pendulum.
                // Reversing at its centre crossing would steer back into its trailing sweep.
                if h.encounter == .swing && distance<2 && abs(s.player.lateral)>0.65 {input.steering=s.player.lateral>0 ? 1:-1}
                else {input.steering=h.lateral(at:arrival)>=0 ? -1:1}
            }
        }
        if let gap=s.chunks.compactMap(\.gap).first(where:{$0.upperBound>s.distance && $0.lowerBound-s.distance<s.speed*0.13}) {input.jump=s.distance<gap.lowerBound && s.player.grounded}
        return input
    }
}
