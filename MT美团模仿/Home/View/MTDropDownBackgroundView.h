//
//  MTDropDownBackgroundView.h
//  MT美团模仿
//
//  Created by Nico on 16/8/29.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HideView <NSObject>

@required
-(void)hideView;

@end

@interface MTDropDownBackgroundView : UIView
@property (weak,nonatomic)id<HideView>delegate;
@end
