import RealityKit
import UIKit
import simd

/// One preloaded photographic cloud, shared across hazards. Rain and shade stay local to the strike.
@MainActor final class StormVFX {
    private var template:ModelEntity?
    private var waiting:[Entity]=[]
    private var preload:Task<Void,Never>?
    private(set) var loadError:String?
    func waitUntilReady() async {await preload?.value}
    init() {
        preload=Task { [weak self] in
            do {
                guard let url=Bundle.main.url(forResource:"storm-threat",withExtension:"png") else {throw CocoaError(.fileNoSuchFile)}
                let texture=try await TextureResource(contentsOf:url,options:.init(semantic:.color))
                var d=MeshDescriptor(name:"Storm cloud alpha card")
                d.positions = .init([[-0.5,-0.5,0],[0.5,-0.5,0],[0.5,0.5,0],[-0.5,0.5,0]])
                d.normals = .init(Array(repeating:[0,0,1],count:4))
                d.textureCoordinates = .init([[0,0],[1,0],[1,1],[0,1]])
                d.primitives = .triangles([0,1,2,0,2,3])
                var material=UnlitMaterial(applyPostProcessToneMap:false)
                material.color = .init(tint:.white,texture:.init(texture));material.blending = .transparent(opacity:.init(floatLiteral:1));material.faceCulling = .none
                let model=ModelEntity(mesh:try MeshResource.generate(from:[d]),materials:[material]);model.name="storm-photo"
                model.components.set(DynamicLightShadowComponent(castsShadow:false))
                self?.template=model
                for holder in self?.waiting ?? [] {self?.install(model,on:holder)}
                self?.waiting.removeAll()
            } catch {self?.loadError=String(describing:error)}
        }
    }
    private func install(_ model:ModelEntity,on holder:Entity) {
        holder.addChild(model.clone(recursive:true))
        let scud=model.clone(recursive:true);scud.name="storm-scud"
        scud.components.set(OpacityComponent(opacity:0.16));scud.position=[0,-0.05,0.025]
        holder.addChild(scud)
    }
    func cloud()->Entity {
        let holder=Entity();holder.name="storm-cloud";holder.position=[0,7.3,0];holder.scale=[12,8,1]
        if let template {install(template,on:holder)} else {waiting.append(holder)}
        return holder
    }
}
