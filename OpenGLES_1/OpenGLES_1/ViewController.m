//
//  ViewController.m
//  OpenGLES_1
//
//  Created by admin on 12/04/2017.
//  Copyright © 2017 admin. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "JFCAEGLayer.h"
@interface ViewController ()
{
    EAGLContext *_eaglContext;
    JFCAEGLayer *_layer;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initGL];
    [self bindBuffer];
    [self render];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


-(void)initGL
{
    //init context
    _eaglContext =[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_eaglContext];
    
    //init layer
    _layer =[[JFCAEGLayer alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    [self.view.layer addSublayer:_layer];
}

-(void)bindBuffer
{
#pragma mark -- renderBuffer
    /**
     *  分配n个未使用的渲染缓存对象名称，并且将他们保存到ids中。对象必须关联到glBindRenderbuffer()之后才能使用。
     */
    glGenRenderbuffers(1,&_colorRenderBuffer);
    /**
     *  创建并绑定一个名称为renderbuffer的渲染缓存。target必须是GL_RENDERBUFFER,而renderbuffer可以是0，即除
     *  当前的绑定，也可以是glGenRenderbuffers()所生成的一个名称；否则系统将产生一个GL_INVALID_OPERATION错
     *  误。
     */
    glBindRenderbuffer(GL_RENDERBUFFER,_colorRenderBuffer);
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
    
#pragma mark -- frameBuffer
    /**
     *  glGenFramebuffers()生成的帧缓存对象。
     *  设置一个可读或者可写的帧缓存。如果target为GL_DRAW_FRAMEBUFFER,那么framebuffer设置的是绘制时的目标帧缓
     *  存。类似的如果target设置为GL_READ_FRAMEBUFFER,那么framebuffer就是读取操作的数据源。如果target设置为
     *  GL_FRAMEBUFFER,那么framebuffer所设置的帧缓存是可读也可写的。如果framebuffer设置为0的话，表示将目标绑
     *  定到默认的窗口系统帧缓存，或者设置为一个如果framebuffer不是0也不是一个可用的帧缓存对象（可用的对象是通过
     *  glGenFramebuffers()生成的，并且没有被glDeleteFramebuffers()所释放，那么将产生一个
     *  GL_INVALID_OPERATION错误。
     */
    glGenFramebuffers(1,&_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER,_frameBuffer);
    /**
     *  绑定绘制缓冲区到帧缓冲区
     *  void glFramebufferRenderbuffer(GLenum target,GLenum attachment,GLenum renderbuffertarget,GLuint renderbuffer)
     *  将渲染缓存renderbuffer关联到当前绑定的帧缓存对象的附件attachment上。target必须是
     *  GL_READ_FRAMEBUFFER,GL_DRAW_FRAMEBUFFER或者GL_FRAMEBUFFER（等价于GL_DRAW_FRAMEBUFFER)
     *  attachment必须是GL_COLOR_ATTACHMENTi(iOS:
     *  GL_COLOR_ATTACHMENT0),GL_DEPTH_ATTACHMENT,GL_STENCIL_ATTACHMENT或者
     *  GL_DEPTH_STENCIL_ATTACHMENT;renderbuffertarget必须设置为
     *  GL_RENDERBUFFER,而renderbuffer必须是0（表示将附件所关联的渲染缓存移除）或者是glGenRenderbuffers()
     *  生成的渲染缓存名称，否则会产生一个GL_INVALID_OPERATION错误。
     */
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0
                              , GL_RENDERBUFFER, _frameBuffer);
}

-(void)render
{
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    //GL_COLOR_BUFFER_BIT:   当前可写的颜色缓冲
    //GL_DEPTH_BUFFER_BIT:   深度缓冲
    //GL_ACCUM_BUFFER_BIT:   累积缓冲
    //GL_STENCIL_BUFFER_BIT: 模板缓冲
    glClear(GL_COLOR_BUFFER_BIT);
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
