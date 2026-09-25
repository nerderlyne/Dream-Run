/// Presentation-only writing. Selection uses a separate seed stream and never
/// advances the world generator or changes a run's rewards.
public enum DreamWhispers {
    private static func chosen(_ run:RunState,_ kind:String,_ index:Int)->Bool {
        var stream=run.identity.stream("whisper:\(kind)",index)
        return stream.below(5) == 0
    }

    public static func message(for run:RunState)->String? {
        guard run.phase == .running else {return nil}
        if run.mode == .tutorial {
            switch run.distance {
            case ..<80: return "tilt for balloons.\ntake a chance. pop a bop."
            case ..<155: return "swipe up.\nwake up 🤷"
            case ..<255: return "swipe down.\n*hugs hard*"
            case ..<345: return "rib rIb rIp.\ndon't touch the rabbit."
            default: return "may your dreams last forever."
            }
        }
        guard run.mode == .fresh || run.mode == .revisit else {return nil}

        // The roll is keyed to the hazard ID, so checking every frame cannot
        // turn a one-in-five opportunity into a guaranteed message.
        if run.hazards.contains(where:{$0.asset == .rabbit && !$0.resolved && (run.distance+20...run.distance+42).contains($0.distance) && chosen(run,"rabbit",Int(truncatingIfNeeded:SplitMix64.fnv($0.id)))}) {
            return "rib rIb rIp. keep away."
        }
        if run.hazards.contains(where:{$0.asset == .pig && $0.pig?.clover == true && !$0.resolved && (run.distance+12...run.distance+42).contains($0.distance) && chosen(run,"luckyPig",Int(truncatingIfNeeded:SplitMix64.fnv($0.id)))}) {
            return "yum feeling lucky?"
        }

        let seconds=Int(run.activeTicks/60)
        // State lines get a brief opportunity every 45 seconds, but only one
        // in five opportunities speaks. General lines appear every four
        // minutes, starting two minutes into the dream.
        if seconds >= 25 && (seconds-25)%45 < 4 {
            let slot=(seconds-25)/45
            var lines=[String]()
            if run.mode == .revisit || run.mirrorCount > 0 {lines.append("do u remember?")}
            if !run.pigs.isEmpty || run.pendingPig != nil {lines.append("i love pigs <3")}
            if !run.player.missingLimbs.isEmpty {lines.append("hay i miss u")}
            if run.continueCount > 0 {lines.append("where were u")}
            if run.visual == .beyond || run.visual == .deepRebuilding {lines.append("the world is yours")}
            if !lines.isEmpty && chosen(run,"state",slot) {
                var stream=run.identity.stream("whisperStateLine",slot)
                return lines[Int(stream.below(UInt64(lines.count)))]
            }
        }
        guard seconds >= 120 && (seconds-120)%240 < 4 else {return nil}
        let slot=(seconds-120)/240
        let lines=["never look back","love 4ever","rabbits on the moon go hard",
                   "may your dreams last forever","u can do this. stay.",
                   "u will make it. go! go! go!","i will always be here",
                   "i'm rooting for u. always. promise"]
        var stream=run.identity.stream("whisperGeneral",slot)
        return lines[Int(stream.below(UInt64(lines.count)))]
    }
}
