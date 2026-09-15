import RealityKit
import UIKit

/// One collage renderer. This resource supplies illumination, never a visible backdrop.
@MainActor final class DreamArtDirection {
    let collage=HybridDreamLayers()
    private var illumination:EnvironmentResource?
    private var applied=false
    private(set) var environmentApplications=0
    func invalidateEnvironment() {applied=false}
    func reset() {collage.reset()}
    func rebase(by shift:SIMD3<Float>) {collage.rebase(by:shift)}
    func baseMaterials(of model:ModelEntity)->[PhysicallyBasedMaterial] {
        model.model?.materials.compactMap{$0 as? PhysicallyBasedMaterial} ?? []
    }
    func replaceBaseMaterials(of model:ModelEntity,with materials:[PhysicallyBasedMaterial]) {
        model.model?.materials=materials
    }
    func environment(view:ARView) {
        guard !applied else{return}
        if illumination == nil {
            let format=UIGraphicsImageRendererFormat();format.scale=1
            let image=UIGraphicsImageRenderer(size:CGSize(width:128,height:64),format:format).image {ctx in
                UIColor(white:0.75,alpha:1).setFill();ctx.fill(CGRect(x:0,y:0,width:128,height:64))
            }
            if let cg=image.cgImage {illumination=try? EnvironmentResource(equirectangular:cg)}
        }
        view.environment.background = .color(UIColor(hex:"#77748F"))
        view.environment.lighting.resource=illumination
        view.environment.lighting.intensityExponent = -0.5
        applied=true;environmentApplications += 1
    }
}
