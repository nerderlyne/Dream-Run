/// Resolves intent while the finger is moving, without waiting for release.
/// One action per contact; reset on completion, cancellation or phase change.
public struct RunnerSwipe {
    public enum Action: Equatable { case jump, slide }
    private var committed=false
    public init() {}
    public mutating func update(x:Double,y:Double)->Action? {
        guard !committed, x.isFinite, y.isFinite,
              abs(y)>=24, abs(y)>abs(x)*1.2 else {return nil}
        committed=true
        return y<0 ? .jump : .slide
    }
}
