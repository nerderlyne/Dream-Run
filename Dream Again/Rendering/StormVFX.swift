import RealityKit
import UIKit
import simd

/// A translucent stitched thunderhead, shared by every lightning encounter.
@MainActor final class StormVFX {
    private var template:ModelEntity?
    private var waiting:[Entity]=[]
    private var preload:Task<Void,Never>?
    private(set) var loadError:String?

    init() {
        preload=Task { [weak self] in
            do {
                guard let url=Bundle.main.url(forResource:"storm-stitched",withExtension:"png") else {throw CocoaError(.fileNoSuchFile)}
                let texture=try await TextureResource(contentsOf:url,options:.init(semantic:.color))
                var card=MeshDescriptor(name:"Stitched thunderhead alpha card")
                card.positions = .init([[-0.5,-0.5,0],[0.5,-0.5,0],[0.5,0.5,0],[-0.5,0.5,0]])
                card.normals = .init(Array(repeating:[0,0,1],count:4))
                card.textureCoordinates = .init([[0,0],[1,0],[1,1],[0,1]])
                card.primitives = .triangles([0,1,2,0,2,3])
                var material=UnlitMaterial(applyPostProcessToneMap:false)
                material.color = .init(tint:.white,texture:.init(texture))
                material.blending = .transparent(opacity:.init(floatLiteral:1))
                material.faceCulling = .none
                let model=ModelEntity(mesh:try MeshResource.generate(from:[card]),materials:[material])
                model.name="storm-silk"
                model.components.set(DynamicLightShadowComponent(castsShadow:false))
                self?.template=model
                for holder in self?.waiting ?? [] {holder.addChild(model.clone(recursive:true))}
                self?.waiting.removeAll()
            } catch {self?.loadError=String(describing:error)}
        }
    }

    func waitUntilReady() async {await preload?.value}

    func cloud()->Entity {
        let holder=Entity();holder.name="storm-cloud";holder.position=[0,6.9,0];holder.scale=[8.4,5.6,1]
        if let template {holder.addChild(template.clone(recursive:true))} else {waiting.append(holder)}
        return holder
    }
}
