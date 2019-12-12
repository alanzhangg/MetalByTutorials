import PlaygroundSupport
import MetalKit

var str = "Hello, playground"

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("GPU is not supported")
}

let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
let view = MTKView(frame: frame, device: device)
view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)

let allocator = MTKMeshBufferAllocator(device: device)

let mdlMesh = MDLMesh(sphereWithExtent: [0.2, 0.75, 0.2],
                      segments: [100, 100],
                      inwardNormals: false,
                      geometryType: .triangles,
                      allocator: allocator)
let mesh = try MTKMesh(mesh: mdlMesh, device: device)
print(mesh.vertexDescriptor.description)

guard let commandQuene = device.makeCommandQueue() else {
    fatalError("Could not create a command quene")
}

let shader = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float4 position [[ attribute(0) ]];
};

vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]]) {
  return vertex_in.position;
}

fragment float4 fragment_main() {
  return float4(0, 0.4, 0.21, 1);
}
"""
let library = try device.makeLibrary(source: shader, options: nil)
let vertexFunction = library.makeFunction(name: "vertex_main")
let fragmentFunction = library.makeFunction(name: "fragment_main")

let descriptor = MTLRenderPipelineDescriptor()
descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
descriptor.vertexFunction = vertexFunction
descriptor.fragmentFunction = fragmentFunction
descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
let pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)

guard let commandBuffer = commandQuene.makeCommandBuffer(),
    let descriptor = view.currentRenderPassDescriptor,
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else{
        fatalError()
}

renderEncoder.setRenderPipelineState(pipelineState)
renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

guard let submesh = mesh.submeshes.first else { fatalError() }

renderEncoder.drawIndexedPrimitives(type: .triangle,
                                    indexCount: submesh.indexCount,
                                    indexType: submesh.indexType,
                                    indexBuffer: submesh.indexBuffer.buffer,
                                    indexBufferOffset: 0)
renderEncoder.endEncoding()
guard let drawable = view.currentDrawable else {
    fatalError()
}

commandBuffer.present(drawable)
commandBuffer.commit()

PlaygroundPage.current.liveView = view


