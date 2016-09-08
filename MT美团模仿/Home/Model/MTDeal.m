//
//  MTDeal.m
//  MT美团模仿
//
//  Created by Nico on 16/9/1.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDeal.h"

@implementation MTDeal



- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self=[super init]) {
        _deal_id=dic[@"deal_id"];
        _title=dic[@"title"];
        _dealDescription=dic[@"description"];
        _list_price=dic[@"list_price"];
        _current_price=dic[@"current_price"];
        _image_url=dic[@"image_url"];
        _s_image_url=dic[@"s_image_url"];
        _purchase_count=dic[@"purchase_count"];
        _deal_h5_url=dic[@"deal_h5_url"];
        _businesses=dic[@"businesses"];
        _categories=dic[@"categories"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_deal_id forKey:@"deal_id"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_dealDescription forKey:@"dealDescription"];
    [aCoder encodeObject:_list_price forKey:@"list_price"];
    [aCoder encodeObject:_current_price forKey:@"current_price"];
    [aCoder encodeObject:_image_url forKey:@"image_url"];
    [aCoder encodeObject:_s_image_url forKey:@"s_image_url"];
    [aCoder encodeObject:_purchase_count forKey:@"purchase_count"];
    [aCoder encodeObject:_deal_h5_url forKey:@"deal_h5_url"];
    [aCoder encodeBool:_isCollect forKey:@"isCollect"];
    [aCoder encodeBool:_isSelected forKey:@"isSelected"];
    [aCoder encodeBool:_isEdit forKey:@"isEdit"];
    [aCoder encodeObject:_businesses forKey:@"businesses"];
    [aCoder encodeObject:_categories forKey:@"categories"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    _deal_id=[aDecoder decodeObjectForKey:@"deal_id"];
    _title=[aDecoder decodeObjectForKey:@"title"];
    _dealDescription=[aDecoder decodeObjectForKey:@"dealDescription"];
    _list_price=[aDecoder decodeObjectForKey:@"list_price"];
    _current_price=[aDecoder decodeObjectForKey:@"current_price"];
    _image_url=[aDecoder decodeObjectForKey:@"image_url"];
    _s_image_url=[aDecoder decodeObjectForKey:@"s_image_url"];
    _purchase_count=[aDecoder decodeObjectForKey:@"purchase_count"];
    _deal_h5_url=[aDecoder decodeObjectForKey:@"deal_h5_url"];
    _isCollect=[aDecoder decodeObjectForKey:@"isCollect"];
    _isSelected=[aDecoder decodeObjectForKey:@"isSelected"];
    _isEdit=[aDecoder decodeObjectForKey:@"isEdit"];
    _businesses=[aDecoder decodeObjectForKey:@"businesses"];
    _categories=[aDecoder decodeObjectForKey:@"categories"];
    return self;
}

@end
