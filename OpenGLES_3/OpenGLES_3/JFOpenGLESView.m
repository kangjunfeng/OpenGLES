//
//  JFOpenGLESView.m
//  OpenGLES_3
//
//  Created by admin on 14/04/2017.
//  Copyright © 2017 admin. All rights reserved.
//

#import "JFOpenGLESView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@implementation JFOpenGLESView

-(id)init
{
    self =[super init];
    if (self) {
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame: frame];
    if (self) {

    }
    return self;
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
        渲染的内存区域并无特别的要求，那么可以传递NULL给参数date。
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
                GL_UNSIGNED_BYTE,GL_UNSIGNED_SHORT_5_6_5,
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

-(GLuint)compileShaderWithShaderName:(NSString*)shaderName shaderType:(GLuint)shaderType
{
    //获取着色器文件
    NSString *shaderPath =[[NSBundle mainBundle]pathForResource:shaderName ofType:@"glsl"];
    NSError *error;
    NSString *strShder  =[NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
        exit(1);
    }
    
    //获取shader 和source
    const char* chShader = [strShder UTF8String];
    int shaderLength     = (int)[strShder length];
    GLuint shaderHandler =glCreateShader(shaderType);
    glShaderSource(shaderHandler, 1, &chShader, &shaderLength);

    //编译shader
    glCompileShader(shaderHandler);
    
    //查询shader对象
    GLint compileSuccess;
    glGetShaderiv(shaderHandler, GL_COMPILE_STATUS, &compileSuccess);
    if(compileSuccess ==GL_FALSE){
        GLchar message[256];
        glGetShaderSource(shaderHandler, sizeof(message), 0,&message[0]);
        NSLog(@"%@",[NSString stringWithUTF8String:message]);
        exit(1);
    }
    return shaderHandler;
    
}

@end
