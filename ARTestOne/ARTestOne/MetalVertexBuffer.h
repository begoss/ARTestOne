//
//  VertexBuffer.h
//  WaterAnimation
//
//  Created by begoss on 2017/11/24.
//  Copyright © 2017年 begoss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

typedef struct __attribute((packed))
{
    float Position[4];
    float Color[4];
    float Normal[3];
    float Texcoord[2];
} MetalVertex;

@interface MetalVertexBuffer : NSObject {
    @public
    MetalVertex *mVertexes;
    NSInteger mVertexCount;
}

- (void)setSize:(NSInteger)size;
- (void)setPositionAtIndex:(NSInteger)index x:(float)x y:(float)y z:(float)z;
- (void)setColorAtIndex:(NSInteger)index r:(float)r g:(float)g b:(float)b a:(float)a;
- (void)setNormalAtIndex:(NSInteger)index x:(float)x y:(float)y z:(float)z;
- (void)setTexcoordAtIndex:(NSInteger)index s:(float)s t:(float)t;

@end

