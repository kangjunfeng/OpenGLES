//
//  Sphere1.c
//  OpenGLES_Globe
//
//  Created by admin on 22/05/2017.
//  Copyright © 2017 admin. All rights reserved.
//

#include "Sphere1.h"
#define PI 3.1415926
#define PI2 6.2831853

int initSphere(int m,int n,float *verts ,float *texCoords)
{
    int vertNum=m*n*4;//顶点总数

    if (verts == NULL) {
        
        verts = malloc(sizeof(float) * 3 * vertNum);
    }
    
    if (texCoords == NULL) {
        
        texCoords = malloc(sizeof(float) * 2 * vertNum);
    }

    
    float stepAngZ=PI/m;//纵向角度每次增加的值
    float stepAngXY=PI2/n;//横向角度每次增加的值
    float angZ=0.0;//初始的纵向角度
    float angXY=0.0;//初始的横向角度
    
    int index=0;
    int indexTex=0;
    for(int i=0;i<m;i++) {
        for(int j=0;j<n;j++) {
            //构造一个顶点
            float x1=sin(angZ)*cos(angXY);
            float y1=sin(angZ)*sin(angXY);
            float z1=cos(angZ);
            verts[index]= x1; index++;
            verts[index]= y1; index++;
            verts[index]= z1; index++;
            float v1=angZ/PI;
            float u1=angXY/PI2;
            texCoords[indexTex]=u1; indexTex++;
            texCoords[indexTex]=v1; indexTex++;
            
            float x2=sin(angZ+stepAngZ)*cos(angXY);
            float y2=sin(angZ+stepAngZ)*sin(angXY);
            float z2=cos(angZ+stepAngZ);
            verts[index]=x2; index++;
            verts[index]=y2; index++;
            verts[index]=z2; index++;
            float v2=(angZ+stepAngZ)/PI;
            float u2=angXY/PI2;
            texCoords[indexTex]=u2; indexTex++;
            texCoords[indexTex]=v2; indexTex++;
            
            
            float x3=sin(angZ+stepAngZ)*cos(angXY+stepAngXY);
            float y3=sin(angZ+stepAngZ)*sin(angXY+stepAngXY);
            float z3=cos(angZ+stepAngZ);
            verts[index]=x3; index++;
            verts[index]=y3; index++;
            verts[index]=z3; index++;
            float v3=(angZ+stepAngZ)/PI;
            float u3=(angXY+stepAngXY)/PI2;
            texCoords[indexTex]=u3; indexTex++;
            texCoords[indexTex]=v3; indexTex++;
            
            float x4=sin(angZ)*cos(angXY+stepAngXY);
            float y4=sin(angZ)*sin(angXY+stepAngXY);
            float z4=cos(angZ);
            verts[index]=x4; index++;
            verts[index]=y4; index++;
            verts[index]=z4; index++;
            float v4=angZ/PI;
            float u4=(angXY+stepAngXY)/PI2;
            texCoords[indexTex]=u4; indexTex++;
            texCoords[indexTex]=v4; indexTex++;
            
            angXY+=stepAngXY;
        }
        angXY=0.0;//每次横向到达2PI角度则横向角度归0
        angZ+=stepAngZ;
    }
    
    return vertNum;
}
