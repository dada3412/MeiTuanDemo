//
//  MTConst.h
//  MT美团模仿
//
//  Created by Nico on 16/8/30.
//  Copyright © 2016年 Nico. All rights reserved.
//
#import <Foundation/Foundation.h>
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif

#define MTColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define MT_GLOBLE_COLOR MTColor(21,188,173)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

extern NSString *const MTParameterSelectedNotification;
extern NSString *const MTCitySelectedNotification;
extern NSString *const MTCollectSelectedNotification;
extern const NSUInteger limitNum;
