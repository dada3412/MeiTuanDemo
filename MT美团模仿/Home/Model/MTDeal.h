//
//  MTDeal.h
//  MT美团模仿
//
//  Created by Nico on 16/9/1.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTDeal : NSObject<NSCoding>
@property (strong, nonatomic)NSString *deal_id;
@property (strong, nonatomic)NSString *title;
@property (strong, nonatomic)NSString *dealDescription;
@property (strong, nonatomic)NSNumber *list_price;
@property (strong, nonatomic)NSNumber *current_price;
@property (strong, nonatomic)NSString *image_url;
@property (strong, nonatomic)NSString *s_image_url;
@property (strong, nonatomic)NSNumber *purchase_count;
@property (strong, nonatomic)NSString *deal_h5_url;
@property (strong, nonatomic)NSArray *businesses;
@property (strong, nonatomic)NSArray *categories;
@property (assign, nonatomic)BOOL isCollect;
@property (assign, nonatomic)BOOL isSelected;
@property (assign, nonatomic)BOOL isEdit;


- (instancetype)initWithDic:(NSDictionary *)dic;
@end
