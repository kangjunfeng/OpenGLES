//
//  JFCAEGLayer.m
//  OpenGLES_1
//
//  Created by admin on 12/04/2017.
//  Copyright © 2017 admin. All rights reserved.

#import "JFCAEGLayer.h"

@implementation JFCAEGLayer

-(id)init
{
    self = [super init];
    if (self) {
        [self initLayer];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.frame =frame;
        [self initLayer];
    }
    return self;
}

-(void)initLayer
{
    self.opaque =YES;
    self.drawableProperties =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
}


@end
