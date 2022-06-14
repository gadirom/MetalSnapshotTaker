import MetalKit
import SwiftUI
import MetalSnapshotTaker

struct MetalView: UIViewRepresentable {
    
    @Binding var uniforms: Uniforms
    
    let snapshotTaker: MetalSnapshotTaker?
    
    func makeCoordinator() -> Coordinator {
        let coord = Coordinator(self)
        snapshotTaker?
            .setup(device: coord.device,
                   drawIn: coord.draw)
        return coord
    }
    func makeUIView(context: UIViewRepresentableContext<MetalView>) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        mtkView.framebufferOnly = false
        //mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        
        return mtkView
    }
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<MetalView>) {
    }
    class Coordinator: NSObject, MTKViewDelegate {
        
        var parent: MetalView
        
        var device: MTLDevice!
        var rayMarchPass: MTLComputePipelineState!
        var commandQueue: MTLCommandQueue!
        
        init(_ parent: MetalView) {
            self.parent = parent
            if let metalDevice = MTLCreateSystemDefaultDevice() {
                self.device = metalDevice
            }
            
            self.commandQueue = device.makeCommandQueue()!
            
            var library: MTLLibrary!
            
            do{ library = try self.device?.makeLibrary(source: metalFunctions, options: nil)
            }catch{print(error)}
            
            let rayMarchFunc = library?.makeFunction(name: "ray_march")
            
            do{ rayMarchPass = try self.device?.makeComputePipelineState(function: rayMarchFunc!)
            }catch{print(error)}
            
            super.init()
        }
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        }
    }
}

extension MetalView.Coordinator{
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        parent.uniforms.time += 0.01
        
        let commandbuffer = commandQueue.makeCommandBuffer()
        let computeCommandEncoder = commandbuffer?.makeComputeCommandEncoder()
        
        computeCommandEncoder?.setComputePipelineState(rayMarchPass)
        computeCommandEncoder?.setTexture(drawable.texture, index: 0)
        computeCommandEncoder?.setBytes(&parent.uniforms, length: MemoryLayout<Uniforms>.stride, index: 0)
        
        let w = rayMarchPass.threadExecutionWidth
        let h = rayMarchPass.maxTotalThreadsPerThreadgroup / w
        
        let threadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        _ = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1)
        let threadgroupsPerGrid = MTLSize(width: drawable.texture.width / w + 1, height: drawable.texture.height / h + 1, depth: 1)
        
        computeCommandEncoder?.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        computeCommandEncoder?.endEncoding()
        
        commandbuffer?.present(drawable)
        commandbuffer?.commit()
        commandbuffer?.waitUntilCompleted()
    }
}
