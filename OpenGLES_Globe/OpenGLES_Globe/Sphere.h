//
//  Sphere.h
//  OpenGLES_Globe
//
//  Created by kk on 2017/5/18.
//  Copyright © 2017年 kk. All rights reserved.
//

#ifndef Sphere_h
#define Sphere_h

#include <stdio.h>
#include <string.h>


int createSphere(int numSlices, float radius, float **vertices, float **texCoords, uint16_t **indices, int *numVerticesOut);

#endif /* Sphere_h */
