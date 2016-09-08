//
//  MTAnnotationView.m
//  MT美团模仿
//
//  Created by Nico on 16/9/7.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTAnnotationView.h"

@implementation MTAnnotationView

static NSString *ID=@"MTAnnotation";

+ (instancetype)annotationWithMapView:(MKMapView *)mapView annotation:(id<MKAnnotation>)annotation
{
    MTAnnotationView *annotationView=(MTAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (!annotationView) {
        annotationView=[[MTAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:ID];
        annotationView.canShowCallout=YES;
    }
    annotationView.annotation=annotation;
    return annotationView;
}

@end
