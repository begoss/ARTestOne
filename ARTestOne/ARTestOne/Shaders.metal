#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float4x4 model_matrix;
} UniformModelM;

typedef struct
{
    float4x4 view_matrix;
} UniformViewM;

typedef struct
{
    float4x4 projection_matrix;
} UniformProjectionM;

typedef struct
{
    float u_time;
} UniformTime;

typedef struct
{
    packed_float4 position;
    packed_float4 color;
    packed_float3 normal;
    packed_float2 texcoord;
} VertexIn;

typedef struct {
    float4 position [[position]];
    float4 color;
    float3 normal;
    float2 texcoord;
} VertexOut;

vertex VertexOut vertex_function_color(device VertexIn *vertices [[buffer(0)]],
                                            constant UniformViewM &uniform_view_matrix [[buffer(1)]],
                                            constant UniformProjectionM &uniform_projection_matrix [[buffer(2)]],
                                            uint vid [[vertex_id]])
{
    VertexOut out;
    out.position = uniform_projection_matrix.projection_matrix * uniform_view_matrix.view_matrix * (float4)vertices[vid].position;
    out.color = vertices[vid].color;
    out.normal = vertices[vid].normal;
    out.texcoord = vertices[vid].texcoord;
    return out;
}

fragment float4 fragment_function_color(VertexOut in [[stage_in]])
{
    return in.color;
}

vertex VertexOut vertex_function_texture(device VertexIn *vertices [[buffer(0)]],
                                constant UniformViewM &uniform_view_matrix [[buffer(1)]],
                                constant UniformProjectionM &uniform_projection_matrix [[buffer(2)]],
                                       uint vid [[vertex_id]])
{
    VertexOut out;
    out.position =  (float4)vertices[vid].position;
    out.texcoord = vertices[vid].texcoord;
    return out;
}

fragment float4 fragment_function_texture(VertexOut in [[stage_in]],
                                       texture2d<float> diffuseTexture [[texture(0)]],
                                       sampler samplr [[sampler(0)]])
{
    float4 diffuseColor = diffuseTexture.sample(samplr, in.texcoord);
    return diffuseColor;
}
