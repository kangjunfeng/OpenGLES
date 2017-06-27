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

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "gmMatrix.h"
#import "Sphere.h"
#import "Sphere1.h"
#include <stdlib.h>

#define  PI 3.141592653f
#define Angle_To_Radian(angle) (angle * PI / 180.0)
static float angle ;
static float scaleLocation;

@interface JFOpenGLESView(){
    EAGLContext *_eaglContext;
    CAEAGLLayer *_glLayer;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    GLuint _glProgram;
    
    GLuint _glPosition;
    GLuint _texture;
    GLuint _textureCoords;
    GLuint _textureID;
    GLuint _uMatrix;
    GLuint _eyeMatrix;
    GLuint _projMatrix;
    GLuint _modeMatrix;
    
    
    GLint _viewWidth;
    GLint _viewHeight;
    
    //sphere
    gmMatrix4 _mMatrix4;
    gmMatrix4 model, view, proj,mvp;
    GLfloat   *_vertexData; // 顶点数据
    GLfloat   *_texCoords;  // 纹理坐标
    GLushort  *_indices;    // 顶点索引
    GLint    _numVetex;   // 顶点数量
    GLuint  _texCoordsBuffer;// 纹理坐标内存标识
    GLuint  _numIndices; // 顶点索引的数量
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;

    float scale;
    float rotateY;
    float rotateX;
    float eyeDist;
    
    //sphere1
    GLfloat  _vertices1; // 顶点数据
    GLfloat  _texCoords1;  // 纹理坐标
    GLint    _numVetex1;   // 顶点数量
    
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
        [self initImageTexture];
        [self prepare];
        [self initGesture];
        
        // Set up Display Link
        CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(CADisplayLinkRender:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    }
    return self;
}

/**
 * 创建渲染对象
 */
-(void)initGLWithFrame:(CGRect)frame
{
    _eaglContext =[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_eaglContext];
}

/**
 * 创建渲染视图
 */
- (void)setupLayer
{
    _glLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _glLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _glLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

/**
 * 创建渲染缓存
 */
-(void)initBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    
    glGenFramebuffers(1,&_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER,_frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _frameBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_viewWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_viewHeight);
    
}

/**
 * 删除渲染缓存
 */
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

/**
 * 创建渲染片元及着色器
 */
