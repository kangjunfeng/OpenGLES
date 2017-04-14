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
#import "JFCAEGLayer.h"
@interface JFOpenGLESView(){
    EAGLContext *_eaglContext;
    JFCAEGLayer *_glLayer;
    GLuint colorRenderBuffer;
    GLuint frameBuffer;
    GLuint glprogram;
    GLuint glposition;
}

@end

@implementation JFOpenGLESView

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
        [self initGLWithFrame:frame];
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

    _glLayer=[[JFCAEGLayer alloc]initWithFrame:frame];
    [self.layer addSublayer:_glLayer];
}

-(void)initBuffer
{
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_glLayer];
    
    glGenFramebuffers(1,&frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER,frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, frameBuffer);
}

-(void)deleteBuffer
{
    if (colorRenderBuffer) {
        glDeleteRenderbuffers(1, &colorRenderBuffer);
        colorRenderBuffer=0;
    }
    
    if (frameBuffer) {
        glDeleteFramebuffers(1, &frameBuffer);
        frameBuffer= 0;
    }
}


-(void)initProgram
{
    //shader
    GLuint vertext  =[self compileWithShaderName:@"Vertex" shaderType:GL_VERTEX_SHADER];
    GLuint fragment =[self compileWithShaderName:@"fragment" shaderType:GL_FRAGMENT_SHADER];
    
    glprogram =glCreateProgram();
    glAttachShader(glprogram, vertext);
    glAttachShader(glprogram, fragment);

    //操作产生最后的可执行程序，它包含最后可以在硬件上执行的硬件指令。
    glLinkProgram(glprogram);
    
    GLint linkSuccess = GL_TRUE;
    glGetProgramiv(glprogram, GL_LINK_STATUS,&linkSuccess);
    if (linkSuccess ==GL_FALSE) {
        GLchar glMessage[256];
        glGetProgramInfoLog(glprogram, sizeof(glMessage), 0, &glMessage[0]);
        NSString *messageString = [NSString stringWithUTF8String:glMessage];
        NSLog(@"program error %@", messageString);
        exit(1);
    }
    
    //绑定着色器参数
    glUseProgram(glprogram);
    glposition = glGetAttribLocation(glprogram,"Position");
}

-(GLuint)compileWithShaderName:(NSString*)name shaderType:(GLenum)shaderType
{
    //获取着色器文件
    NSString *shaderPath =[[NSBundle mainBundle]pathForResource:name ofType:@"glsl"];
    NSError *error;
    NSString *strShader =[NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"strShader %@",strShader);
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

-(void)draw{
    
    //设置绘制区域
    glViewport(0,0,self.frame.size.width,self.frame.size.height);
    
    const GLfloat vertices[]={
        -1,-1, 0,        //左下
         1,-1, 0,        //右下
        -1, 1, 0,        //左上
         1, 1, 0         //右上
    };

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
    //传入顶点参数
    glVertexAttribPointer(glposition, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(glposition);
    
    //绘制多边形
    glDrawArrays(GL_TRIANGLE_STRIP, 1, 4);
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}


@end
