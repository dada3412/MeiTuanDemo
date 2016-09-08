//
//  MTHeaderCollectionReusableView.h
//  MT美团模仿
//
//  Created by Nico on 16/9/3.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTHeaderCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
