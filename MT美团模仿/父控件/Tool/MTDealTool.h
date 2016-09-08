//
//  MTDealTool.h
//  MT美团模仿
//
//  Created by Nico on 16/9/5.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MTDeal;
@interface MTDealTool : NSObject

+ (NSArray *)dealArrayWithPage:(NSInteger)page;
+ (void)addDeal:(MTDeal *)deal;
+ (void)removeDeal:(MTDeal *)deal;
+ (NSInteger)countOfDealCollect;

+ (BOOL)isTableContainDeal:(MTDeal *)deal;
@end
