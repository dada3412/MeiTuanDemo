//
//  MTCitiesManage.m
//  MT美团模仿
//
//  Created by Nico on 16/8/31.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTCitiesManage.h"
#import "MTCity.h"
#import "MTRegion.h"
@interface MTCitiesManage ()
@property (nonatomic,strong, readwrite)NSMutableArray *citiesArray;

@end

@implementation MTCitiesManage

static MTCitiesManage *_instance=nil;

+ (instancetype)shareCitiesManage
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[[self alloc] init];
    });
    return  _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[super allocWithZone:zone];
    });
    
    return _instance;
}

- (instancetype)init
{
    if (self=[super init]) {
        _citiesArray=[NSMutableArray new];
        NSString * path=[[NSBundle mainBundle] pathForResource:@"cities" ofType:@"plist"];
        NSArray * array=[NSArray arrayWithContentsOfFile:path];
        [array enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MTCity *city=[[MTCity alloc] init];
            city.name=obj[@"name"];
            city.pinYin=obj[@"pinYin"];
            city.pinYinHead=obj[@"pinYinHead"];
            
            NSArray *regionsArray=obj[@"regions"];
            NSMutableArray *array=[NSMutableArray new];
            [regionsArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MTRegion *region=[MTRegion new];
                region.name=obj[@"name"];
                region.subArray=obj[@"subregions"];
                [array addObject:region];
            }];
            city.regionsArray=[NSArray arrayWithArray:array];
            [self.citiesArray addObject:city];
        }];
    }
    return self;
}

#pragma mark ---公共接口

- (MTCity *)cityWithName:(NSString *)name
{
    __block MTCity *city=nil;
    [_citiesArray enumerateObjectsUsingBlock:^(MTCity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:name]) {
            city=obj;
        }
    }];
    return city;
}

@end
