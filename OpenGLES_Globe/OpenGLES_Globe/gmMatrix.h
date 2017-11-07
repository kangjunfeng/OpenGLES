//
//  gmMatrix.h
//  MyOpenGLES
//
//  Created by Archer_LJ on 14-7-10.
//  Copyright (c) 2014年 Archer_LJ. All rights reserved.
//

#ifndef MyOpenGLES_gmMatrix_h
#define MyOpenGLES_gmMatrix_h

#include "gmVector.h"

#define M00 0
#define M01 1
#define M02 2
#define M03 3
#define M10 4
#define M11 5
#define M12 6
#define M13 7
#define M20 8
#define M21 9
#define M22 10
#define M23 11
#define M30 12
#define M31 13
#define M32 14
#define M33 15

typedef struct _gmMatrix4
{
    float m[16];
}
gmMatrix4;

void InitgmMatrix4(gmMatrix4* mat);

void gmMatrixMultiply(gmMatrix4* out, gmMatrix4* m1, gmMatrix4* m2);

void gmMatrixTranslate(gmMatrix4* out, float x, float y, float z);
void gmMatrixScale(gmMatrix4* out, float x, float y, float z);
void gmMatrixRotateX(gmMatrix4* out, float x);
void gmMatrixRotateY(gmMatrix4* out, float y);
void gmMatrixRotateZ(gmMatrix4* out, float z);

void gmMatrixLookAtLH(gmMatrix4* out, gmVector3* eye, gmVector3* at, gmVector3* up);
void gmMatrixPerspectiveFovLH(gmMatrix4* out, float foy, float aspect, float near, float far);

#endif
