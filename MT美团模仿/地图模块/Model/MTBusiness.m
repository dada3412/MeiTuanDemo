//
//  MTBusiness.m
//  MT美团模仿
//
//  Created by Nico on 16/9/7.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTBusiness.h"
@implementation MTBusiness
- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self=[super init]) {
        self.name=dic[@"name"];
        self.latitude=dic[@"latitude"];
        self.longitude=dic[@"longitude"];
    }
    return self;
}
@end