-(void)initProgram
{
    //shader
    GLuint vertext  =[self compileWithShaderName:@"Vertex" shaderType:GL_VERTEX_SHADER];
    GLuint fragment =[self compileWithShaderName:@"Fragment" shaderType:GL_FRAGMENT_SHADER];
    
    _glProgram =glCreateProgram();
    glAttachShader(_glProgram, vertext);
    glAttachShader(_glProgram, fragment);

    //操作产生最后的可执行程序，它包含最后可以在硬件上执行的硬件指令。
    glLinkProgram(_glProgram);
    
    GLint linkSuccess = GL_TRUE;
    glGetProgramiv(_glProgram, GL_LINK_STATUS,&linkSuccess);
    if (linkSuccess ==GL_FALSE) {
        GLchar glMessage[256];
        glGetProgramInfoLog(_glProgram, sizeof(glMessage), 0, &glMessage[0]);
        NSString *messageString = [NSString stringWithUTF8String:glMessage];
        NSLog(@"program error %@", messageString);
        exit(1);
    }
    
    //绑定着色器参数
    glUseProgram(_glProgram);
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

/**
 * 创建图片纹理
 */
-(void)initImageTexture
{
    //获取图片
    NSString *imgPath =[[NSBundle mainBundle]pathForResource:@"balitieta" ofType:@"jpg"];
    NSData   *data    =[[NSData alloc]initWithContentsOfFile:imgPath];
    UIImage  *image   =[UIImage imageWithData:data];
    _textureID =[self createTextureWithImage:image];
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
    CGContextRef contextRef = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
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
    
    //生成纹理
    glEnable(GL_TEXTURE_2D);
    GLuint textureID;
    glGenTextures(1,&textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    //纹理设置
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
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
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    //绑定纹理位置
    glBindTexture(GL_TEXTURE_2D, 0);
    //释放内存
    CGContextRelease(contextRef);
    free(imageData);
    
    return textureID;
}


- (GLuint)setupTexture:(UIImage *)image {
    CGImageRef cgImageRef = [image CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    glEnable(GL_TEXTURE_2D);
    
    /**
     *  GL_TEXTURE_2D表示操作2D纹理
     *  创建纹理对象，
     *  绑定纹理对象，
     */
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    /**
     *  纹理过滤函数
     *  图象从纹理图象空间映射到帧缓冲图象空间(映射需要重新构造纹理图像,这样就会造成应用到多边形上的图像失真),
     *  这时就可用glTexParmeteri()函数来确定如何把纹理象素映射成像素.
     *  如何把图像从纹理图像空间映射到帧缓冲图像空间（即如何把纹理像素映射成像素）
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // S方向上的贴图模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // T方向上的贴图模式
    // 线性过滤：使用距离当前渲染像素中心最近的4个纹理像素加权平均值
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    /**
     *  将图像数据传递给到GL_TEXTURE_2D中, 因其于textureID纹理对象已经绑定，所以即传递给了textureID纹理对象中。
     *  glTexImage2d会将图像数据从CPU内存通过PCIE上传到GPU内存。
     *  不使用PBO时它是一个阻塞CPU的函数，数据量大会卡。
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    // 结束后要做清理
    glBindTexture(GL_TEXTURE_2D, 0); //解绑
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}


-(void)prepare
{
    scale =0.5f;
    rotateY =0;
    rotateX =0;
    eyeDist =-3.5f;
    angle   =0.0f;
    scaleLocation =1.0f;
    
    InitgmMatrix4(&_mMatrix4);
    InitgmMatrix4(&model);
    
    //坐标、纹理、索引
    _numIndices = createSphere(200, 1.0, &(_vertexData), &(_texCoords), &_indices, &_numVetex);

//    _numVetex1 = initSphere(60,50,&(_vertices1) ,&(_texCoords1));
    
    //参数
    _glPosition = glGetAttribLocation(_glProgram,"Position");
    _texture    = glGetUniformLocation(_glProgram, "Texture");//frag
    _textureCoords = glGetAttribLocation(_glProgram, "TextureCoords");
    _uMatrix       = glGetUniformLocation(_glProgram, "Matrix");
    _projMatrix    = glGetUniformLocation(_glProgram, "projMatrix");
    _eyeMatrix     = glGetUniformLocation(_glProgram, "eyeMatrix");
    _modeMatrix    = glGetUniformLocation(_glProgram, "modeMatrix");
    
}

-(void)initGesture
{
    //捏合
    UIPinchGestureRecognizer *pinchGesture =[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
    
    //拖动
    UIPanGestureRecognizer *panGesture =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:panGesture];
}

#pragma mark -- UIGesture
-(void)pinchGesture:(UIPinchGestureRecognizer*)gesture
{
    
    if (gesture.state==UIGestureRecognizerStateChanged) {
        if (scale *gesture.scale>2.0 || scale *gesture.scale<0.3) {
            return;
        }
        scale *=gesture.scale;
        
//        if (scaleLocation*gesture.scale>scaleLocation) {
//            eyeDist+=0.1f;
//        }else{
//            eyeDist-=0.1f;
//        }
    }else if(gesture.state ==UIGestureRecognizerStateEnded){
        scaleLocation*=gesture.scale;
    }
}

-(void)panGesture:(UIPanGestureRecognizer*)gesture
{
    CGPoint translatedPoint = [gesture translationInView:self];
    
    if (gesture.state ==UIGestureRecognizerStateChanged) {
        if (translatedPoint.x<0) {
            rotateY +=2.0f;
            angle   +=0.1f;
        }else{
            rotateY -=2.0f;
            angle   -=0.1f;
        }
        
//        if (translatedPoint.y<0) {
//            rotateX +=1.0f;
//        }else{
//            rotateX -=1.0f;
//        }
        
    }
}

-(void)CADisplayLinkRender:(CADisplayLink *)displayLink
{
    [self draw];
}


/**
 * 绘制
 */
-(void)draw{
    //清屏
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    glViewport(0,_viewHeight/2-_viewWidth/2, _viewWidth,_viewWidth);
    glViewport(0,0,_viewWidth,_viewHeight);
    
    //激活
    glActiveTexture(GL_TEXTURE5); // 指定纹理单元GL_TEXTURE5
    glBindTexture(GL_TEXTURE_2D, _textureID); // 绑定，即可从_textureID中取出图像数据。
    glUniform1i(_texture, 5); // 与纹理单元的序号对应
    
    //render
    [self renderSphereVertice3];
    
    // 使用完之后解绑GL_TEXTURE_2D
    glBindTexture(GL_TEXTURE_2D, 0);
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
    
}

-(void)renderSphereVertice1
{
    int CAP = 5;//绘制球体时，每次增加的角度
    int numVert = (180/CAP) * (360/CAP) * 6 * 3;
    int numText = (180/CAP) * (360/CAP) * 6 * 2;
    GLfloat  verticals[numVert];
    
    GLfloat  UV_TEX_VERTEX[numText];

    float x = 0;
    float y = 0;
    float z = 0;
    
    float r = 0.5;//球体半径
    int index = 0;
    int index1 = 0;
    double d = CAP * PI / 180;//每次递增的弧度
    for (int i = 0; i < 180; i += CAP) {
        double d1 = i * PI / 180;
        for (int j = 0; j < 360; j += CAP) {
            //获得球体上切分的超小片矩形的顶点坐标（两个三角形组成，所以有六点顶点）
            double d2 = j * PI / 180;
            verticals[index++] = (float) (x + r * sin(d1 + d) * cos(d2 + d));
            verticals[index++] = (float) (y + r * cos(d1 + d));
            verticals[index++] = (float) (z + r * sin(d1 + d) * sin(d2 + d));
            //获得球体上切分的超小片三角形的纹理坐标
            UV_TEX_VERTEX[index1++] = (j + CAP) * 1.0f / 360;
            UV_TEX_VERTEX[index1++] = (i + CAP) * 1.0f / 180;
            
            verticals[index++] = (float) (x + r * sin(d1) * cos(d2));
            verticals[index++] = (float) (y + r * cos(d1));
            verticals[index++] = (float) (z + r * sin(d1) * sin(d2));
            
            UV_TEX_VERTEX[index1++] = j * 1.0f / 360;
            UV_TEX_VERTEX[index1++] = i * 1.0f / 180;
            
            verticals[index++] = (float) (x + r * sin(d1) * cos(d2 + d));
            verticals[index++] = (float) (y + r * cos(d1));
            verticals[index++] = (float) (z + r * sin(d1) * sin(d2 + d));
            
            UV_TEX_VERTEX[index1++] = (j + CAP) * 1.0f / 360;
            UV_TEX_VERTEX[index1++] = i * 1.0f / 180;
            
            verticals[index++] = (float) (x + r * sin(d1 + d) * cos(d2 + d));
            verticals[index++] = (float) (y + r * cos(d1 + d));
            verticals[index++] = (float) (z + r * sin(d1 + d) * sin(d2 + d));
            
            UV_TEX_VERTEX[index1++] = (j + CAP) * 1.0f / 360;
            UV_TEX_VERTEX[index1++] = (i + CAP) * 1.0f / 180;
            
            verticals[index++] = (float) (x + r * sin(d1 + d) * cos(d2));
            verticals[index++] = (float) (y + r * cos(d1 + d));
            verticals[index++] = (float) (z + r * sin(d1 + d) * sin(d2));
            
            UV_TEX_VERTEX[index1++] = j * 1.0f / 360;
            UV_TEX_VERTEX[index1++] = (i + CAP) * 1.0f / 180;
            
            verticals[index++] = (float) (x + r * sin(d1) * cos(d2));
            verticals[index++] = (float) (y + r * cos(d1));
            verticals[index++] = (float) (z + r * sin(d1) * sin(d2));
            
            UV_TEX_VERTEX[index1++] = j * 1.0f / 360;
            UV_TEX_VERTEX[index1++] = i * 1.0f / 180;
        }
    }
    
    gmVector3 eye = {0.0f, 0.0f, eyeDist};
    gmVector3 at  = {0.0f, 0.0f, 0.0f};
    gmVector3 up  = {0.0f, 1.0f, 0.0f};
    
    gmMatrixLookAtLH(&view, &eye, &at, &up);
    
    gmMatrixPerspectiveFovLH(&proj, 1.0f, (float)_viewWidth / (float)_viewHeight, 1.0f, 1000.0f);
    
    gmMatrixMultiply(&mvp, &model, &view);
    gmMatrixMultiply(&mvp, &mvp, &proj);
    
    gmMatrixRotateY(&model, angle);
    glUniformMatrix4fv(_uMatrix, 1, 0, (float*)&mvp);

    
    glVertexAttribPointer(_textureCoords, 2, GL_FLOAT, GL_FALSE, 0, UV_TEX_VERTEX);
    glEnableVertexAttribArray(_textureCoords);
    
    glVertexAttribPointer(_glPosition, 3, GL_FLOAT, GL_FALSE, 0, verticals);
    glEnableVertexAttribArray(_glPosition);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, numVert/3);
    
}


-(void)renderSphereVertice3
{
    //透视投影
    float aspect = fabsf((float)_viewWidth /(float)_viewHeight);
    GLKMatrix4 perspectiveMatrix =GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0f),aspect, 1.0f,100.0f);
    perspectiveMatrix  = GLKMatrix4Scale(perspectiveMatrix, scale, scale, 1.0f);
    perspectiveMatrix  = GLKMatrix4RotateY(perspectiveMatrix, GLKMathDegreesToRadians(rotateY));
    perspectiveMatrix  = GLKMatrix4RotateX(perspectiveMatrix, GLKMathDegreesToRadians(rotateX));
    
//    perspectiveMatrix  = GLKMatrix4Translate(perspectiveMatrix, 0, 0, -0.5f);
//    GLKMatrix4 frustum    = GLKMatrix4MakeFrustum(-1,1,-1,1,1.0f,1000.0f);
//    GLKMatrix4 projMatrix = GLKMatrix4Multiply(perspectiveMatrix, frustum);
    
    //相机视角
    GLKMatrix4 eyeMatrix= GLKMatrix4MakeLookAt(0.0f, 0.0f, -1.0f,
                                               0.0f, 0.0f, 0.0f,
                                               0.0f, 1.0f, 0.0f);
//    GLKMatrix4 modeMatrix = GLKMatrix4MakeTranslation(0.0f, -1.0f, -6.5f);;
   
    GLKMatrix4 MVP = GLKMatrix4Identity;
//    MVP = GLKMatrix4Multiply(MVP, modeMatrix);
    MVP = GLKMatrix4Multiply(MVP, eyeMatrix);
    MVP = GLKMatrix4Multiply(MVP, perspectiveMatrix);
    //矩阵
    glUniformMatrix4fv(_uMatrix, 1, 0, (float*)&MVP);

/*----------------------------------- c --------------------------------*/
//    gmVector3 eye = {0.0f, 0.0f, eyeDist};
//    gmVector3 at  = {0.0f, 0.0f, 0.0f};
//    gmVector3 up  = {0.0f, 1.0f, 0.0f};
//
//    gmMatrixLookAtLH(&view, &eye, &at, &up);
//
//    gmMatrixPerspectiveFovLH(&proj, 1.0f, (float)_viewWidth / (float)_viewHeight, 1.0f, 1000.0f);
//
//    gmMatrixMultiply(&mvp, &model, &view);
//    gmMatrixMultiply(&mvp, &mvp, &proj);
//
//    gmMatrixRotateY(&model, angle);
//    glUniformMatrix4fv(_uMatrix, 1, 0, (float*)&mvp);
    
    // 加载顶点坐标数据
    glGenBuffers(1, &_vertexBuffer); // 申请内存
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer); // 将命名的缓冲对象绑定到指定的类型上去
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*_numVetex*3,_vertexData, GL_STATIC_DRAW);
    
    // 加载顶点索引数据
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _numIndices*sizeof(GLushort), _indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(_glPosition);  // 绑定到位置上
    glVertexAttribPointer(_glPosition, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), NULL);
  
    // 加载纹理坐标
    glGenBuffers(1, &_texCoordsBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _texCoordsBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*_numVetex*2, _texCoords, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(_textureCoords);
    glVertexAttribPointer(_textureCoords, 2, GL_FLOAT, GL_FALSE, 2*sizeof(GLfloat), NULL);
    
    //draw
    glDrawElements(GL_TRIANGLES, (GLsizei)_numIndices,GL_UNSIGNED_SHORT, nil);

    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    glDeleteBuffers(1, &_texCoordsBuffer);
}

@end
