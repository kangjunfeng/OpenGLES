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

const GLfloat triangle[]={
    -0.5f,0.0f,0,
     0.0f,0.5f,0,
     0.5f,0.0f,0
};

const GLfloat rectangle[]={
    -0.5f,-0.5f,0,
    -0.5f, 0.5f,0,
     0.5f, 0.5f,0,
     0.5f,-0.5f,0
};

const GLfloat pentagon[]={
    -0.5f,-0.5f,0,
    -0.5f, 0.0f,0,
     0.0f, 0.5f,0,
     0.5f, 0.0f,0,
     0.5f,-0.5f,0
};

@interface JFOpenGLESView(){
    EAGLContext *_eaglContext;
    CAEAGLLayer *_glLayer;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    GLuint _glProgram;
    GLuint _glPosition;
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
    _glPosition = glGetAttribLocation(_glProgram,"position");
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
        NSLog(@"compile error%@", messageString);
        exit(1);
    }
    return shaderHandler;
}

-(void)draw{
    //清屏
    glClearColor(0.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glLineWidth(1.0);
    
    //设置绘制区域
    glViewport(0,0,self.frame.size.width,self.frame.size.height);

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
    glEnableVertexAttribArray(_glPosition);
    glVertexAttribPointer(_glPosition, 3, GL_FLOAT, GL_FALSE, 0, pentagon);
    
    //triangle->3  rectangle->4  pentagon->5
    glDrawArrays(GL_TRIANGLE_FAN,0,5);
    
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}


@end
