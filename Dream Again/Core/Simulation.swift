import Foundation
public enum RunMode: String, Codable, Sendable { case fresh, revisit, tutorial, debug, reviewDemo
    public var earns: Bool { self != .debug && self != .reviewDemo }
}
public enum RunPhase: String, Codable, Sendable { case ready, running, safeDrop, mirrorCrossing, paused, waking, resuming, luckyTransition, whiteEnding, finished }
public struct InputFrame: Codable, Equatable, Sendable {
    public var steering: Double = 0
    public var jump = false
    public var slide = false
    public init(steering: Double = 0, jump: Bool = false, slide: Bool = false) { self.steering = steering; self.jump = jump; self.slide = slide }
}
public enum StrawLimb:String,Codable,CaseIterable,Sendable {case leftArm,rightArm,leftLeg,rightLeg}
public struct PlayerState: Codable, Equatable, Sendable {
    public var missingLimbs:[StrawLimb]=[]
    public var lateral = 0.0
    public var height = 0.0
    public var knockbackVelocity=0.0
    public var velocityY = 0.0
    public var grounded = true
    public var slideTicks = 0
    public var slideCooldown = 0
    public var slideExtension = 0
    public var jumpBuffer = 0
    public var slideBuffer = 0
    public var coyote = 5
    public var bodyHeight: Double { slideTicks > 0 ? 0.58 : 1.55 }
}
public enum GameEvent: Equatable, Sendable { case balloon, strawBreak, strawRepair, stumble, thunder, waking, clover, pigCommitted, mirror, drop, mastery, tutorialComplete, ending }
public struct CollectedPig: Codable, Equatable, Sendable { public var ordinal: Int; public var hue: Int }
public struct RunState: Codable, Sendable {
    public var schema = 1
    public var rules=RunRules()
    public var id: UUID
    public var identity: DreamIdentity
    public var mode: RunMode
    public var phase: RunPhase = .ready
    public var resumePhase: RunPhase = .running
    public var activeTicks: UInt64 = 0
    public var distance = 0.0
    public var player = PlayerState()
    public var continueCount = 0
    public var straw = 0
    public var hayCollected = 0
    public var sportsBallsSinceHay = 0
    public var lastHayTick:UInt64?
    public var nextStrawRepairTick:UInt64 = 0
    public var balloons = 0
    public var pigs: [CollectedPig] = []
    public var pendingPig: PigDecision?
    public var lastPigOrdinal = 0
    public var instabilityUntil: UInt64 = 0
    public var softImmunityUntil: UInt64 = 0
    public var lastSoftTick: UInt64 = 0
    public var chunks: [ChunkDescription] = []
    public var recentAssets:[AssetID]=[]
    public var recentRoutes:[AssetID]=[]
    public var recentHazards:[AssetID]=[]
    public var recentRecipes:[Int]=[]
    public var hazards: [HazardDescription] = []
    public var collectedIDs: Set<String> = []
    public var safeUntilDistance = 0.0
    public var mirrorCount = 0
    public var mirrorUntilTick: UInt64 = 0
    public var dropCount = 0
    public var voidEntryTick: UInt64?
    public var escapedVoid = false
    public var firstWakingTicks: UInt64?
    public var endingElapsed = 0.0
    public var recoveryElapsed = 0.0
    public var lastDropBlock = -1
    public var cause = ""
    public var seconds: Double { Double(activeTicks) / 60 }
    public var unhinderedSpeed:Double {DreamDifficulty.speed(seconds:seconds)}
    /// The same authoritative recovery drives travel speed and the avatar's hit pose.
    public var stumbleWeight:Double {
        guard lastSoftTick > 0,activeTicks >= lastSoftTick,activeTicks-lastSoftTick < 60 else {return 0}
        return 1-Double(activeTicks-lastSoftTick)/60
    }
    public var speed:Double {unhinderedSpeed*(1-0.25*stumbleWeight)}
    public func floorHeight(at distance:Double)->Double {chunks.reduce(0){$0+($1.step?.height(at:distance) ?? 0)}}
    public func halfWidth(at distance:Double)->Double {chunks.first{$0.start<=distance && $0.end>distance}?.halfWidth ?? 2}
    public var unbroken: Bool { mode == .fresh && continueCount == 0 }
    public var visual: VisualPhase { pigs.count == 3 ? .luckyWhite : .at(seconds: seconds) }
    public var paletteIndex: Int {
        if visual == .luckyWhite { return 7 }
        if visual == .beyond || visual == .deepRebuilding { return 8 + mirrorCount % 4 }
        var palette=identity.stream("palette",0)
        return (Int(palette.below(7)) + Int(distance / 432) + mirrorCount * 2) % 7
    }
    public init(identity: DreamIdentity, mode: RunMode, id: UUID = UUID()) { self.identity = identity; self.mode = mode; self.id = id; self.rules=RunRules() }
}
public struct GameSimulation: Sendable {
    public var state: RunState
    private var certificationSlope:Double?
    init(certification:RunState,slope:Double) {state=certification;certificationSlope=slope}
    public init(identity: DreamIdentity, mode: RunMode = .fresh, rules: RunRules? = nil) { state = RunState(identity: identity, mode: mode); if let rules {state.rules=rules}; streamChunks() }
    public init(snapshot: RunState) throws {
        guard snapshot.schema == 1, snapshot.sportsBallsSinceHay >= 0, snapshot.straw >= 0, snapshot.straw <= snapshot.hayCollected, Set(snapshot.player.missingLimbs).count == snapshot.player.missingLimbs.count, snapshot.player.missingLimbs.count <= 4, snapshot.identity.supported, snapshot.distance.isFinite, snapshot.distance >= 0, snapshot.distance <= Double(Int.max/4096), snapshot.activeTicks < UInt64.max-RunRules.pigIntervalTicks, snapshot.player.lateral.isFinite, abs(snapshot.player.lateral) <= 2.5, snapshot.player.knockbackVelocity.isFinite, abs(snapshot.player.knockbackVelocity)<=8, snapshot.continueCount <= 1, snapshot.pigs.count <= 3, snapshot.chunks.count <= 16, snapshot.rules == RunRules() else { throw DreamError.corruptStore }
        state = snapshot
    }
    public mutating func resume() { if state.phase == .paused || state.phase == .ready { state.phase = state.resumePhase } }
    public mutating func pause() { if [.running,.safeDrop,.mirrorCrossing,.luckyTransition,.whiteEnding,.resuming].contains(state.phase) { state.resumePhase = state.phase; state.phase = .paused } }
    public mutating func wake(_ cause: String) {
        guard [.running,.safeDrop,.mirrorCrossing].contains(state.phase) else { return }
        state.cause = cause; state.phase = .waking; state.endingElapsed = 0
        if state.firstWakingTicks == nil { state.firstWakingTicks = state.activeTicks }
    }
    public mutating func continueRun() -> Bool {
        guard state.continueCount == 0, state.pigs.count < 3, [.waking,.finished].contains(state.phase) else { return false }
        state.continueCount = 1; state.phase = .resuming; state.recoveryElapsed = 0
        // Rejoin beyond the fatal gap on certified support. No rewind or pickup replay.
        let g = WorldGenerator(state.identity)
        while !g.supported(state.distance, tutorial: state.mode == .tutorial) { state.distance += 0.5 }
        state.safeUntilDistance = state.distance + state.speed * 2 + 4
        state.hazards.removeAll { $0.position(at: state.activeTicks) <= state.safeUntilDistance }
        for i in state.chunks.indices where state.chunks[i].end > state.distance && state.chunks[i].start < state.safeUntilDistance {
            state.chunks[i].gap=nil;state.chunks[i].step=nil;state.chunks[i].collapsing=false;state.chunks[i].halfWidth=2
            state.chunks[i].hazards=[]
        }
        state.player = PlayerState(); state.instabilityUntil = 0; state.softImmunityUntil = 0
        return true
    }
    public mutating func presentationStep(_ dt: Double, skip: Bool = false) -> [GameEvent] {
        if state.phase == .resuming {
            state.recoveryElapsed += dt
            if state.recoveryElapsed >= 2 { state.phase = .running }; return []
        }
        guard [.waking,.luckyTransition,.whiteEnding].contains(state.phase) else { return [] }
        state.endingElapsed += max(0, min(dt, 0.1))
        if state.pigs.count == 3 {
            if state.endingElapsed >= 45 { state.phase = .whiteEnding }
            if state.endingElapsed >= 57 || skip && state.endingElapsed >= 5 { state.phase = .finished; return [.ending] }
        } else if state.endingElapsed >= (state.cause == "unravelled" ? 2.4:1.25) || skip && state.endingElapsed >= 0.35 { state.phase = .finished; return [.ending] }
        return []
    }
    mutating func streamChunks() {
        let index = max(0, Int(state.distance / 24)), generator = WorldGenerator(state.identity)
        let lower = max(0, index-2), upper = index+10
        state.chunks.removeAll { $0.id < lower || $0.id > upper }
        let existing = Set(state.chunks.map(\.id))
        for i in lower...upper where !existing.contains(i) {
            var chunk = generator.chunk(i, tutorial: state.mode == .tutorial)
            let original=chunk
            var certified=false
            for attempt in 1...8 {
                chunk.candidateAttempts=attempt
                if HorizonCertification.validate(history:state.chunks,candidate:chunk,rulesVersion:state.identity.rulesVersion) {certified=true;break}
                chunk=original
                if let gap=chunk.gap {let length=max(1.8,(gap.upperBound-gap.lowerBound)-Double(attempt)*0.3);chunk.gap=gap.lowerBound...(gap.lowerBound+length)}
                for h in chunk.hazards.indices where chunk.hazards[h].encounter == .dodge || chunk.hazards[h].encounter == .rolling {chunk.hazards[h].lateral=(attempt%2 == 0 ? -1 : 1)*0.9}
            }
            if !certified {chunk.hazards=[];chunk.gap=nil;chunk.step=nil;chunk.collapsing=false;chunk.halfWidth=2;chunk.routeFamily = .trackStraight;chunk.candidateAttempts=8;chunk.fallbackReason="no certified horizon trajectory"}
            if chunk.start < state.safeUntilDistance && chunk.end > state.distance { chunk.hazards=[]; chunk.gap=nil;chunk.step=nil;chunk.collapsing=false;chunk.halfWidth=2 }
            state.sportsBallsSinceHay += chunk.hazards.filter { $0.isRollingSportsBall }.count
            if chunk.pickups.contains(where:{$0.kind == .straw}) {
                if state.sportsBallsSinceHay >= 4 {state.sportsBallsSinceHay=0}
                else {chunk.pickups.removeAll {$0.kind == .straw}}
            }
            state.chunks.append(chunk)
            state.recentAssets=Array((state.recentAssets+chunk.scenery.map(\.asset)).suffix(12))
            state.recentRoutes=Array((state.recentRoutes+[chunk.routeFamily]).suffix(2))
            state.recentHazards=Array((state.recentHazards+chunk.hazards.map(\.asset)).suffix(2))
            if state.recentRecipes.last != chunk.recipe {state.recentRecipes=Array((state.recentRecipes+[chunk.recipe]).suffix(3))}
            for var hazard in chunk.hazards {
                hazard.spawnTick = state.activeTicks
                // Arm the ball from a 72 m visible approach; never let an ahead-streamed ball
                // roll backwards through earlier mandatory actions before the player arrives.
                if hazard.speed > 0 { hazard.distance += 12; hazard.spawnTick = UInt64.max }
                state.hazards.append(hazard)
            }
        }
        state.chunks.sort { $0.id < $1.id }
        state.hazards.removeAll { $0.position(at: state.activeTicks) < state.distance - 48 || $0.resolved }
        let activeIDs = Set(state.chunks.flatMap { $0.pickups.map(\.id) })
        state.collectedIDs.formIntersection(activeIDs)
    }
    public mutating func step(_ input: InputFrame = InputFrame()) -> [GameEvent] {
        guard [.running,.safeDrop,.mirrorCrossing].contains(state.phase) else { return [] }
        var events: [GameEvent] = []
        let oldDistance = state.distance, oldLateral = state.player.lateral, oldHeight = state.player.height
        state.activeTicks += 1
        let dt = 1.0/60, speed = state.speed
        state.distance += speed*dt
        let desired = max(-1, min(1, input.steering.isFinite ? input.steering : 0))*state.rules.lateralLimit
        let filtered = (desired-state.player.lateral)*(1-exp(-dt/state.rules.smoothing))
        state.player.lateral += max(-state.rules.lateralSpeed*dt,min(state.rules.lateralSpeed*dt,filtered))+state.player.knockbackVelocity*dt
        state.player.knockbackVelocity *= exp(-dt/0.18)
        if input.jump { state.player.jumpBuffer = 8 }
        if input.slide { state.player.slideBuffer = 8 }
        state.player.slideCooldown=max(0,state.player.slideCooldown-1)
        if state.player.slideTicks == 1 && state.player.slideExtension > 0 && state.hazards.contains(where:{!$0.resolved && $0.encounter == .slide && abs($0.position(at:state.activeTicks)-state.distance) < $0.radius+0.28}) {
            state.player.slideExtension -= 1
        } else if state.player.slideTicks > 0 { state.player.slideTicks -= 1 }
        if state.player.grounded { state.player.coyote = 5 } else { state.player.coyote = max(0,state.player.coyote-1) }
        if state.player.jumpBuffer > 0 && state.player.coyote > 0 && state.player.slideTicks == 0 {
            state.player.velocityY = state.rules.jumpVelocity; state.player.grounded = false; state.player.coyote = 0; state.player.jumpBuffer = 0
        }
        if state.player.slideBuffer > 0 && state.player.grounded && state.player.slideTicks == 0 && state.player.slideCooldown == 0 { state.player.slideTicks = state.rules.slideTicks; state.player.slideCooldown=81; state.player.slideExtension=15; state.player.slideBuffer = 0 }
        state.player.jumpBuffer = max(0,state.player.jumpBuffer-1); state.player.slideBuffer = max(0,state.player.slideBuffer-1)
        let supported = !state.chunks.contains { $0.gap?.contains(state.distance) == true }
        if !supported && state.player.grounded { state.player.grounded = false; state.player.velocityY = 0 }
        if !state.player.grounded {
            let route=WorldGenerator(state.identity)
            state.player.height -= certificationSlope.map{$0*(state.distance-oldDistance)} ?? (route.sample(state.distance).y-route.sample(oldDistance).y)
            state.player.height -= state.floorHeight(at:state.distance)-state.floorHeight(at:oldDistance)
            state.player.height += state.player.velocityY*dt; state.player.velocityY -= state.rules.gravity*dt
            if supported && state.player.height <= 0 && state.player.velocityY <= 0 {
                if oldHeight < -0.35 { wake("gap"); return [.waking] }
                state.player.height = 0; state.player.velocityY = 0; state.player.grounded = true
            }
            if state.player.height < -1.6 { wake("gap"); return [.waking] }
        }
        if certificationSlope == nil && Int(oldDistance/24) != Int(state.distance/24) { streamChunks() }
        let ordinal = Int((state.activeTicks + 360) / RunRules.pigIntervalTicks)
        if ordinal > state.lastPigOrdinal && ordinal > 0 {
            let decision = PigDecision(identity: state.identity, ordinal: ordinal, continued: state.continueCount > 0)
            state.pendingPig = decision; state.lastPigOrdinal = ordinal
            state.safeUntilDistance = state.distance + speed*10
            state.hazards.removeAll { $0.position(at: state.activeTicks) > state.distance && $0.position(at: state.activeTicks) < state.safeUntilDistance }
            // Reserve the runway's support before rendering the promise.
            for i in state.chunks.indices where state.chunks[i].start < state.safeUntilDistance && state.chunks[i].end > state.distance { state.chunks[i].gap = nil;state.chunks[i].step=nil;state.chunks[i].collapsing=false;state.chunks[i].halfWidth=2 }
            if decision.present { state.hazards.append(HazardDescription(id: "pig:\(ordinal)", asset: .pig, encounter: .dodge, distance: state.distance + speed*6, lateral: 0.18, radius: decision.clover ? 0.65 : 0.38, height: 0.65, pig: decision)) }
            events.append(.pigCommitted)
        }
        for i in state.hazards.indices where state.hazards[i].speed > 0 && state.hazards[i].spawnTick == UInt64.max {
            if state.hazards[i].distance-state.distance <= 72 { state.hazards[i].spawnTick=state.activeTicks }
        }
        for i in state.hazards.indices where state.hazards[i].encounter == .lightning && state.hazards[i].strikeTick == UInt64.max {
            let remaining=state.hazards[i].distance-state.distance
            if remaining<=70 {
                state.hazards[i].strikeTick=state.activeTicks+UInt64(max(120,remaining/state.unhinderedSpeed*60))
            }
        }
        if state.hazards.contains(where:{$0.encounter == .lightning && $0.strikeTick == state.activeTicks}) {events.append(.thunder)}
        for i in state.chunks.indices {
            for j in state.chunks[i].pickups.indices where state.chunks[i].pickups[j].kind == .straw && state.chunks[i].pickups[j].rollStart == nil {
                let pickup=state.chunks[i].pickups[j]
                // Wait until the runner clears the preceding obstacle section. Confine
                // rolling to this clear support, including when the player misses it.
                if state.distance >= (pickup.rollLimit ?? state.chunks[i].start) && pickup.distance-state.distance <= 72 {
                    state.chunks[i].pickups[j].rollStart=state.activeTicks
                }
            }
        }
        if state.straw>0 && !state.player.missingLimbs.isEmpty && state.activeTicks>=state.nextStrawRepairTick {
            state.straw -= 1;state.player.missingLimbs.removeLast();state.nextStrawRepairTick=state.activeTicks+60;events.append(.strawRepair)
        }
        // Swept route-space slab intersection; sorted impact times implement tie precedence.
        struct Contact { var t: Double; var priority: Int; var hazard: Int?; var pickup: PickupDescription? }
        var contacts: [Contact] = []
        func interval(_ a: Double, _ b: Double, _ lo: Double, _ hi: Double) -> (Double,Double)? {
            if abs(b-a) < 1e-12 { return a >= lo && a <= hi ? (0,1) : nil }
            let t1=(lo-a)/(b-a), t2=(hi-a)/(b-a), low=max(0,min(t1,t2)), high=min(1,max(t1,t2)); return low <= high ? (low,high) : nil
        }
        for i in state.hazards.indices {
            let h = state.hazards[i]; if h.resolved { continue }
            let current = h.position(at: state.activeTicks), previous = current + h.speed*dt
            if h.pig == nil && h.encounter != .mirror && current < state.safeUntilDistance { continue }
            if h.encounter == .lightning && !h.striking(at:state.activeTicks) {continue}
            let wide = h.encounter == .slide || h.requiresJump || h.encounter == .mirror
            let currentX=h.lateral(at:state.activeTicks),previousX=h.lateral(at:state.activeTicks-1)
            guard let s = interval(oldDistance-previous,state.distance-current,-h.radius-0.28,h.radius+0.28), let x = interval(oldLateral-previousX,state.player.lateral-currentX,-(wide ? 2 : h.contactHalfWidth+0.28),(wide ? 2 : h.contactHalfWidth+0.28)), max(s.0,x.0) <= min(s.1,x.1) else { continue }
            let t=max(s.0,x.0), feet=oldHeight+(state.player.height-oldHeight)*t
            if h.encounter == .slide && feet+state.player.bodyHeight < 0.85 { continue }
            if h.encounter != .slide && h.encounter != .mirror && h.encounter != .lightning && feet > h.height { continue }
            contacts.append(Contact(t:t,priority:h.encounter == .mirror ? 5 : h.pig?.clover == true ? 3 : h.fatal ? 0 : 2,hazard:i))
        }
        for p in state.chunks.flatMap(\.pickups) where !state.collectedIDs.contains(p.id) {
            let before=p.balloonPosition(at:state.activeTicks-1),after=p.balloonPosition(at:state.activeTicks)
            guard let s=interval(oldDistance-p.routeDistance(at:state.activeTicks-1),state.distance-p.routeDistance(at:state.activeTicks),p.kind == .straw ? -0.76:-0.55,p.kind == .straw ? 0.76:0.55),
                  let x=interval(oldLateral-before.lateral,state.player.lateral-after.lateral,p.kind == .straw ? -0.76:-0.58,p.kind == .straw ? 0.76:0.58),
                  let y=interval(oldHeight-before.height,state.player.height-after.height,-state.player.bodyHeight-0.32,0.36),
                  max(s.0,x.0,y.0) <= min(s.1,x.1,y.1) else {continue}
            contacts.append(Contact(t:max(s.0,x.0,y.0),priority:4,pickup:p))
        }
        contacts.sort { abs($0.t-$1.t) < 1e-9 ? $0.priority < $1.priority : $0.t < $1.t }
        for c in contacts {
            if let p=c.pickup {
                if p.kind == .straw {
                    state.straw += 1;state.hayCollected += 1;state.lastHayTick=state.activeTicks
                    if !state.player.missingLimbs.isEmpty {state.straw -= 1;state.player.missingLimbs.removeLast()}
                    state.collectedIDs.insert(p.id);events.append(.strawRepair)
                } else {state.collectedIDs.insert(p.id);state.balloons += 1;events.append(.balloon)}
                continue
            }
            guard let i=c.hazard else { continue }; let h=state.hazards[i]; state.hazards[i].resolved=true
            if h.encounter == .mirror { state.mirrorCount += 1; state.mirrorUntilTick=state.activeTicks+6; state.phase = .mirrorCrossing; events.append(.mirror) }
            else if let pig=h.pig, pig.clover {
                state.pigs.append(CollectedPig(ordinal:pig.ordinal,hue:Int(pig.cloverDraw))); events.append(.clover)
                if state.pigs.count == 3 { state.phase = .luckyTransition; state.endingElapsed = 0; state.distance = oldDistance+(state.distance-oldDistance)*c.t; break }
            } else if h.fatal { wake(h.asset == .rabbit ? "rabbit" : h.asset == .nazar ? "nazar" : h.encounter == .lightning ? "lightning" : h.encounter == .swing ? "swinging mace" : h.requiresJump ? "missed jump" : "underpass"); events.append(.waking); break }
            else if state.activeTicks >= state.softImmunityUntil {
                if [.soccer,.eightBall,.softball,.americanFootball].contains(h.asset) {
                    let left=state.player.lateral <= h.lateral(at:state.activeTicks)
                    let order:[StrawLimb]=left ? [.leftArm,.rightArm,.leftLeg,.rightLeg]:[.rightArm,.leftArm,.rightLeg,.leftLeg]
                    if let limb=order.first(where:{!state.player.missingLimbs.contains($0)}) {state.player.missingLimbs.append(limb);events.append(.strawBreak);state.nextStrawRepairTick=state.activeTicks+60}
                    if state.player.missingLimbs.count == 4 {wake("unravelled");events.append(.waking);break}
                }
                state.lastSoftTick=state.activeTicks; state.instabilityUntil=state.activeTicks+300; state.softImmunityUntil=state.activeTicks+48
                let direction=state.player.lateral >= h.lateral(at:state.activeTicks) ? 1.0:-1.0
                state.player.lateral += direction*0.18;state.player.knockbackVelocity=direction*4
                events.append(.stumble)
            }
        }
        if abs(state.player.lateral)+0.28>state.halfWidth(at:state.distance) && state.player.height<0.1 && state.phase == .running {
            wake("fell from edge");events.append(.waking)
        }
        if state.phase == .mirrorCrossing && state.activeTicks >= state.mirrorUntilTick { state.phase = .running }
        let block=Int(state.distance/1800), local=state.distance.truncatingRemainder(dividingBy:1800)
        if local >= 900 && local < 916 && state.pigs.count < 3 && state.phase == .running { state.phase = .safeDrop }
        if state.phase == .safeDrop && local >= 916 { state.phase = .running; if state.lastDropBlock != block { state.dropCount += 1; state.lastDropBlock=block; events.append(.drop) } }
        if state.paletteIndex == 5 { if state.voidEntryTick == nil { state.voidEntryTick=state.activeTicks } }
        else if let entered=state.voidEntryTick { if state.activeTicks-entered >= 7200 { state.escapedVoid=true }; state.voidEntryTick=nil }
        if state.activeTicks == 648000 { events.append(.mastery) }
        if state.mode == .tutorial && state.seconds >= 55 { wake("tutorial complete"); events.append(.tutorialComplete) }
        return events
    }
    #if DEBUG
    public mutating func debugTime(_ seconds: Double) { state.mode = .debug; state.activeTicks = UInt64(max(0,seconds)*60); state.lastPigOrdinal = Int(seconds/Double(RunRules.pigIntervalSeconds)) }
    public mutating func debugPig(third: Bool) {
        state.mode = .debug
        if third { state.pigs = [CollectedPig(ordinal:1,hue:0),CollectedPig(ordinal:2,hue:1),CollectedPig(ordinal:3,hue:0)]; state.phase = .luckyTransition; state.endingElapsed=0 }
        else { state.hazards.append(HazardDescription(id:"debug:pig:\(state.activeTicks)",asset:.pig,encounter:.dodge,distance:state.distance+30,lateral:0,radius:0.65,height:0.65,pig:PigDecision(ordinal:99,clover:0,continued:false))) }
    }
    #endif
}
