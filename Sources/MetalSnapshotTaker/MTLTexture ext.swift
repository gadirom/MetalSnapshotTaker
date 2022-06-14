import SwiftUI
import MetalKit

extension MTLTexture{
    public var cgImage: CGImage? {
        guard let image = self.ciImage else {
            return nil
        }
        let flipped = image.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
        let opt = [CIContextOption.outputPremultiplied: true,
                   CIContextOption.useSoftwareRenderer: false]
        let cont = CIContext(options: opt)
        return cont.createCGImage(flipped, from: flipped.extent)
    }
    public var ciImage: CIImage?{
        let opt =  [CIImageOption.colorSpace: CGColorSpaceCreateDeviceRGB()]
        guard let image = CIImage(mtlTexture: self, options: opt)
        else {
            print("CIImage not created")
            return nil
        }
        return image
    }
    public var uiImage: UIImage?{
        guard let cgImage = self.cgImage
        else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage
    }
}
