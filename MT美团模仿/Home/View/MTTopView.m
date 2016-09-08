//
//  MTTopView.m
//  MT美团模仿
//
//  Created by Nico on 16/8/27.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTTopView.h"
#import "MTTopButton.h"
#import "UIView+AutoLayout.h"
@implementation MTTopView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor=[UIColor whiteColor];
        _categoryButton=[[MTTopButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/3.f, frame.size.height)];
        [_categoryButton setTitle:@"全部分类" forState:UIControlStateNormal];
        [_categoryButton setImage:[UIImage imageNamed:@"gc_navi_arrow_down"] forState:UIControlStateNormal];
        [_categoryButton setImage:[UIImage imageNamed:@"gc_navi_arrow_up"] forState:UIControlStateSelected];
        
        
        
        _districtButton=[[MTTopButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_categoryButton.frame), 0, frame.size.width/3.f, frame.size.height)];
        [_districtButton setImage:[UIImage imageNamed:@"gc_navi_arrow_down"] forState:UIControlStateNormal];
        [_districtButton setImage:[UIImage imageNamed:@"gc_navi_arrow_up"] forState:UIControlStateSelected];
        [_districtButton setTitle:@"全部" forState:UIControlStateNormal];
        
        
        _sortButton=[[MTTopButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_districtButton.frame), 0, frame.size.width/3.f, frame.size.height)];
        [_sortButton setImage:[UIImage imageNamed:@"gc_navi_arrow_down"] forState:UIControlStateNormal];
        [_sortButton setImage:[UIImage imageNamed:@"gc_navi_arrow_up"] forState:UIControlStateSelected];
        [_sortButton setTitle:@"默认排序" forState:UIControlStateNormal];
        
        
        [self addSubview:_categoryButton];
        [self addSubview:_districtButton];
        [self addSubview:_sortButton];
        
        CGFloat barH=20.f;
        UIImageView *bar1=[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_categoryButton.frame), (self.frame.size.height-barH)/2.0, 2, barH)];
        bar1.image=[UIImage imageNamed:@"bg_dropdown_rightpart"];
        
        UIImageView *bar2=[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_districtButton.frame), (self.frame.size.height-barH)/2.0, 2, barH)];
        bar2.image=[UIImage imageNamed:@"bg_dropdown_rightpart"];
        
        [self addSubview:bar1];
        [self addSubview:bar2];

        
    }
    return self;
}

@end
