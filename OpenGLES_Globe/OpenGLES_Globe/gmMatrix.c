//
//  gmMatrix.c
//  MyOpenGLES
//
//  Created by Archer_LJ on 14-7-10.
//  Copyright (c) 2014年 Archer_LJ. All rights reserved.
//

#include <stdio.h>
#include <math.h>
#include "gmMatrix.h"
#include <string.h>

void InitgmMatrix4(gmMatrix4* mat)
{
    if (mat == NULL)
    {
        return;
    }
    
    memset(mat, 0, sizeof(gmMatrix4));
    
    mat->m[M00] = 1.0f;
    mat->m[M11] = 1.0f;
    mat->m[M22] = 1.0f;
    mat->m[M33] = 1.0f;
}

void gmMatrixMultiply(gmMatrix4* out, gmMatrix4* m1, gmMatrix4* m2)
{
    if (out == NULL || m1 == NULL || m2 == NULL)
    {
        return;
    }
    
    gmMatrix4 tmpout;
    
    tmpout.m[ 0] = m1->m[ 0]*m2->m[ 0] + m1->m[ 1]*m2->m[ 4] + m1->m[ 2]*m2->m[ 8] + m1->m[ 3]*m2->m[12];
	tmpout.m[ 1] = m1->m[ 0]*m2->m[ 1] + m1->m[ 1]*m2->m[ 5] + m1->m[ 2]*m2->m[ 9] + m1->m[ 3]*m2->m[13];
	tmpout.m[ 2] = m1->m[ 0]*m2->m[ 2] + m1->m[ 1]*m2->m[ 6] + m1->m[ 2]*m2->m[10] + m1->m[ 3]*m2->m[14];
	tmpout.m[ 3] = m1->m[ 0]*m2->m[ 3] + m1->m[ 1]*m2->m[ 7] + m1->m[ 2]*m2->m[11] + m1->m[ 3]*m2->m[15];
    
	tmpout.m[ 4] = m1->m[ 4]*m2->m[ 0] + m1->m[ 5]*m2->m[ 4] + m1->m[ 6]*m2->m[ 8] + m1->m[ 7]*m2->m[12];
	tmpout.m[ 5] = m1->m[ 4]*m2->m[ 1] + m1->m[ 5]*m2->m[ 5] + m1->m[ 6]*m2->m[ 9] + m1->m[ 7]*m2->m[13];
	tmpout.m[ 6] = m1->m[ 4]*m2->m[ 2] + m1->m[ 5]*m2->m[ 6] + m1->m[ 6]*m2->m[10] + m1->m[ 7]*m2->m[14];
	tmpout.m[ 7] = m1->m[ 4]*m2->m[ 3] + m1->m[ 5]*m2->m[ 7] + m1->m[ 6]*m2->m[11] + m1->m[ 7]*m2->m[15];
    
	tmpout.m[ 8] = m1->m[ 8]*m2->m[ 0] + m1->m[ 9]*m2->m[ 4] + m1->m[10]*m2->m[ 8] + m1->m[11]*m2->m[12];
	tmpout.m[ 9] = m1->m[ 8]*m2->m[ 1] + m1->m[ 9]*m2->m[ 5] + m1->m[10]*m2->m[ 9] + m1->m[11]*m2->m[13];
	tmpout.m[10] = m1->m[ 8]*m2->m[ 2] + m1->m[ 9]*m2->m[ 6] + m1->m[10]*m2->m[10] + m1->m[11]*m2->m[14];
	tmpout.m[11] = m1->m[ 8]*m2->m[ 3] + m1->m[ 9]*m2->m[ 7] + m1->m[10]*m2->m[11] + m1->m[11]*m2->m[15];
    
	tmpout.m[12] = m1->m[12]*m2->m[ 0] + m1->m[13]*m2->m[ 4] + m1->m[14]*m2->m[ 8] + m1->m[15]*m2->m[12];
	tmpout.m[13] = m1->m[12]*m2->m[ 1] + m1->m[13]*m2->m[ 5] + m1->m[14]*m2->m[ 9] + m1->m[15]*m2->m[13];
	tmpout.m[14] = m1->m[12]*m2->m[ 2] + m1->m[13]*m2->m[ 6] + m1->m[14]*m2->m[10] + m1->m[15]*m2->m[14];
	tmpout.m[15] = m1->m[12]*m2->m[ 3] + m1->m[13]*m2->m[ 7] + m1->m[14]*m2->m[11] + m1->m[15]*m2->m[15];
    
    *out = tmpout;
}

void gmMatrixTranslate(gmMatrix4* out, float x, float y, float z)
{
    if (out == NULL)
    {
        return;
    }
    
	out->m[ 0]=1.0f;	out->m[ 4]=0.0f;	out->m[ 8]=0.0f;	out->m[12]=x;
	out->m[ 1]=0.0f;	out->m[ 5]=1.0f;	out->m[ 9]=0.0f;	out->m[13]=y;
	out->m[ 2]=0.0f;	out->m[ 6]=0.0f;	out->m[10]=1.0f;	out->m[14]=z;
	out->m[ 3]=0.0f;	out->m[ 7]=0.0f;	out->m[11]=0.0f;	out->m[15]=1.0f;
}

