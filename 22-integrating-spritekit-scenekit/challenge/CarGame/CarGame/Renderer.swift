/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import MetalKit

class Renderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var colorPixelFormat: MTLPixelFormat!
  static var library: MTLLibrary?
  static var commandBuffer: MTLCommandBuffer?
  
  var depthStencilState: MTLDepthStencilState!
  
  var scene: Scene?
  
  lazy var lights: [Light] = {
    return lighting()
  }()

  init(metalView: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice() else {
      fatalError("GPU not available")
    }
    metalView.depthStencilPixelFormat = .depth32Float
    metalView.device = device
    metalView.sampleCount = 4
    Renderer.device = device
    Renderer.commandQueue = device.makeCommandQueue()!
    Renderer.colorPixelFormat = metalView.colorPixelFormat
    Renderer.library = device.makeDefaultLibrary()
    
    super.init()
    metalView.clearColor = MTLClearColor(red: 0.7, green: 0.9,
                                         blue: 1, alpha: 1)
    metalView.delegate = self
    metalView.framebufferOnly = false

    mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    buildDepthStencilState()
  }
  
  func buildDepthStencilState() {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    depthStencilState =
      Renderer.device.makeDepthStencilState(descriptor: descriptor)
  }
}

extension Renderer: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    scene?.sceneSizeWillChange(to: size)
  }

  func draw(in view: MTKView) {
    guard let descriptor = view.currentRenderPassDescriptor,
      let scene = scene,
      let commandBuffer = Renderer.commandQueue.makeCommandBuffer() else {
        return
    }

    Renderer.commandBuffer = commandBuffer
    
    let deltaTime = 1 / Float(view.preferredFramesPerSecond)
    scene.update(deltaTime: deltaTime)

    guard let renderEncoder =
      commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
        return
    }

    renderEncoder.setDepthStencilState(depthStencilState)
    
    var fragmentUniforms = FragmentUniforms()
    fragmentUniforms.lightCount = UInt32(lights.count)

    renderEncoder.setFragmentBytes(&fragmentUniforms,
                                   length: MemoryLayout<FragmentUniforms>.stride,
                                   index: Int(BufferIndexFragmentUniforms.rawValue))

    renderEncoder.setFragmentBytes(&lights,
                                   length: MemoryLayout<Light>.stride * lights.count,
                                   index: Int(BufferIndexLights.rawValue))

    for renderable in scene.renderables {
      renderEncoder.pushDebugGroup(renderable.name)
      renderable.render(renderEncoder: renderEncoder,
                        uniforms: scene.uniforms,
                        fragmentUniforms: fragmentUniforms)
      renderEncoder.popDebugGroup()
    }

    scene.skybox?.render(renderEncoder: renderEncoder,
                         uniforms: scene.uniforms)

    renderEncoder.endEncoding()
    guard let drawable = view.currentDrawable else {
      return
    }
    
    scene.postProcessNodes.forEach { node in
      node.postProcess(inputTexture: drawable.texture)
    }

    commandBuffer.present(drawable)
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
    Renderer.commandBuffer = nil
  }
}
