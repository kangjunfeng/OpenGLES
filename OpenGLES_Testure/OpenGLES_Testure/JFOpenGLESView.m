//
//  JFOpenGLESView.m
//  OpenGLES_2
//
//  Created by admin on 12/04/2017.
//  Copyright © 2017 admin. All rights reserved.
//

#import "JFOpenGLESView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

const GLfloat vertices[] = {
    0.5f,  0.5f, 0.0f, 1.0f, 0.0f,   // 右上
    0.5f, -0.5f, 0.0f, 1.0f, 1.0f,   // 右下
    -0.5f, -0.5f, 0.0f, 0.0f, 1.0f,  // 左下
    -0.5f, -0.5f, 0.0f, 0.0f, 1.0f,  // 左下
    -0.5f,  0.5f, 0.0f, 0.0f, 0.0f,  // 左上
    0.5f,  0.5f, 0.0f, 1.0f, 0.0f,   // 右上
};

@interface JFOpenGLESView(){
    EAGLContext *_eaglContext;
    CAEAGLLayer *_glLayer;
   
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    GLuint _glprogram;
    GLuint _glposition;
    GLuint _texcoordID;
}

@end

@implementation JFOpenGLESView

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame =frame;
        [self initGLWithFrame:frame];
        [self setupLayer];
        [self deleteBuffer];
        [self initBuffer];
        [self initProgram];
        [self createVBO];
        [self createTexture];
        [self draw];
    }
    return self;
}

-(void)initGLWithFrame:(CGRect)frame
{
    _eaglContext =[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_eaglContext];
}

- (void)setupLayer
{
    _glLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _glLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _glLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}


-(void)initBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_glLayer];
    
    glGenFramebuffers(1,&_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER,_frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _frameBuffer);
}

-(void)deleteBuffer
{
    if (_colorRenderBuffer) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer=0;
    }
    
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer= 0;
    }
}

-(void)initProgram
{
    //shader
    GLuint vertext  =[self compileWithShaderName:@"Vertex" shaderType:GL_VERTEX_SHADER];
    GLuint fragment =[self compileWithShaderName:@"Fragment" shaderType:GL_FRAGMENT_SHADER];
    
    _glprogram =glCreateProgram();
    glAttachShader(_glprogram, vertext);
    glAttachShader(_glprogram, fragment);

    //操作产生最后的可执行程序，它包含最后可以在硬件上执行的硬件指令。
    glLinkProgram(_glprogram);
    
    GLint linkSuccess = GL_TRUE;
    glGetProgramiv(_glprogram, GL_LINK_STATUS,&linkSuccess);
    if (linkSuccess ==GL_FALSE) {
        GLchar glMessage[256];
        glGetProgramInfoLog(_glprogram, sizeof(glMessage), 0, &glMessage[0]);
        NSString *messageString = [NSString stringWithUTF8String:glMessage];
        NSLog(@"program error %@", messageString);
        exit(1);
    }
    
    //绑定着色器参数
    glUseProgram(_glprogram);
    _glposition = glGetAttribLocation(_glprogram,"Position");
}

