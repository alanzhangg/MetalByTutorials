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

class Node {
  var name: String = "untitled"
  var position: float3 = [0, 0, 0]
  var rotation: float3 = [0, 0, 0] {
    didSet {
      let rotationMatrix = float4x4(rotation: rotation)
      quaternion = simd_quatf(rotationMatrix)
    }
  }
  var scale: float3 = [1, 1, 1]
  var quaternion = simd_quatf()
  
  var boundingBox = MDLAxisAlignedBoundingBox()
  var size: float3 {
    return boundingBox.maxBounds - boundingBox.minBounds
  }

  var modelMatrix: float4x4 {
    let translateMatrix = float4x4(translation: position)
    let rotateMatrix = float4x4(quaternion)
    let scaleMatrix = float4x4(scaling: [scale.x, scale.y, -scale.z])
    return translateMatrix * rotateMatrix * scaleMatrix
  }
  
}

