//
//  MTHomeTableViewFooter.m
//  MT美团模仿
//
//  Created by Nico on 16/9/1.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTHomeTableViewFooter.h"

@implementation MTHomeTableViewFooter

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        UIActivityIndicatorView *activity=[[UIActivityIndicatorView alloc] init];
        UILabel *label=[[UILabel alloc] init];
        label.textAlignment=NSTextAlignmentCenter;
        [self addSubview:activity];
        [self addSubview:label];
        _activity=activity;
        _label=label;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat activityW=self.frame.size.height;
    _activity.frame=CGRectMake(0, 0, activityW, activityW);
    
    _label.frame=CGRectMake(0, 0, self.frame.size.width*0.66, self.frame.size.height);
    _label.center=self.center;
    
    
}


@end