-(GLuint)compileWithShaderName:(NSString*)name shaderType:(GLenum)shaderType
{
    //获取着色器文件
    NSString *shaderPath =[[NSBundle mainBundle]pathForResource:name ofType:@"glsl"];
    NSError *error;
    NSString *strShader =[NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];

    if (!strShader) {
        NSLog(@"shader error %@",error.localizedDescription);
        exit(1);
    }
    
    // 2 创建一个代表shader的OpenGL对象, 指定vertex或fragment shader
    GLuint shaderHandler = glCreateShader(shaderType);
    
    // 3 获取shader的source
    const char* shaderString = [strShader UTF8String];
    int shaderStringLength = (int)[strShader length];
    glShaderSource(shaderHandler, 1, &shaderString, &shaderStringLength);
    
    // 4 编译shader
    glCompileShader(shaderHandler);
    
    // 5 查询shader对象的信息
    GLint compileSuccess;
    glGetShaderiv(shaderHandler, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandler, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shaderHandler;
}

-(void)createVBO{
    GLuint vbo;
    /**
     *void glGenBuffers(GLsizei n, GLuint *buffers)
     *     参数 n ： 表示需要创建纹理对象的个数
     *     参数 buffers ：用于存储单一ID或多个ID的GLuint变量或数组的地址。
     */
    glGenBuffers(1, &vbo);
   
    /**
     *void glBindBuffer(GLenum target, GLuint buffer);
     *     指定当前活动缓冲区的对象
     *     参数 target ：告诉VBO该缓存对象将保存顶点数组数据还是索引数组数据：GL_ARRAY_BUFFER或  
                        GL_ELEMENT_ARRAY
     *     参数 buffer ：指定绑定的VBO handle
     */
    glBindBuffer(GL_ARRAY_BUFFER,vbo);
   
    /**
     *void glBufferData(GLenum target, GLsizeiptr size, const GLvoid *data, GLenum usage);
     *     参数 target:可以是GL_ARRAY_BUFFER()（顶点数据）或GL_ELEMENT_ARRAY_BUFFER(索引数据)
     *     参数 size:存储相关数据所需的内存容量
     *     参数 data:用于初始化缓冲区对象，可以是一个指向客户区内存的指针，也可以是NULL
     *     参数 usage:数据在分配之后如何进行读写,如GL_STREAM_READ，GL_STREAM_DRAW，GL_STREAM_COPY，如图
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
    /**
     *void glVertexAttribPointer(GLuint index,GLint size,GLenum type,GLboolean normalized,GLsizei
     *                            stride,const void *ptr)
     *     index: 着色器脚本对应变量ID
     *     size : 此类型数据的个数
     *     type : 此类型的sizeof值
     *     normalized : 是否对非float类型数据转化到float时候进行归一化处理
     *     stride : 此类型数据在数组中的重复间隔宽度，byte类型计数
     *     ptr    : 数据指针， 这个值受到VBO的影响
     */
    glEnableVertexAttribArray(glGetAttribLocation(_glprogram, "position"));
    glVertexAttribPointer(glGetAttribLocation(_glprogram, "position"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    
    glEnableVertexAttribArray(glGetAttribLocation(_glprogram, "texcoord"));
    glVertexAttribPointer(glGetAttribLocation(_glprogram, "texcoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL+sizeof(GL_FLOAT)*3);

}

-(void)createTexture
{
    NSString *path   = [[NSBundle mainBundle]pathForResource:@"3D" ofType:@"png"];
    NSData   *data   = [[NSData alloc]initWithContentsOfFile:path];
    UIImage  *image  = [UIImage imageWithData:data];
    _texcoordID      = [self createTextureWithImage:image];

}


-(GLuint)createTextureWithImage:(UIImage*)image
{
    //获取图片基本参数
    CGImageRef imageRef =[image CGImage];
    GLuint width   = (GLuint)CGImageGetWidth(imageRef);
    GLuint height  = (GLuint)CGImageGetHeight(imageRef);
    CGRect rect    = CGRectMake(0,0,width,height);
    
    //绘制
    CGColorSpaceRef  colorSpace =  CGColorSpaceCreateDeviceRGB();
    void *imageData  =  malloc(width*height*4);
    /**
     *  CGBitmapContextCreate(void * __nullable data,size_t width, size_t height, size_t
     *  bitsPerComponent, size_t bytesPerRow,CGColorSpaceRef cg_nullable space, uint32_t
     *  bitmapInfo)
     *  data:指向绘图操作被渲染的内存区域，这个内存区域大小应该为（bytesPerRow*height）个字节。如果对绘制操作被
     渲染的内存区域并无特别的要求，那么可以传递NULL给参数data。
     *  width:代表被渲染内存区域的宽度。
     *  height:代表被渲染内存区域的高度。
     *  bitsPerComponent:被渲染内存区域中组件在屏幕每个像素点上需要使用的bits位，举例来说，如果使用32-bit像素和
     RGB颜色格式，那么RGBA颜色格式中每个组件在屏幕每个像素点上需要使用的bits位就为32/4=8。
     *  bytesPerRow:代表被渲染内存区域中每行所使用的bytes位数。
     *  colorspace:用于被渲染内存区域的“位图上下文”。
     *  bitmapInfo:指定被渲染内存区域的“视图”是否包含一个alpha（透视）通道以及每个像素相应的位置，除此之外还
     可以指定组件式是浮点值还是整数值。
     */
    CGContextRef  contextRef =  CGBitmapContextCreate(imageData, width,height, 8, width*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    /**
     *  void CGContextTranslateCTM ( CGContextRef c, CGFloat tx, CGFloat ty )：平移坐标系统。
     *  该方法相当于把原来位于 (0, 0) 位置的坐标原点平移到 (tx, ty) 点。在平移后的坐标系统上绘制图形时，所有坐标点的 X 坐标都相当于增加了 tx，所有点的 Y 坐标都相当于增加了 ty。
     */
    CGContextTranslateCTM(contextRef, 0, height);
    /**
     *  void CGContextScaleCTM ( CGContextRef c, CGFloat sx, CGFloat sy )：缩放坐标系统。
     *  该方法控制坐标系统水平方向上缩放 sx，垂直方向上缩放 sy。在缩放后的坐标系统上绘制图形时，所有点的 X 坐标都相当于乘以 sx 因子，所有点的 Y 坐标都相当于乘以 sy 因子。
     */
    
    CGContextScaleCTM(contextRef, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(contextRef, rect);
    CGContextDrawImage(contextRef, rect, imageRef);
    
    GLuint textureID =[self createTexture2DWithImageData:imageData width:width height:height];
//    CGContextRelease(contextRef);
//    free(imageData);
    
    return textureID;
}

-(GLuint)createTexture2DWithImageData:(void*)imgData width:(GLuint)width height:(GLuint)height
{
    //纹理设置
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
   
    //生成纹理
    glEnable(GL_TEXTURE_2D);
    GLuint textureID;
    glGenTextures(1,&textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    /**
     *  void glTexImage2D(GLenum target,GLint level,GLint internalformat,GLsizei width,GLsizei
     height,GLint border,GLenum format,GLenum type,const GLvoid * pixels);
     *  target  指定目标纹理，这个值必须是GL_TEXTURE_2D。
     *  level   执行细节级别。0是最基本的图像级别，你表示第N级贴图细化级别。
     *  internalformat     指定纹理中的颜色组件，这个取值和后面的format取值必须相同。可选的值有
     GL_ALPHA,GL_RGB,GL_RGBA,GL_LUMINANCE,GL_LUMINANCE_ALPHA 等几种。
     *  width   指定纹理图像的宽度，必须是2的n次方。纹理图片至少要支持64个材质元素的宽度
     *  height  指定纹理图像的高度，必须是2的m次方。纹理图片至少要支持64个材质元素的高度
     *  border  指定边框的宽度。必须为0。
     *  format  像素数据的颜色格式，必须和internalformatt取值必须相同。可选的值有
     GL_ALPHA,GL_RGB,GL_RGBA,GL_LUMINANCE,GL_LUMINANCE_ALPHA 等几种。
     *  type    指定像素数据的数据类型。可以使用的值有
     GL_UNSIGNED_BYTE,
     GL_UNSIGNED_SHORT_5_6_5,
     GL_UNSIGNED_SHORT_4_4_4_4,
     GL_UNSIGNED_SHORT_5_5_5_1
     *  pixels  指定内存中指向图像数据的指针
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width,height, 0, GL_RGB, GL_UNSIGNED_BYTE, imgData);
    //绑定纹理位置
    glBindTexture(GL_TEXTURE_2D, 0);
    //释放内存
    
    return textureID;
}

-(void)draw{

    glClearColor(0.0, 1.0,1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glLineWidth(2.0);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 激活纹理
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texcoordID);
    glUniform1i(glGetUniformLocation(_glprogram, "image"), 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    // 索引数组
    //unsigned int indices[] = {0,1,2,3,2,0};
    //glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, indices);
    
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];




}


@end