void gmMatrixScale(gmMatrix4* out, float x, float y, float z)
{
    if (out == NULL)
    {
        return;
    }
    
	out->m[ 0]=x;		out->m[ 4]=0.0f;	out->m[ 8]=0.0f;	out->m[12]=0.0f;
	out->m[ 1]=0.0f;	out->m[ 5]=y;		out->m[ 9]=0.0f;	out->m[13]=0.0f;
	out->m[ 2]=0.0f;	out->m[ 6]=0.0f;	out->m[10]=z;		out->m[14]=0.0f;
	out->m[ 3]=0.0f;	out->m[ 7]=0.0f;	out->m[11]=0.0f;	out->m[15]=1.0f;
}

void gmMatrixRotateX(gmMatrix4* out, float x)
{
    if (out == NULL)
    {
        return;
    }
    
	float fcos, fsin;
    
    fcos = cos(x);
    fsin = sin(x);
    
    out->m[ 0]=1.0f;	out->m[ 4]=0.0f;	out->m[ 8]=0.0f;	out->m[12]=0.0f;
	out->m[ 1]=0.0f;	out->m[ 5]=fcos;	out->m[ 9]=fsin;	out->m[13]=0.0f;
	out->m[ 2]=0.0f;	out->m[ 6]=-fsin;	out->m[10]=fcos;	out->m[14]=0.0f;
	out->m[ 3]=0.0f;	out->m[ 7]=0.0f;	out->m[11]=0.0f;	out->m[15]=1.0f;
}

void gmMatrixRotateY(gmMatrix4* out, float y)
{
    if (out == NULL)
    {
        return;
    }
    
	float fcos, fsin;
    
    fcos = cos(y);
    fsin = sin(y);
    
    out->m[ 0]=fcos;		out->m[ 4]=0.0f;	out->m[ 8]=-fsin;		out->m[12]=0.0f;
	out->m[ 1]=0.0f;		out->m[ 5]=1.0f;	out->m[ 9]=0.0f;		out->m[13]=0.0f;
	out->m[ 2]=fsin;		out->m[ 6]=0.0f;	out->m[10]=fcos;		out->m[14]=0.0f;
	out->m[ 3]=0.0f;		out->m[ 7]=0.0f;	out->m[11]=0.0f;		out->m[15]=1.0f;
}

void gmMatrixRotateZ(gmMatrix4* out, float z)
{
    if (out == NULL)
    {
        return;
    }
    
	float fcos, fsin;
    
    fcos = cos(z);
    fsin = sin(z);
    
    out->m[ 0]=fcos;		out->m[ 4]=fsin;	out->m[ 8]=0.0f;	out->m[12]=0.0f;
	out->m[ 1]=-fsin;		out->m[ 5]=fcos;	out->m[ 9]=0.0f;	out->m[13]=0.0f;
	out->m[ 2]=0.0f;		out->m[ 6]=0.0f;	out->m[10]=1.0f;	out->m[14]=0.0f;
	out->m[ 3]=0.0f;		out->m[ 7]=0.0f;	out->m[11]=0.0f;	out->m[15]=1.0f;
}

void gmMatrixLookAtLH(gmMatrix4* out, gmVector3* eye, gmVector3* at, gmVector3* up)
{
	gmVector3 f, s, u;
	gmMatrix4 t;
    
	f.x = eye->x - at->x;
	f.y = eye->y - at->y;
	f.z = eye->z - at->z;
    
	gmVec3Normalize(&f, &f);
	gmVec3CrossProduct(&s, &f, up);
	gmVec3Normalize(&s, &s);
	gmVec3CrossProduct(&u, &s, &f);
	gmVec3Normalize(&u, &u);
    
	out->m[ 0] = s.x;
	out->m[ 1] = u.x;
	out->m[ 2] = -f.x;
	out->m[ 3] = 0;
    
	out->m[ 4] = s.y;
	out->m[ 5] = u.y;
	out->m[ 6] = -f.y;
	out->m[ 7] = 0;
    
	out->m[ 8] = s.z;
	out->m[ 9] = u.z;
	out->m[10] = -f.z;
	out->m[11] = 0;
    
	out->m[12] = 0;
	out->m[13] = 0;
	out->m[14] = 0;
	out->m[15] = 1;
    
	gmMatrixTranslate(&t, -eye->x, -eye->y, -eye->z);
	gmMatrixMultiply(out, &t, out);
}

void gmMatrixPerspectiveFovLH(gmMatrix4* out, float foy, float aspect, float near, float far)
{
	float f, n;
    
	f = 1.0f / (float)tan(foy * 0.5f);
	n = 1.0f / (far - near);
    
	out->m[ 0] = f / aspect;
	out->m[ 1] = 0;
	out->m[ 2] = 0;
	out->m[ 3] = 0;
    
	out->m[ 4] = 0;
	out->m[ 5] = f;
	out->m[ 6] = 0;
	out->m[ 7] = 0;
    
	out->m[ 8] = 0;
	out->m[ 9] = 0;
	out->m[10] = far * n;
	out->m[11] = 1;
    
	out->m[12] = 0;
	out->m[13] = 0;
	out->m[14] = -far * near * n;
	out->m[15] = 0;
}
