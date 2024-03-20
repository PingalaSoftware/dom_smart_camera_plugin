//
//  DisplayView.m
//  XMUtils
//
//  Created by liuguifang on 05/20/16.
//  Copyright (c) 2016 xiongmaitech. All rights reserved.
//

#import "DisplayView.h"

@implementation DisplayView

+(Class)layerClass{
    return [CAEAGLLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame{
    id obj = [super initWithFrame:frame];
    return obj;
}


- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
