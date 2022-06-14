import SwiftUI
import MetalKit

/// Class that allows taking snapshots of any size from MTKView
public class MetalSnapshotTaker{
    
    private var snapshotSize: CGSize{
        didSet{
            snapshotTexture = makeSnapshotTexture(size: snapshotSize)
        }
    }
    var device: MTLDevice!
    var snapshotTexture: MTLTexture?
    var drawIn: ((MTKView)->())?
    var sizeChange: ((MTKView, CGSize)->())?
    
    var currentSize: CGSize?
    var takingSnapshot = false
    
    public init(size: CGSize){
        snapshotSize = size
    }
    /// Call this method before taking snapshots
    /// - Parameters:
    ///   - device: device from `MTKView`
    ///   - drawIn: reference to `draw` method of `MTKView`
    ///   - onSizeChange: optional reference to `mtkView` method if you use this method to change rendering behaviour
    public func setup(device: MTLDevice,
                      drawIn: @escaping ((MTKView)->()),
                      onSizeChange: ((MTKView, CGSize)->())? = nil){
        self.sizeChange = onSizeChange
        self.drawIn = drawIn
        self.device = device
        if snapshotTexture == nil{
            DispatchQueue.global(qos: .background).async{ [self] in
                snapshotTexture = makeSnapshotTexture(size: snapshotSize)
            }
        }
    }
    /// Call this method from `mtkView` method of MTKView to "remember" current size of `MTKView`
    /// - Parameter size: pass `size` parameter from `mtkView` method
    public func setCurrentSize(_ size: CGSize) {
        if !takingSnapshot{
            currentSize = size
        }
    }
    func takeTexture()->MTLTexture?{
        guard let draw = drawIn
        else { return nil}
        let rect = CGRect(origin: .zero, size: snapshotSize)
        let mtkView = MTKView(frame: rect, device: device)
        mtkView.framebufferOnly = false
        mtkView.contentScaleFactor = 1
        mtkView.colorPixelFormat = .bgra8Unorm
        if let sizeChange = sizeChange{
            takingSnapshot = true
            sizeChange(mtkView, snapshotSize)
            takingSnapshot = false
        }
        draw(mtkView)
        if let currentSize = currentSize {
            sizeChange!(mtkView, currentSize)
        }
        guard let drawable = mtkView.currentDrawable
        else {
            print("no drawable")
            return nil
        }
        return drawable.texture
    }
}
public extension MetalSnapshotTaker{
    func take()->UIImage?{
        let texture = takeTexture()
        guard let uiImage = texture?.uiImage
        else {
            print("no image!")
            return nil
        }
        return uiImage
    }
    func take()->CGImage?{
        let texture = takeTexture()
        guard let cgImage = texture?.cgImage
        else {
            print("no image!")
            return nil
        }
        return cgImage
    }
    func take()->Image?{
        guard let uiImage: UIImage = take()
        else {
            print("no image!")
            return nil
        }
        return Image(uiImage: uiImage)
    }
}
extension MetalSnapshotTaker{
    func makeSnapshotTexture(size: CGSize) -> MTLTexture{
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.textureType = MTLTextureType.type2D
        texDescriptor.width = Int(size.width)
        texDescriptor.height = Int(size.height)
        texDescriptor.pixelFormat = .rgba8Unorm
        texDescriptor.usage = [.shaderWrite, .shaderRead]
        return device!.makeTexture(descriptor: texDescriptor)!
    }
}
