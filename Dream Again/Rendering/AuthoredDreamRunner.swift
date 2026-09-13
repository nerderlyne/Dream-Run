import RealityKit
import Foundation

/// Optional production-art seam. The shipped character is explicitly a procedural stand-in.
/// A validated local USDZ can replace it without changing the simulation or cosmetic inventory.
@MainActor final class AuthoredDreamRunner {
    enum ArtError:Error {case missingHatSocket,missingClip(String)}
    let entity:Entity
    let hatSocket:Entity
    private let clips:[String:AnimationResource]
    private var playing=""
    private var controller:AnimationPlaybackController?
    static let requiredClips=["idle","run","jump","slide","stumble","fall","faint"]
    init(entity:Entity) throws {
        guard let socket=entity.findEntity(named:"hat.socket") else {throw ArtError.missingHatSocket}
        var found:[String:AnimationResource]=[:]
        for animation in entity.availableAnimations {if let name=animation.name {found[name]=animation}}
        for name in Self.requiredClips where found[name] == nil {throw ArtError.missingClip(name)}
        self.entity=entity;hatSocket=socket;clips=found
    }
    static func load(_ url:URL) async throws -> AuthoredDreamRunner {
        let e=try await Entity(contentsOf:url);return try AuthoredDreamRunner(entity:e)
    }
    func pose(_ name:String,speed:Float=1) {
        if playing != name,let clip=clips[name] {
            entity.stopAllAnimations(recursive:true)
            controller=entity.playAnimation(["idle","run"].contains(name) ? clip.repeat() : clip,transitionDuration:0.12)
            playing=name
        }
        controller?.speed=speed
    }
}
