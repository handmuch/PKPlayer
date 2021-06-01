//
//  PKMetalImageViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2021/5/19.
//  Copyright © 2021 PeterKwok. All rights reserved.
//

#import "PKMetalImageViewController.h"

#import <MetalKit/MetalKit.h>

typedef struct {
    vector_float4 position;
    vector_float4 texCoords;
} Vertex;

@interface PKMetalImageViewController ()<MTKViewDelegate>

@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) id <MTLRenderPipelineState> pipelineState;    //渲染管线
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id <MTLBuffer> vertixBuffer;
@property (nonatomic, strong) id <MTLTexture> texture;

@end

@implementation PKMetalImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupMTKView];
    [self setupPipeline];
    [self setupVertex];
    [self setupTexture];
}

/// 初始化 MTKView
- (void)setupMTKView {
    self.mtkView = [[MTKView alloc] initWithFrame:CGRectMake(0,
                                                             100,
                                                             [UIApplication sharedApplication].keyWindow.frame.size.width,
                                                             [UIApplication sharedApplication].keyWindow.frame.size.width * 1.47)
                                           device:MTLCreateSystemDefaultDevice()];
    self.mtkView.delegate = self;
    [self.view addSubview:self.mtkView];
}

/// 初始化 渲染管线
- (void)setupPipeline {
    // 获取library
    id <MTLLibrary> libray = [self.mtkView.device newDefaultLibrary];
    id <MTLFunction> vertexFunction = [libray newFunctionWithName:@"vertexShader"];
    id <MTLFunction> fragmentFunction = [libray newFunctionWithName:@"fragmentShader"];
    
    // 渲染管线描述
    MTLRenderPipelineDescriptor *descriptior = [[MTLRenderPipelineDescriptor alloc] init];
    descriptior.vertexFunction = vertexFunction;
    descriptior.fragmentFunction = fragmentFunction;
    descriptior.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    
    // 创建渲染管线
    self.pipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:descriptior
                                                                             error:NULL];
    
    // 创建渲染指令队列
    self.commandQueue = [self.mtkView.device newCommandQueue];
}

/// 创建顶点数据
- (void)setupVertex {
    static const Vertex vertices[] = {
        {{-1.0, -1.0, 0.0, 1.0}, {0.0, 1.0}},
        {{-1.0, 1.0, 0.0, 1.0}, {0.0, 0.0}},
        {{1.0, -1.0, 0.0, 1.0}, {1.0, 1.0}},
        {{1.0, 1.0, 0.0, 1.0}, {1.0, 0.0}}
    };
    self.vertixBuffer = [self.mtkView.device newBufferWithBytes:vertices
                                                         length:sizeof(vertices)
                                                        options:MTLResourceStorageModeShared];
}

/// 初始化纹理
- (void)setupTexture {
    MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:self.mtkView.device];
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"0.jpg"];
    // 这里如果用 imageNamed 来读取图片，在反复加载纹理的时候，会出现倒置的错误
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    NSDictionary *options = @{
        MTKTextureLoaderOptionSRGB : @NO
    };
    self.texture = [textureLoader newTextureWithCGImage:image.CGImage
                                                options:options
                                                  error:NULL];
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView *)view {
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = self.mtkView.currentRenderPassDescriptor;
    if (renderPassDescriptor) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        // -1.0 是 z 轴 near， 1.0 是 z 轴 far
        MTLViewport viewport = (MTLViewport){0.0, 0.0, self.mtkView.drawableSize.width, self.mtkView.drawableSize.height, -1.0, 1.0};
        // 设置视口大小
        [renderEncoder setViewport:viewport];
        // 设置渲染管线
        [renderEncoder setRenderPipelineState:self.pipelineState];
        // 设置顶点缓存
        [renderEncoder setVertexBuffer:self.vertixBuffer offset:0 atIndex:0];
        //设置纹理
        [renderEncoder setFragmentTexture:self.texture atIndex:0];
        //绘制命令
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:self.mtkView.currentDrawable];
    }
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
}

@end
