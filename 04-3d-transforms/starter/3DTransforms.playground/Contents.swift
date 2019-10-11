import MetalKit
import PlaygroundSupport

struct Point {
    var is3D: Bool
    var x: float4x4
    var y: Float
}
var size = MemoryLayout<Point>.size
var stride = MemoryLayout<Point>.stride
var alignment = MemoryLayout<Point>.alignment
var offset = MemoryLayout<Point>.offset(of: \Point.is3D)
size = MemoryLayout<float4x4>.size

// set up View
device = MTLCreateSystemDefaultDevice()!
let frame = NSRect(x: 0, y: 0, width: 1200, height: 1200)
let view = MTKView(frame: frame, device: device)
view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
view.device = device

var vertices: [simd_float3] = [
    [-0.7,  0.8,   1],
    [-0.7, -0.4,   1],
    [ 0.4,  0.2,   1]
]

var pointColor = float4(1.0, 0.0, 0.8, 1.0)
var blackColor = float4(0,0,0,0)

// Metal set up is done in Utility.swift

// set up render pass
guard let drawable = view.currentDrawable,
  let descriptor = view.currentRenderPassDescriptor,
  let commandBuffer = commandQueue.makeCommandBuffer(),
  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
    fatalError()
}
renderEncoder.setRenderPipelineState(pipelineState)

var matrix = matrix_identity_float4x4

// drawing code here
//var vertices = [SIMD3<Float>(0, 0, 0.5)]
let originalBuffer = device.makeBuffer(bytes: &vertices,
                                       length: MemoryLayout<SIMD3<Float>>.stride * vertices.count,
                                       options: [])

renderEncoder.setVertexBytes(vertices, length: MemoryLayout<float3>.stride * vertices.count, index: 0)
renderEncoder.setVertexBytes(&matrix, length: MemoryLayout<float4x4>.stride, index: 1)
renderEncoder.setVertexBuffer(originalBuffer, offset: 0, index: 0)
renderEncoder.setFragmentBytes(&lightGrayColor, length: MemoryLayout<SIMD4<Float>>.stride, index: 0)
renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)

//matrix.columns.3 = [0.3, -0.4, 0, 1]
//let scaleX: Float = 1.2
//let scaleY: Float = 0.5
//matrix.columns.0 = [scaleX, 0, 0, 0]
//matrix.columns.1 = [0, scaleY, 0, 0];
let angle = Float.pi / 2.0
var distanceVector = simd_float4(vertices.last!.x, vertices.last!.y, vertices.last!.z, 1)
var translate = matrix_identity_float4x4
translate.columns.3 = distanceVector
var rotate = matrix_identity_float4x4
rotate.columns.0 = [cos(angle), -sin(angle), 0, 0]
rotate.columns.1 = [sin(angle), cos(angle), 0, 0]
//matrix = translate.inverse
matrix = translate * rotate * translate.inverse

//vertices = vertices.map{
//    var vertex = SIMD4<Float>($0.x, $0.y, $0.x, 1)
//    vertex = matrix * vertex
//    return [vertex.x, vertex.y, vertex.z]
//}
var transformedBuffer = device.makeBuffer(bytes: &vertices,
                                          length: MemoryLayout<SIMD3<Float>>.stride * vertices.count,
                                          options: [])
renderEncoder.setVertexBytes(&matrix, length: MemoryLayout<float4x4>.stride, index: 1)
renderEncoder.setVertexBuffer(transformedBuffer, offset: 0, index: 0)
renderEncoder.setFragmentBytes(&redColor, length: MemoryLayout<SIMD4<Float>>.stride, index: 0)
renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)


//renderEncoder.setFragmentBytes(&pointColor, length: MemoryLayout<float4>.stride, index: 0)


//let last = vertices[2]
//let distance = float4(last.x, last.y, last.z, 1.0)
//
//var translation = matrix_identity_float4x4
//translation.columns.3 = distance
//
//let angle = Float.pi / 2.0
//var rotation = matrix_identity_float4x4
//rotation.columns.0 = [cos(angle), -sin(angle), 0, 0]
//rotation.columns.1 = [sin(angle), cos(angle), 0, 0]
//
//matrix = translation * rotation * translation.inverse
//
//renderEncoder.setVertexBytes(vertices, length: MemoryLayout<float3>.stride * vertices.count, index: 0)
//renderEncoder.setVertexBytes(&matrix, length: MemoryLayout<float4x4>.stride, index: 1)
//
//renderEncoder.setFragmentBytes(&blackColor, length: MemoryLayout<float4>.stride, index: 0)
//renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)

renderEncoder.endEncoding()
commandBuffer.present(drawable)
commandBuffer.commit()



PlaygroundPage.current.liveView = view
