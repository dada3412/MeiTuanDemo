//
//  MTAnnotationView.h
//  MT美团模仿
//
//  Created by Nico on 16/9/7.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MTAnnotationView : MKAnnotationView
+ (instancetype)annotationWithMapView:(MKMapView *)mapView annotation:(id<MKAnnotation>)annotation;
@end
