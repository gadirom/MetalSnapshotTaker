# MetalSnapshotTaker

This package contains `MetalSnapshotTaker` class that allows taking snapshots of arbitrary sizes from an `MTKView` subclass with minimal alterations in it`s code. 
Usable in SwiftUI context and outputs an image in one of these formats: `UIImage`, `CGImage`, `Image`.

## How to Use

Create an instance of `MetalSnapshotTaker` either in your `MTKView` or in `UIViewRepresentable` that holds it. Call the `update` method (this can be done from Coordinator`s init) passing an instance of MTLDevice, and references to `draw`, and `mtkView` methods of you MTKView subclass. The last one only needed if you use it to modify rendering, in which case the `setCurrentSize` shoud be called from it.
