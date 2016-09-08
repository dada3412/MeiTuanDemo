//
//  MTTopView.h
//  MT美团模仿
//
//  Created by Nico on 16/8/27.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTTopButton.h"

@interface MTTopView : UIView
@property (strong, nonatomic) MTTopButton *categoryButton;
@property (strong, nonatomic) MTTopButton *districtButton;
@property (strong, nonatomic) MTTopButton *sortButton;
@end
