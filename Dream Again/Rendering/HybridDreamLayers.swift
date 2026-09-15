import RealityKit
import UIKit

/// Fixed pool: 20 semantic cards, three atmospheric cards and two sky cards; no decoding or mesh creation in update.
@MainActor final class HybridDreamLayers {
    @MainActor private final class Slot {
        let model:ModelEntity
        var key=""
        var imageAspect:Float=1
        var placement:DreamCollagePlacement?
        var basePosition=SIMD3<Float>.zero
        init(mesh:MeshResource) {
            model=ModelEntity(mesh:mesh,materials:[]);model.isEnabled=false
            model.components.set(DynamicLightShadowComponent(castsShadow:false))
        }
    }
    let root=Entity()
    private var slots:[Slot]=[],atmosphere:[Slot]=[],skies:[Slot]=[]
    // Blend every transparent layer before writing their depths. Otherwise a clear
    // part of a nearer quad can clip a farther card into a visible rectangle.
    private let sortGroup=ModelSortGroup(depthPass:.postPass)
    private var textures:[String:TextureResource]=[:]
    private var preload:Task<Void,Never>?
    private var skyLoad:Task<Void,Never>?
    private var requestedSky=""
    private var cutoutsReady=false
    var residentPlateCount:Int {textures.keys.filter{$0.hasPrefix("plate_")}.count}
    private var skyIndex=0
    private var selectionKey=""
    private var selectedIdentity:DreamIdentity?
    private var selectedSky:DreamRepresentation?
    private var skyStarted:Double?
    private var skyDuration=24.0
    private(set) var loadErrors:[String]=[]
    private(set) var loadedTextureCount=0
    private(set) var activeCardCount=0
    var ready:Bool {cutoutsReady && (requestedSky.isEmpty || textures[requestedSky] != nil)}
    var previewPlate:String?
    var previewVignette:DreamVignette?
    var reducedMotion=false
    var previewScale:DreamScaleEvent?
    var previewFraming:DreamScaleFraming?
    var pooledCardCount:Int {slots.count+atmosphere.count+skies.count}
    var activeAtmosphereCount:Int {atmosphere.filter{$0.model.isEnabled}.count}
    var cardPositions:[SIMD3<Float>] {(slots+atmosphere).map{$0.model.position}}
    init() {
        root.name="dream-collage"
        var d=MeshDescriptor(name:"collage-unit-quad")
        d.positions = .init([[-0.5,-0.5,0],[0.5,-0.5,0],[0.5,0.5,0],[-0.5,0.5,0]])
        d.normals = .init(Array(repeating:SIMD3<Float>(0,0,1),count:4))
        // RealityKit's imported texture coordinates use the bottom-left origin here.
        d.textureCoordinates = .init([[0,0],[1,0],[1,1],[0,1]])
        d.primitives = .triangles([0,1,2,0,2,3])
        do {
            let mesh=try MeshResource.generate(from:[d])
            slots=(0..<DreamCollageComposition.slotCount).map{_ in Slot(mesh:mesh)}
            atmosphere=(0..<DreamAtmosphere.slotCount).map{_ in Slot(mesh:mesh)}
            skies=(0..<2).map{_ in Slot(mesh:mesh)}
            for slot in skies+slots+atmosphere {root.addChild(slot.model)}
        } catch {loadErrors.append("Quad: \(error)")}
        preload=Task { [weak self] in
            let assets=DreamCollageKit.assets.filter{!$0.isPlate}
            for asset in assets {
                guard !Task.isCancelled else{return}
                guard let url=Bundle.main.url(forResource:asset.resource,withExtension:asset.resourceExtension) else {
                    self?.loadErrors.append("Missing \(asset.resource).\(asset.resourceExtension)");continue
                }
                do {
                    let texture=try await TextureResource(contentsOf:url,options:.init(semantic:.color))
                    self?.textures[asset.id]=texture
                    self?.loadedTextureCount=self?.textures.count ?? 0
                } catch {self?.loadErrors.append("\(asset.id): \(error)")}
            }
            self?.cutoutsReady=true
        }
    }
    func waitForPreload() async {await preload?.value;await skyLoad?.value}
    private func requestPlate(_ asset:DreamRepresentation) {
        requestedSky=asset.id
        guard textures[asset.id] == nil,skyLoad == nil else {return}
        skyLoad=Task { [weak self] in
            guard let url=Bundle.main.url(forResource:asset.resource,withExtension:asset.resourceExtension) else {
                self?.loadErrors.append("Missing plate \(asset.id)");self?.skyLoad=nil;return
            }
            do {
                let texture=try await TextureResource(contentsOf:url,options:.init(semantic:.color))
                guard let self else {return}
                self.textures[asset.id]=texture
                let pinned=Set(self.skies.map(\.key)+[self.requestedSky])
                for id in self.textures.keys.sorted() where id.hasPrefix("plate_") && !pinned.contains(id) {
                    self.textures.removeValue(forKey:id)
                }
                self.loadedTextureCount=self.textures.count
            } catch {self?.loadErrors.append("Plate \(asset.id): \(error)")}
            self?.skyLoad=nil
        }
    }
    func reset() {
        for slot in slots+atmosphere+skies {slot.key="";slot.placement=nil;slot.model.isEnabled=false}
        skyStarted=nil;skyIndex=0;activeCardCount=0
    }
    func rebase(by shift:SIMD3<Float>) {for slot in slots+atmosphere {slot.model.position += shift;slot.basePosition += shift}}
    private func assign(_ asset:DreamRepresentation,to slot:Slot)->Bool {
        guard let texture=textures[asset.id] else{return false}
        var material=UnlitMaterial(applyPostProcessToneMap:false)
        material.color = .init(tint:.white,texture:.init(texture))
        material.blending = .transparent(opacity:.init(floatLiteral:1))
        material.faceCulling = .none
        slot.imageAspect=asset.aspect
        slot.model.model?.materials=[material];slot.model.name="collage:\(asset.id)"
        return true
    }
    private func opacity(_ slot:Slot,_ value:Float) {
        slot.model.isEnabled=value>0.002
        slot.model.components.set(OpacityComponent(opacity:max(0,min(1,value))))
    }
    func update(run:RunState,origin:RouteSample,world:Entity,camera:PerspectiveCamera,aspect:Float,lowPower:Bool,voidWeight:Double) {
        guard slots.count == DreamCollageComposition.slotCount,skies.count == 2 else{return}
        if root.parent == nil {world.addChild(root)}
        root.isEnabled=true
        let density=DreamCollageComposition.density(seconds:run.seconds,visual:run.visual,voidWeight:voidWeight)
        let nextSelection="\(Int(run.distance/1600)):\(run.mirrorCount+run.dropCount):\(previewPlate ?? "")"
        if nextSelection != selectionKey || selectedIdentity != run.identity || selectedSky == nil {
            selectedSky=DreamPlateLibrary.assets.first{$0.id == previewPlate} ?? DreamCollageComposition.plate(identity:run.identity,section:Int(run.distance/1600),transition:run.mirrorCount+run.dropCount)
            selectionKey=nextSelection;selectedIdentity=run.identity
        }
        guard let sky=selectedSky else {return}
        requestPlate(sky)
        let current=skies[skyIndex],incoming=skies[1-skyIndex]
        if current.key.isEmpty,assign(sky,to:current) {current.key=sky.id}
        if current.key != sky.id && skyStarted == nil && !current.key.isEmpty,assign(sky,to:incoming) {
            incoming.key=sky.id;skyStarted=run.seconds
            skyDuration=run.phase == .mirrorCrossing || run.phase == .safeDrop ? 1.8:24
        }
        let fade=skyStarted.map{Float(min(1,max(0,(run.seconds-$0)/skyDuration)))} ?? 0
        let skyVisibility:Float=run.pigs.count>=3 ? max(0,1-Float(run.endingElapsed/12)) : min(1,density*3)
        for (i,slot) in skies.enumerated() {
            let depth:Float=i == skyIndex ? 5000:4999
            let height=2*depth*tan(camera.camera.fieldOfViewInDegrees * .pi/360)*1.08
            let plateAspect=slot.key.isEmpty ? sky.aspect:slot.imageAspect
            let width=max(height*plateAspect,height*max(0.1,aspect))
            slot.model.scale=[width,width/plateAspect,1]
            slot.model.orientation=camera.orientation
            slot.model.position=camera.position+camera.orientation.act([0,0,-depth])
            opacity(slot,slot.key.isEmpty ? 0 : skyVisibility*(i == skyIndex ? 1:fade))
        }
        if fade>=1 {opacity(current,0);current.model.model?.materials=[];current.key="";skyIndex=1-skyIndex;skyStarted=nil}
        let generator=WorldGenerator(run.identity)
        let layers=slots+atmosphere
        for i in layers.indices {
            let slot=layers[i],isAtmosphere=i>=slots.count,a=i-slots.count
            let period=isAtmosphere ? DreamAtmosphere.period(slot:a):DreamCollageComposition.period(slot:i)
            let cell=isAtmosphere ? DreamAtmosphere.cell(distance:run.distance,slot:a):DreamCollageComposition.cell(distance:run.distance,slot:i)
            let p:DreamCollagePlacement
            if let cached=slot.placement,cached.cell == cell {p=cached}
            else if isAtmosphere {p=DreamAtmosphere.placement(identity:run.identity,distance:run.distance,slot:a)}
            else if i>=16,let scene=previewVignette {p=scene.placement(identity:run.identity,distance:run.distance,part:i-16,scaleEvent:previewScale)}
            else {p=DreamCollageComposition.placement(identity:run.identity,distance:run.distance,slot:i,scaleEvent:previewScale,framing:previewFraming)}
            let key="\(p.cell):\(p.representation.id)"
            if slot.key != key {
                guard assign(p.representation,to:slot) else {opacity(slot,0);continue}
                slot.key=key;slot.placement=p
                let s=generator.sample(p.anchorDistance)
                let forward=SIMD3<Float>(Float(sin(s.yaw)),0,-Float(cos(s.yaw)))
                let right=SIMD3<Float>(Float(cos(s.yaw)),0,Float(sin(s.yaw)))
                slot.model.position=[Float(s.x-origin.x),Float(s.y-origin.y),Float(s.z-origin.z)]
                slot.model.position += forward*p.depth+right*p.lateral+[0,p.elevation,0]
                slot.basePosition=slot.model.position
            }
            let motion=DreamScenicMotion.sample(id:p.representation.id,seconds:run.seconds,slot:i,reduced:reducedMotion || lowPower)
            let motionScale=min(1,p.height/40)
            slot.model.position=slot.basePosition+camera.orientation.act([motion.offset.x*motionScale,motion.offset.y*motionScale,0])
            slot.model.scale=[p.height*p.representation.aspect*(p.mirrored ? -1:1)*motion.scale,p.height*motion.scale,1]
            slot.model.orientation=camera.orientation*simd_quatf(angle:p.roll+motion.roll,axis:[0,0,1])
            let age=run.distance-p.anchorDistance
            let fadeDistance:Double=isAtmosphere ? 96:24
            let edge=Float(min(1,max(0,age/fadeDistance))*min(1,max(0,(period-age)/fadeDistance)))
            let rank:Float=i>=16 ? 0.12:Float((i*7)%16)/16
            let population=isAtmosphere ? DreamAtmosphere.weight(density:density,slot:a,lowPower:lowPower):max(0,min(1,(density-rank)*8))
            let delta=camera.orientation.inverse.act(slot.model.position-camera.position),z = -delta.z
            let coversRoute=abs(delta.x)-abs(slot.model.scale.x)*0.5<z*0.10 && delta.y-slot.model.scale.y*0.5<z*0.06
            let readability:Float=coversRoute ? (isAtmosphere ? 0.65:p.representation.concept != .cloud ? 0.65:1):1
            let visible:Float=z>35 && (!lowPower || i<10 || isAtmosphere) ? 1:0
            let angularExtent=max(abs(slot.model.scale.x),slot.model.scale.y)/max(1,z)
            let scaleVisibility:Float=isAtmosphere ? 1:DreamScaleComposition.visibility(extent:angularExtent,role:p.scaleRole)
            opacity(slot,p.opacity*edge*population*visible*readability*scaleVisibility*(run.pigs.count>=3 ? 0:1))
        }
        let cameraInverse=camera.orientation.inverse
        let ordered=(skies+layers).sorted {
            cameraInverse.act($0.model.position-camera.position).z < cameraInverse.act($1.model.position-camera.position).z
        }
        for (order,slot) in ordered.enumerated() {
            let value=Int32(order)
            if slot.model.components[ModelSortGroupComponent.self]?.order != value {
                slot.model.components.set(ModelSortGroupComponent(group:sortGroup,order:value))
            }
        }
        activeCardCount=ordered.filter{$0.model.isEnabled}.count
    }
}
