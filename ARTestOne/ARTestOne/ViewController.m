//
//  ViewController.m
//  ARTestOne
//
//  Created by begoss on 2018/6/19.
//  Copyright © 2018年 begoss. All rights reserved.
//

#import "ViewController.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "MetalTypes.h"
#import "MetalVertexBuffer.h"
#import "AAPLMathUtilities.h"

@interface ViewController () <ARSCNViewDelegate, ARSessionDelegate>

@property (nonatomic, strong) ARSCNView *arSCNView;
@property (nonatomic, strong) ARSession *arSession;
@property (nonatomic, strong) ARWorldTrackingConfiguration *arSessionConfiguration;

@property (nonatomic, assign) BOOL hasSetupMetal;

@property (nonatomic, strong) CAMetalLayer *metalLayer;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

@property (nonatomic, strong) id<MTLRenderPipelineState> colorPipelineState;
@property (nonatomic, strong) id<MTLSamplerState> nearestSamplerState;
@property (nonatomic, strong) id<MTLDepthStencilState> depthStencilState;
@property (nonatomic, strong) id<MTLDepthStencilState> noDepthStencilState;
@property (nonatomic, assign) MetalUniformViewM uniform_v;
@property (nonatomic, assign) MetalUniformProjectionM uniform_p;
@property (nonatomic, strong) id<MTLBuffer> uniformVBuffer;
@property (nonatomic, strong) id<MTLBuffer> uniformPBuffer;

@property (nonatomic, strong) MetalVertexBuffer *testVertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> testMTLBuffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化arSCNView.scene
    SCNScene *scene = [SCNScene scene];
    self.arSCNView.scene = scene;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //添加arSCNView，并启动arSession
    [self.view addSubview:self.arSCNView];
    [self.arSession runWithConfiguration:self.arSessionConfiguration];
    
    //添加一个SCNText
    SCNNode *myTextNode = [SCNNode node];
    SCNText *myText = [SCNText textWithString:@"SCNText" extrusionDepth:0.75];
    [myTextNode setPosition:SCNVector3Make(0, 0, -0.3)];
    [myTextNode setGeometry:myText];
    myText.font = [UIFont fontWithName:@"STHeitiJ-Medium" size:10];
    myTextNode.scale = SCNVector3Make(0.004, 0.004, 0.004);
    myText.firstMaterial.diffuse.contents = [UIColor orangeColor];
    [self.arSCNView.scene.rootNode addChildNode:myTextNode];
    
}

#pragma mark - ARSCNViewDelegate

/*
 // Override to create and configure nodes for anchors added to the view's session.
 - (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
 SCNNode *node = [SCNNode new];
 
 // Add geometry to the node...
 
 return node;
 }
 */

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

#pragma mark - ARSessionDelegate

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    
}

#pragma mark - SCNSceneRendererDelegate

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    if (!self.hasSetupMetal) {
        //初始化Metal相关的东西
        self.hasSetupMetal = YES;
        [self setupMetal];
    }else {
        //更新view_matrix
        _uniform_v.view_matrix = matrix_invert(SCNMatrix4ToMat4(self.arSCNView.pointOfView.worldTransform));
        void *bufferPointerV = [self.uniformVBuffer contents];
        memcpy(bufferPointerV, &_uniform_v, sizeof(MetalUniformViewM));
        
        //更新projection_matrix
        _uniform_p.projection_matrix = SCNMatrix4ToMat4(self.arSCNView.pointOfView.camera.projectionTransform);
        void *bufferPointerP = [self.uniformPBuffer contents];
        memcpy(bufferPointerP, &_uniform_p, sizeof(MetalUniformProjectionM));
        
        //使用arSCNView.currentRenderCommandEncoder进行Metal绘制
        id<MTLRenderCommandEncoder> renderPass = self.arSCNView.currentRenderCommandEncoder;
        
        [renderPass setDepthStencilState:self.depthStencilState];
        [renderPass setRenderPipelineState:self.colorPipelineState];
        [renderPass setVertexBuffer:self.testMTLBuffer offset:0 atIndex:0];
        [renderPass setVertexBuffer:self.uniformVBuffer offset:0 atIndex:1];
        [renderPass setVertexBuffer:self.uniformPBuffer offset:0 atIndex:2];
        [renderPass setFragmentSamplerState:self.nearestSamplerState atIndex:0];
        [renderPass drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:_testVertexBuffer->mVertexCount];
    }
}

#pragma mark - Init ARKit

- (ARWorldTrackingConfiguration *)arSessionConfiguration
{
    if (_arSessionConfiguration != nil) {
        return _arSessionConfiguration;
    }
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    _arSessionConfiguration = configuration;
    _arSessionConfiguration.lightEstimationEnabled = YES;
    
    return _arSessionConfiguration;
    
}

- (ARSession *)arSession
{
    if(_arSession != nil)
    {
        return _arSession;
    }
    _arSession = [[ARSession alloc] init];
    
    return _arSession;
}

