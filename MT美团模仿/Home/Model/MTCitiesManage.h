//
//  MTCitiesManage.h
//  MT美团模仿
//
//  Created by Nico on 16/8/31.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTCity;
@interface MTCitiesManage : NSObject
@property (nonatomic,strong,readonly) NSMutableArray *citiesArray;
+ (instancetype)shareCitiesManage;
- (MTCity *)cityWithName:(NSString *)name;
@end
