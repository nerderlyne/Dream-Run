import Foundation

/// A bounded memo of pure certification results, independent of seed RNG and renderer timing.
private final class CertificationMemo:@unchecked Sendable {
    static let shared=CertificationMemo()
    let lock=NSLock()
    var values:[String:Bool]=[:]
    func value(_ key:String)->Bool? {lock.lock();defer{lock.unlock()};return values[key]}
    func set(_ key:String,_ value:Bool) {lock.lock();defer{lock.unlock()};if values.count >= 4096 {values.removeAll(keepingCapacity:true)};values[key]=value}
}
public enum HorizonCertification {
    /// Samples continuous steering through the authoritative movement/collision engine.
    /// A passing trajectory is an existence witness, not a guarantee for arbitrary input.
    /// Width/clearance margins are those of the real capsule, not a point runner.
    public static func validate(history:[ChunkDescription],candidate:ChunkDescription,rulesVersion:UInt16 = 1)->Bool {
        guard FairnessValidator.validate(candidate) else {return false}
        let beginning=max(0,candidate.start-48)
        var pieces=Array(history.suffix(2))+[candidate]
        pieces=pieces.filter{$0.end > beginning}
        for i in pieces.indices {
            pieces[i].start -= beginning
            if let gap=pieces[i].gap {pieces[i].gap=((gap.lowerBound-beginning)*1000).rounded()/1000-0.01...((gap.upperBound-beginning)*1000).rounded()/1000+0.01}
            for j in pieces[i].hazards.indices {pieces[i].hazards[j].distance=((pieces[i].hazards[j].distance-beginning)*1000).rounded()/1000;pieces[i].hazards[j].radius += 0.01;pieces[i].hazards[j].id="cert:\(i):\(j)"}
            pieces[i].pickups=[];pieces[i].scenery=[]
        }
        let hazards=pieces.flatMap(\.hazards)
        let gaps=pieces.compactMap(\.gap)
        // Serialize only geometry and motion that affect authority. No palette/seed cache key.
        let key="R\(rulesVersion)|"+hazards.map{"\($0.fatal),\($0.contactHalfWidth),\($0.encounter.rawValue),\($0.distance),\($0.lateral),\($0.radius),\($0.height),\($0.speed)"}.joined(separator:"|")+gaps.map{"g\($0.lowerBound),\($0.upperBound)"}.joined()+"end\(candidate.end-beginning)"
        if let cached=CertificationMemo.shared.value(key) {return cached}
        if hazards.isEmpty && gaps.isEmpty {CertificationMemo.shared.set(key,true);return true}
        let result=certify(pieces:pieces,ending:candidate.end-beginning+56,rulesVersion:rulesVersion)
        CertificationMemo.shared.set(key,result)
        return result
    }
    private static func certify(pieces:[ChunkDescription],ending:Double,rulesVersion:UInt16)->Bool {
        // Ordinary active route grades are bounded below .08 by the implemented analytic route.
        // Marked drops have a separate validated scripted contract, without competing hazards.
        for slope in [-0.08,0.08] {
            for entry in [-RunRules(version:rulesVersion).lateralLimit,0,RunRules(version:rulesVersion).lateralLimit] {
                for entryTicks:UInt64 in [0,18_000,5_184_000] {
                    var identity=DreamIdentity(seed:0);identity.rulesVersion=rulesVersion
                    var state=RunState(identity:identity,mode:.reviewDemo)
                    state.phase = .running;state.activeTicks=entryTicks;state.lastPigOrdinal=1000
                    state.chunks=pieces;state.player.lateral=entry
                    state.hazards=pieces.flatMap(\.hazards).map { original in
                        var h=original;h.spawnTick=state.activeTicks
                        if h.speed > 0 {h.distance += 12;h.spawnTick=UInt64.max}
                        return h
                    }
                    var simulation=GameSimulation(certification:state,slope:slope)
                    var ticks=0
                    while simulation.state.distance < ending && ticks < 1200 {
                        let s=simulation.state
                        let relevant=s.hazards.filter{!$0.resolved && $0.position(at:s.activeTicks)>s.distance-1 && $0.position(at:s.activeTicks)<s.distance+64}.sorted{$0.position(at:s.activeTicks)<$1.position(at:s.activeTicks)}
                        var input=InputFrame()
                        if let hazard=relevant.first {
                            let distance=hazard.position(at:s.activeTicks)-s.distance
                            if hazard.encounter == .slide {input.slide=distance < max(s.speed*0.3,hazard.radius+0.28+s.speed/60+0.15) && distance>0 && s.player.slideTicks == 0}
                            else if hazard.encounter == .jump {input.jump=distance<s.speed*0.23 && distance>0 && s.player.grounded}
                            else if hazard.encounter != .mirror {input.steering=hazard.lateral>=0 ? -1 : 1}
                        }
                        if let gap=s.chunks.compactMap(\.gap).first(where:{$0.upperBound>s.distance && $0.lowerBound-s.distance<s.speed*0.16}) {input.jump=s.distance<gap.lowerBound && s.player.grounded}
                        _=simulation.step(input);ticks += 1
                        guard [.running,.safeDrop,.mirrorCrossing].contains(simulation.state.phase) else {return false}
                    }
                    if simulation.state.distance < ending {return false}
                }
            }
        }
        return true
    }
}
