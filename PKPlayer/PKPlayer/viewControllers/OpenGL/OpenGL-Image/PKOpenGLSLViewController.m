//
//  PKOpenGLSLViewController.m
//  PKPlayer
//
//  Created by 郭建华 on 2021/5/28.
//  Copyright © 2021 PeterKwok. All rights reserved.
//

#import "PKOpenGLSLViewController.h"
#import <GLKit/GLKit.h>

/**
 定义顶点类型
 */
typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;

@interface PKOpenGLSLViewController ()

@property (nonatomic, assign) SenceVertex *vertices;
@property (nonatomic, strong) EAGLContext *context;

@end

@implementation PKOpenGLSLViewController

- (void)dealloc {
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self commonInit];
}

- (void)commonInit {
    // 创建上下文，使用 2.0 版本
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    // 创建顶点数组
    self.vertices = malloc(sizeof(SenceVertex) * 4); // 4 个顶点
    
    self.vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}}; // 左上角
    self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}}; // 左下角
    self.vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}}; // 右上角
    self.vertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}}; // 右下角
    
    // 创建一个展示纹理的层
    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width);
    layer.contentsScale = [[UIScreen mainScreen] scale];  // 设置缩放比例，不设置的话，纹理会失真
    
    [self.view.layer addSublayer:layer];
    
    //绑定纹理输出层
    [self bindRenderLayer:layer];
    
    // 通过 GLKTextureLoader 来加载纹理，并存放在 GLKBaseEffect 中
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"0.jpg"];
    // 这里如果用 imageNamed 来读取图片，在反复加载纹理的时候，会出现倒置的错误
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    GLuint textureID = [self createTextureWithImage:image];
    
    //设置视口尺寸
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    
    //编译链接shader
    GLuint program = [self programWithShaderName:@"PKGLSL"];
    glUseProgram(program);
    
    //获取 shader 中的参数， 然后传递进去
    GLuint positionSlot = glGetAttribLocation(program, "Position");
    GLuint textureSlot = glGetUniformLocation(program, "Texture");
    GLuint textureCoordsSlot = glGetAttribLocation(program, "TextureCoords");
    
    //将纹理ID传给着色器程序
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glUniform1f(textureSlot, 0);    //将 textureSlot 赋值为 0，而 0 与 GL_TEXTURE0 对应，这里如果写 1，上面也要改成 GL_TEXTURE1
    
    // 创建顶点缓存
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    //设置顶点数据
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    //设置纹理数据
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    //开始绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //将绑定的渲染缓存呈现到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    //删除顶点缓存
    glDeleteBuffers(1, &vertexBuffer);
    vertexBuffer = 0;
}

#pragma mark - private

- (GLuint)createTextureWithImage:(UIImage *)image {
    //UIImage 转换为 CGImageRef
    CGImageRef cgImageRef = [image CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    //绘制图片
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    //生成纹理
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    // 将图片数据写入纹理缓存
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    // 设置如何把纹素映射成像素
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    //解绑
    glBindTexture(GL_TEXTURE_2D, 0);
    
    //释放内存
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}

- (void)bindRenderLayer:(CALayer <EAGLDrawable> *)layer {
    GLuint renderBuffer;    //渲染缓存
    GLuint frameBuffer;     //帧缓存
    
    //绑定渲染缓存要输出的layer
    glGenBuffers(1, &renderBuffer);
    glBindBuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    //将渲染缓存绑定在帧缓存
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
}

// 将一个顶点找着色器和一个片段着色器挂载到一个着色器程序上，并返回程序的id
- (GLuint)programWithShaderName:(NSString *)shaderName {
    //编译两个着色器
    GLuint vertexShader = [self compileShaderWithName:shaderName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:shaderName type:GL_FRAGMENT_SHADER];
    
    // 挂载shader到program上
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    //链接program
    glLinkProgram(program);
    
    //检查链接是否成功
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSAssert(NO, @"读取shader失败");
        exit(1);
    }
    return program;
}

- (GLuint)compileShaderWithName:(NSString *)name type:(GLenum)shaderType {
    //查找shader文件
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:GL_VERTEX_SHADER ? @"vsh" :@"fsh"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSAssert(NO, @"读取shader失败");
        exit(1);
    }
    
    //创建一个shader对象
    GLuint shader = glCreateShader(shaderType);
    
    //获取shader的内容
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int sharderStringLength = (int)[shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &sharderStringLength);
    
    //编译shader
    glCompileShader(shader);
    
    //查询shader是否编译成功
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"shader编译失败：%@", messageString);
        exit(1);
    }
    return shader;
}

//获取渲染缓存宽度
- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}

//获取渲染缓存高度
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}

@end
