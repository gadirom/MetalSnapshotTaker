# MetalSnapshotTaker
<p align="center">
    <img src="https://img.shields.io/badge/platforms-iOS_13_-blue.svg" alt="iOS" />
    <a href="https://swift.org/about/#swiftorg-and-open-source"><img src="https://img.shields.io/badge/Swift-5.6-orange.svg" alt="Swift 5.6" /></a>
    <a href="https://developer.apple.com/metal/"><img src="https://img.shields.io/badge/Metal-2.4-green.svg" alt="Metal 2.4" /></a>
    <a href="https://apps.apple.com/ru/app/swift-playgrounds/id908519492?l=en"><img src="https://img.shields.io/badge/SwiftPlaygrounds-4.1-orange.svg" alt="Swift Playgrounds 4.1" /></a>
   <a href="https://en.wikipedia.org/wiki/MIT_License"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT" /></a>
    
</p>

This package contains `MetalSnapshotTaker` class that allows exporting of images of arbitrary sizes from the output of `MTKView` subclass with minimal alterations in it's code. 
Usable in SwiftUI context and outputs an image in one of these formats: `UIImage`, `CGImage`, `Image`.

## How to Use

Create an instance of `MetalSnapshotTaker` either in your `MTKView` or in `UIViewRepresentable` that holds it. Call the `update` method (this can be done from Coordinator's init) passing an instance of MTLDevice, and references to `draw`, and `mtkView` methods of you MTKView subclass. The last one only needed if you use it to modify rendering, in which case the `setCurrentSize` shoud be called from it.

## Example

An example Swift Playgrounds app: [MetalSnapshotTaker example](https://github.com/gadirom/MetalSnapshotTaker/tree/main/MetalSnapshotTaker%20example.swiftpm)

<p align="center">
    <img src="https://github.com/gadirom/MetalSnapshotTaker/blob/main/SnapshotTaker.gif" alt="example" />
</p>
