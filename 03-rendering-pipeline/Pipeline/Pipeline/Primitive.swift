//
//  Primitive.swift
//  Pipeline
//
//  Created by zyyk on 2019/12/10.
//  Copyright © 2019 zyyk. All rights reserved.
//

import Foundation
import MetalKit

class Primitive {
    class func makeCube(device: MTLDevice, size: Float) -> MDLMesh{
        let allocator = MTKMeshBufferAllocator(device: device)
        let mesh = MDLMesh(boxWithExtent: [size, size, size],
                           segments: [1, 1, 1],
                           inwardNormals: false,
                           geometryType: .triangles,
                           allocator: allocator)
        return mesh
    }
}
