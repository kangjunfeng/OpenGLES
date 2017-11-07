//
//  gmVector.c
//  MyOpenGLES
//
//  Created by Archer_LJ on 14-7-10.
//  Copyright (c) 2014年 Archer_LJ. All rights reserved.
//

#include <stdio.h>
#include <math.h>
#include "gmVector.h"
#include <string.h>
void InitgmVector2(gmVector2* vec)
{
    memset(vec, 0, sizeof(gmVector2));
}

void InitgmVector3(gmVector3* vec)
{
    memset(vec, 0, sizeof(gmVector3));
}

void InitgmVector4(gmVector4* vec)
{
    memset(vec, 0, sizeof(gmVector4));
    vec->w = 1.0f;
}

void gmVec3Normalize(gmVector3* out, gmVector3* in)
{
    float f = in->x * in->x + in->y * in->y + in->z * in->z;
    f = 1.0f / sqrt(f);
    
	out->x = in->x * f;
	out->y = in->y * f;
	out->z = in->z * f;
}

void gmVec3CrossProduct(gmVector3* out, gmVector3* v1, gmVector3* v2)
{
    gmVector3 result;
    
    result.x = v1->y * v2->z - v1->z * v2->y;
    result.y = v1->z * v2->x - v1->x * v2->z;
    result.z = v1->x * v2->y - v1->y * v2->x;
    
	*out = result;
}
