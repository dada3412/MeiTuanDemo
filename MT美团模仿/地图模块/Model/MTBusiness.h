//
//  MTBusiness.h
//  MT美团模仿
//
//  Created by Nico on 16/9/7.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTBusiness : NSObject
@property (strong,nonatomic)NSString *name;
@property (strong,nonatomic)NSNumber *latitude;
@property (strong,nonatomic)NSNumber *longitude;
- (instancetype)initWithDic:(NSDictionary *)dic;
@end
