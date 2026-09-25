public enum DreamCollageKit {
    public static var skyIDs:[String] {DreamPlateLibrary.assets.map(\.id)}
    public static let assets:[DreamRepresentation] = DreamOwnerObjectKit.assets + DreamPlateLibrary.assets
}
