import SwiftUI

/// A short receipt beside the currency total, rather than a second progression currency.
struct BalloonCounter:View {
    let total:Int
    let tick:UInt64
    let runID:UUID
    let reducedMotion:Bool
    @State private var gained=0
    @State private var started:UInt64=0
    private var progress:Double {min(1,Double(tick>=started ? tick-started:60)/54)}
    var body:some View {
        Label("\(total)",systemImage:"balloon")
            .monospacedDigit()
            .scaleEffect(reducedMotion || gained==0 ? 1:1+0.16*sin(progress * .pi))
            .overlay(alignment:.topTrailing) {
                if gained>0 && progress<1 {
                    Label("+\(gained)",systemImage:"balloon.fill")
                        .font(.system(size:15,weight:.bold)).foregroundStyle(.white)
                        .fixedSize(horizontal:true,vertical:true)
                        .padding(7).background(.black.opacity(0.35),in:Capsule())
                        .offset(x:0,y:reducedMotion ? 32:48*(1-progress))
                        .opacity(1-progress).allowsHitTesting(false).accessibilityHidden(true)
                }
            }
            .accessibilityLabel("\(total) balloons collected")
            .onChange(of:total) {old,new in
                guard new>old else {gained=0;return}
                gained=(progress<0.35 ? gained:0)+(new-old);started=tick
            }
            .onChange(of:runID) {_,_ in gained=0;started=tick}
    }
}
