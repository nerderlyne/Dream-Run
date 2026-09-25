import Foundation

public enum DreamScaleEvent:Int,CaseIterable,Sendable {
    case none,miniature,oversized,monumental,absurd
    public var title:String {["Quiet scale","Miniature","Oversized","Monumental","Absurd"][rawValue]}
}
public enum DreamScaleFraming:Int,CaseIterable,Sendable {
    case whole,beneath,crownOnly,rootsOnly
    public var title:String {["Whole landmark","World below","Crown from below","Roots overhead"][rawValue]}
}
public enum DreamScaleRole:Int,Sendable {case tiny,ordinary,oversized,miniature,monumental,absurd}

/// One scene-wide anomaly budget, owned by slot zero. Other slots cannot roll landmarks.
public struct DreamScaleComposition:Equatable,Sendable {
    public let event:DreamScaleEvent
    public let concept:AssetID
    public let scene:Int
    public let framing:DreamScaleFraming
    public static func plan(identity:DreamIdentity,distance:Double,override:DreamScaleEvent?=nil,framing:DreamScaleFraming?=nil)->Self {
        let scene=max(0,Int(distance/768))
        var rng=identity.stream("relative-scale-event",scene)
        let roll=rng.below(100)
        let event:DreamScaleEvent=roll<60 ? .none:roll<75 ? .miniature:roll<94 ? .oversized:roll<99 ? .monumental:.absurd
        let concepts:[AssetID]=[.horse,.moon,.house,.tree,.arch]
        let concept=concepts[Int(rng.below(UInt64(concepts.count)))],framingRoll=rng.below(100)
        let selected=override ?? event
        let large=selected == .monumental || selected == .absurd
        let chosen:DreamScaleFraming=large ? (framingRoll<35 ? .whole:framingRoll<55 ? .beneath:framingRoll<80 ? .crownOnly:.rootsOnly):(framingRoll<45 ? .beneath:.whole)
        return .init(event:selected,concept:concept,scene:scene,framing:framing ?? chosen)
    }
    public func role(slot:Int)->DreamScaleRole {
        if slot==0 {
            switch event {
            case .none:return .ordinary
            case .miniature:return .miniature
            case .oversized:return .oversized
            case .monumental:return .monumental
            case .absurd:return .absurd
            }
        }
        // All four vignette parts obey the same hierarchy. Twelve small context objects,
        // six ordinary ones, and at most one restrained oversized supporting object.
        let rank=(slot*7+scene*3)%19
        if rank<12 {return .tiny}
        if rank<18 || event == .monumental || event == .absurd {return .ordinary}
        return .oversized
    }
    public static func extent(_ role:DreamScaleRole)->Float {
        switch role {
        case .miniature:return 0.008
        case .tiny:return 0.022
        case .ordinary:return 0.05
        case .oversized:return 0.085
        case .monumental:return 0.32
        case .absurd:return 0.55
        }
    }
    /// Maximum angular diameter before fading, not resizing in response to the camera.
    public static func ceiling(_ role:DreamScaleRole)->Float {
        switch role {
        case .miniature:return 0.04
        case .tiny:return 0.075
        case .ordinary:return 0.16
        case .oversized:return 0.25
        case .monumental:return 0.7
        case .absurd:return 1.15
        }
    }
    public static func visibility(extent:Float,role:DreamScaleRole)->Float {
        let limit=ceiling(role)
        return max(0,min(1,(limit-extent)/(limit*0.25)))
    }
    public func compose(_ p:DreamCollagePlacement,slot:Int)->DreamCollagePlacement {
        let role=role(slot:slot)
        let height=p.depth*Self.extent(role)/max(1,p.representation.aspect)
        // Keep the selected landmark beside the route; miniature variants stay among
        // the same smaller context objects rather than becoming distant sky plates.
        let focus=slot==0 && event != .none
        let side:Float=p.lateral<0 ? -1:1
        let band=(slot*5+scene)%19
        let below = !focus && band<7
        let lateral=focus ? side*p.depth*(event == .absurd ? 0.18:0.10):below ? side*p.depth*(0.11+Float(band)*0.015):p.lateral
        var elevation:Float
        if focus {
            switch framing {
            case .whole:elevation=max(height*0.58,p.depth*0.11)
            case .beneath:elevation = -p.depth*0.17
            case .crownOnly:elevation = -height*0.5-p.depth*0.12
            case .rootsOnly:elevation = height*0.55+p.depth*0.18
            }
        } else {
            elevation=below ? -p.depth*(0.09+Float(band)*0.022):max(height*0.6,p.elevation*0.7)
        }
        return .init(representation:p.representation,cell:p.cell,anchorDistance:p.anchorDistance,depth:p.depth,lateral:lateral,elevation:elevation,height:height,mirrored:p.mirrored,roll:p.roll,opacity:focus ? 1:p.opacity,scaleRole:role)
    }
}
