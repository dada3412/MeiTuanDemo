//
//  MTTopButton.m
//  MT美团模仿
//
//  Created by Nico on 16/8/27.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTTopButton.h"
#import "MTConst.h"
@implementation MTTopButton

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self setTitleColor:MT_GLOBLE_COLOR forState:UIControlStateSelected];
        [self.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];    
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleLabel.frame.size.width+5, 0,-self.titleLabel.frame.size.width-5)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.imageView.frame.size.width-5, 0, self.imageView.frame.size.width+5)];
    

    
}

@end