- (ARSCNView *)arSCNView
{
    if (_arSCNView != nil) {
        return _arSCNView;
    }
    _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    _arSCNView.session = self.arSession;
    _arSCNView.automaticallyUpdatesLighting = YES;
    _arSCNView.delegate = self;
    _arSCNView.session.delegate = self;
    
    return _arSCNView;
}

#pragma mark - Init Metal

- (void)setupMetal {
    _metalLayer = (CAMetalLayer *)self.arSCNView.layer;
    _device = self.arSCNView.device;
    _commandQueue = self.arSCNView.commandQueue;
    
    _uniform_v.view_matrix = matrix_identity_float4x4;
    _uniform_p.projection_matrix = SCNMatrix4ToMat4(self.arSCNView.pointOfView.camera.projectionTransform);;
    
    self.uniformVBuffer = [_device newBufferWithLength:sizeof(MetalUniformViewM) options:MTLResourceOptionCPUCacheModeDefault];
    void *bufferPointerV = [self.uniformVBuffer contents];
    memcpy(bufferPointerV, &_uniform_v, sizeof(MetalUniformViewM));
    
    self.uniformPBuffer = [_device newBufferWithLength:sizeof(MetalUniformProjectionM) options:MTLResourceOptionCPUCacheModeDefault];
    void *bufferPointerP = [self.uniformPBuffer contents];
    memcpy(bufferPointerP, &_uniform_p, sizeof(MetalUniformProjectionM));
    
    [self makePipeline];
    [self makeSamplerState];
    [self setContent];
}

//初始化Pipeline
- (void)makePipeline {
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    self.depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    
    MTLDepthStencilDescriptor *noDepthStencilDescriptor = [MTLDepthStencilDescriptor new];
    noDepthStencilDescriptor.depthWriteEnabled = NO;
    self.noDepthStencilState = [self.device newDepthStencilStateWithDescriptor:noDepthStencilDescriptor];
    
    MTLRenderPipelineDescriptor *colorPipelineDescriptor = [MTLRenderPipelineDescriptor new];
    colorPipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertex_function_color"];
    colorPipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragment_function_color"];
    colorPipelineDescriptor.colorAttachments[0].pixelFormat = self.metalLayer.pixelFormat;
    colorPipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    colorPipelineDescriptor.colorAttachments[0].blendingEnabled = YES;
    colorPipelineDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
    colorPipelineDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
    colorPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    colorPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
    colorPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    colorPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    
    NSError *colorError = nil;
    self.colorPipelineState = [self.device newRenderPipelineStateWithDescriptor:colorPipelineDescriptor
                                                                          error:&colorError];
    
    if (!self.colorPipelineState)
    {
        NSLog(@"Error occurred when creating render pipeline state: %@", colorError);
    }
    
}

//初始化SamplerState
- (void)makeSamplerState {
    MTLSamplerDescriptor *nearestSamplerState = [MTLSamplerDescriptor new];
    nearestSamplerState.sAddressMode = MTLSamplerAddressModeRepeat;
    nearestSamplerState.tAddressMode = MTLSamplerAddressModeRepeat;
    nearestSamplerState.minFilter = MTLSamplerMinMagFilterLinear;
    nearestSamplerState.magFilter = MTLSamplerMinMagFilterNearest;
    nearestSamplerState.mipFilter = MTLSamplerMipFilterLinear;
    _nearestSamplerState = [_device newSamplerStateWithDescriptor:nearestSamplerState];
}

//创建一个正方形
- (void)setContent {
    self.testVertexBuffer = [MetalVertexBuffer new];
    [self.testVertexBuffer setSize:4];
    [self.testVertexBuffer setPositionAtIndex:0 x:-0.2 y:0.2 z:-0.5];
    [self.testVertexBuffer setColorAtIndex:0 r:0.1 g:0.4 b:0.6 a:1.0];
    [self.testVertexBuffer setTexcoordAtIndex:0 s:0 t:0];
    [self.testVertexBuffer setPositionAtIndex:1 x:-0.2 y:-0.2 z:-0.5];
    [self.testVertexBuffer setColorAtIndex:1 r:0.6 g:0.4 b:0.1 a:1.0];
    [self.testVertexBuffer setTexcoordAtIndex:1 s:0 t:1];
    [self.testVertexBuffer setPositionAtIndex:2 x:0.2 y:0.2 z:-0.5];
    [self.testVertexBuffer setColorAtIndex:2 r:0.4 g:0.6 b:0.1 a:1.0];
    [self.testVertexBuffer setTexcoordAtIndex:2 s:1 t:0];
    [self.testVertexBuffer setPositionAtIndex:3 x:0.2 y:-0.2 z:-0.5];
    [self.testVertexBuffer setColorAtIndex:3 r:0.6 g:0.4 b:0.1 a:1.0];
    [self.testVertexBuffer setTexcoordAtIndex:3 s:1 t:1];
    self.testMTLBuffer = [_device newBufferWithBytes:_testVertexBuffer->mVertexes
                                              length:sizeof(MetalVertex)*_testVertexBuffer->mVertexCount
                                             options:MTLResourceOptionCPUCacheModeDefault];
}

@end
