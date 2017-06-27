//
//  gmVector.h
//  MyOpenGLES
//
//  Created by Archer_LJ on 14-7-10.
//  Copyright (c) 2014年 Archer_LJ. All rights reserved.
//

#ifndef MyOpenGLES_gmVector_h
#define MyOpenGLES_gmVector_h

typedef struct _gmVector2
{
    float x;
    float y;
}
gmVector2;

typedef struct _gmVector3
{
    float x;
    float y;
    float z;
}
gmVector3;

typedef struct _gmVector4
{
    float x;
    float y;
    float z;
    float w;
}
gmVector4;

void InitgmVector2(gmVector2* vec);
void InitgmVector3(gmVector3* vec);
void InitgmVector4(gmVector4* vec);

void gmVec3Normalize(gmVector3* out, gmVector3* in);
void gmVec3CrossProduct(gmVector3* out, gmVector3* v1, gmVector3* v2);

#endif
