//
//  MTDropDownBackgroundView.m
//  MT美团模仿
//
//  Created by Nico on 16/8/29.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDropDownBackgroundView.h"
#import "UIView+AutoLayout.h"
@interface MTDropDownBackgroundView ()


@end

@implementation MTDropDownBackgroundView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        UIButton * backgroundButton=[[UIButton alloc] init];
        [backgroundButton setBackgroundColor:[UIColor blackColor]];
        backgroundButton.alpha=0.3;
        [backgroundButton addTarget:self.delegate action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backgroundButton];
        [backgroundButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    return self;
}

//- (void)hideView
//{
//    [UIView animateWithDuration:0.2 animations:^{
//        CGRect frame=self.frame;
//        self.frame=CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0);
//    }];
//    
//}

@end
