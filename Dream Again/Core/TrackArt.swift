import Foundation

public enum TrackPattern:String,CaseIterable,Sendable {case checker,stripes,solid}
public enum TrackArt {
    public static func palettes(_ originals:[PaletteDefinition])->[PaletteDefinition] {
        let pairs=[("#FFD5EA","#7436CE"),("#FFDEED","#16877E"),("#EAC7FF","#A335AB"),("#EDF8FF","#247CCB"),("#BD579D","#30205D"),("#EFDFC4","#493D46"),("#FFDCEA","#158E70"),("#FFFDF1","#DBCA96"),("#F6F06C","#3820AA"),("#B0FFF0","#B62C64"),("#E3F477","#16504C"),("#FFD18C","#6933B5")]
        return originals.enumerated().map {i,p in var p=p;let pair=pairs[i%pairs.count];p.track_light=pair.0;p.track_dark=pair.1;return p}
    }
    public static func pattern(identity:DreamIdentity,distance:Double)->TrackPattern {
        var rng=identity.stream("track-surface",Int(max(0,distance)/192))
        let draw=rng.below(100)
        let quiet=DreamAtmosphericComposition.plan(identity:identity,distance:floor(max(0,distance)/192)*192).solidTrackWeight
        return draw<quiet ? .solid : draw<quiet+20 ? .stripes:.checker
    }
    public static func isLight(_ pattern:TrackPattern,distance:Int,column:Int)->Bool {
        switch pattern {case .checker:return (distance+column)%2 == 0;case .stripes:return column%2 == 0;case .solid:return false}
    }
}
