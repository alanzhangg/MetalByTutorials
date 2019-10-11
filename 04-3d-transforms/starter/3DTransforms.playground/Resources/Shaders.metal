#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float pointSize [[point_size]];
};

//vertex VertexOut vertex_main(constant float3 *vertices [[buffer(0)]],
//                             constant float4x4 &matrix [[buffer(1)]],
//                             uint vid [[vertex_id]])
//{
//    VertexOut vo;
//    vo.position = matrix * float4(vertices[vid], 1.0);
//    vo.pointSize = 20;
//    return vo;
//}

vertex VertexOut vertex_main(constant float3 * vertices [[buffer(0)]],
                             constant float4x4 & matrix [[buffer(1)]],
                             uint id [[vertex_id]]){
    VertexOut ou;
    ou.position = matrix * float4(vertices[id], 1);
    ou.pointSize = 20.0;
    return ou;
}

fragment float4 fragment_main(constant float4 &color [[buffer(0)]]) {
    return color;
}
