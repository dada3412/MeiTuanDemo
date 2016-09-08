//
//  MTAnnotation.h
//  MT美团模仿
//
//  Created by Nico on 16/9/7.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class MTDeal;
@interface MTAnnotation : NSObject<MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy)NSString *mapIcon;
@property (strong,nonatomic)MTDeal *deal;
@end
