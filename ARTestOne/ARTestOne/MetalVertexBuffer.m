//
//  VertexBuffer.m
//  WaterAnimation
//
//  Created by begoss on 2017/11/24.
//  Copyright © 2017年 begoss. All rights reserved.
//

#import "MetalVertexBuffer.h"

@implementation MetalVertexBuffer

- (void)setSize:(NSInteger)size {
    mVertexCount = size;
    mVertexes = malloc(sizeof(MetalVertex)*size);
}

- (void)setPositionAtIndex:(NSInteger)index x:(float)x y:(float)y z:(float)z {
    mVertexes[index].Position[0] = x;
    mVertexes[index].Position[1] = y;
    mVertexes[index].Position[2] = z;
    mVertexes[index].Position[3] = 1.0f;
}

- (void)setColorAtIndex:(NSInteger)index r:(float)r g:(float)g b:(float)b a:(float)a {
    mVertexes[index].Color[0] = r;
    mVertexes[index].Color[1] = g;
    mVertexes[index].Color[2] = b;
    mVertexes[index].Color[3] = a;
}

- (void)setNormalAtIndex:(NSInteger)index x:(float)x y:(float)y z:(float)z {
    mVertexes[index].Normal[0] = x;
    mVertexes[index].Normal[1] = y;
    mVertexes[index].Normal[2] = z;
}

- (void)setTexcoordAtIndex:(NSInteger)index s:(float)s t:(float)t {
    mVertexes[index].Texcoord[0] = s;
    mVertexes[index].Texcoord[1] = t;
}

- (void)dealloc {
    free(mVertexes);
}

@end
