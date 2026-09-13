import Foundation
import GameKit
import UIKit

@MainActor protocol RecordPublisher { func submit(_ run:RunState) async throws }
@MainActor struct DisabledRecordPublisher:RecordPublisher { func submit(_ run:RunState) async throws {throw DreamError.unavailable} }
/// Optional adapter; no instance is created by the offline dependency graph.
@MainActor final class GameCenterPublisher:RecordPublisher {
    let unbrokenID:String,continuedID:String
    init(unbrokenID:String,continuedID:String) {self.unbrokenID=unbrokenID;self.continuedID=continuedID}
    func authenticate(present:@escaping (UIViewController)->Void,onError:@escaping (Error)->Void) {
        GKLocalPlayer.local.authenticateHandler={controller,error in if let controller {present(controller)};if let error {onError(error)}}
    }
    func submit(_ run:RunState) async throws {
        guard run.mode == .fresh,GKLocalPlayer.local.isAuthenticated,!unbrokenID.isEmpty,!continuedID.isEmpty else {throw DreamError.unavailable}
        let ticks=run.continueCount == 0 ? run.firstWakingTicks ?? run.activeTicks : run.activeTicks
        try await GKLeaderboard.submitScore(Int(min(ticks,UInt64(Int.max))),context:0,player:GKLocalPlayer.local,leaderboardIDs:[run.continueCount == 0 ? unbrokenID : continuedID])
    }
}
/// A future synchronized ledger must reconcile source lots and unique transaction IDs.
/// It must not restore consumables by replaying all historical purchases as new grants.
protocol ProfileBackupTransport:Sendable {
    func uploadVersionedBackup(_ data:Data) async throws
    func downloadVersionedBackup() async throws -> Data?
}
