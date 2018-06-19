//
//  MetalTypes.h
//  WaterAnimation
//
//  Created by begoss on 2018/1/3.
//  Copyright © 2018年 begoss. All rights reserved.
//

#ifndef MetalTypes_h
#define MetalTypes_h

typedef struct
{
    matrix_float4x4 model_matrix;
} MetalUniformModelM;

typedef struct
{
    matrix_float4x4 view_matrix;
} MetalUniformViewM;

typedef struct
{
    matrix_float4x4 projection_matrix;
} MetalUniformProjectionM;

typedef struct
{
    float u_time;
} MetalUniformTime;

typedef struct
{
    vector_float3 direction;
} MetalLightDirection;

#endif /* MetalTypes_h */
