//
//  MTMapViewController.m
//  MT美团模仿
//
//  Created by Nico on 16/9/5.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTMapViewController.h"
#import <MapKit/MapKit.h>
#import "MBProgressHUD+HM.h"
#import "DPAPI.h"
#import "MTConst.h"
#import "MTDeal.h"
#import "MTBusiness.h"
#import "MTAnnotation.h"
#import "MTAnnotationView.h"
#import "MTCategory.h"
#import <objc/runtime.h>
#import "MTNavigationController.h"
#import "MTDealMapViewController.h"
@interface MTMapViewController ()<MKMapViewDelegate,DPRequestDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic)CLLocationManager *clManager;
@property (assign,nonatomic,getter=isUploadLocation)BOOL uploadLocation;
@property (assign,nonatomic,getter=islocalCity)BOOL localCity;
@property (strong,nonatomic)NSString *selectedCategory;
@property (strong,nonatomic)NSMutableArray *categoryArray;
@property (assign,nonatomic)CLLocationCoordinate2D mapCenterCoordinate;

@end

@implementation MTMapViewController

static char *dealKey="dealKey";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate=self;
    [self.mapView setShowsUserLocation:YES];
    _categoryArray=[[NSMutableArray alloc] init];
    NSString *path=[[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
    NSArray *categoriesArray=[NSArray arrayWithContentsOfFile:path];
    [categoriesArray enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MTCategory *category=[MTCategory new];
        category.name=obj[@"name"];
        category.subArray=obj[@"subcategories"];
        category.mapIcon=obj[@"map_icon"];
        [self.categoryArray addObject:category];
    }];



    [self.backButton addTarget:self action:@selector(tapBackButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.locationButton addTarget:self action:@selector(tapLocation) forControlEvents:UIControlEventTouchUpInside];
    _clManager=[[CLLocationManager alloc] init];
    
    if ([self.clManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.clManager requestWhenInUseAuthorization];
    }
    [MBProgressHUD showMessage:@"正在定位" toView:self.view];
}

- (void)tapLocation
{
    MKCoordinateSpan span=MKCoordinateSpanMake(0.02, 0.02);
    MKCoordinateRegion region=MKCoordinateRegionMake(_mapView.userLocation.coordinate, span);
    _mapView.centerCoordinate=_mapView.userLocation.coordinate;
    _mapView.region=region;
}

- (void)tapBackButton
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)tapRightCalloutButton:(UIButton *)btn
{
    MTDeal *deal=objc_getAssociatedObject(btn, dealKey);
    if (!deal) {
        return;
    }
    
    MTDealMapViewController *dvc=[[MTDealMapViewController alloc] init];
    [dvc setupDeals:deal];
    MTNavigationController *nvc=[[MTNavigationController alloc] initWithRootViewController:dvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark --MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view];
    [MBProgressHUD showError:@"定位失败" toView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
    });
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.isUploadLocation) {
        return;
    }
    
    [MBProgressHUD hideHUDForView:self.view];
    _uploadLocation=YES;
    __block NSString *city=nil;
    CLGeocoder *coder=[[CLGeocoder alloc] init];
    [coder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark=[placemarks firstObject];
        city=placemark.locality?placemark.locality:placemark.addressDictionary[@"City"];
        city=[city substringToIndex:city.length-1];
        if ([city isEqualToString:_selectedCity]) {
            self.localCity=YES;
            MKCoordinateSpan span=MKCoordinateSpanMake(0.025, 0.025);
            MKCoordinateRegion region=MKCoordinateRegionMake(userLocation.coordinate, span);
            mapView.centerCoordinate=userLocation.coordinate;
            mapView.region=region;
            [self loadDataWithCoordinate:userLocation.coordinate Radius:2000];
            return;
        }
        
        [coder geocodeAddressString:_selectedCity completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            self.localCity=NO;
            CLPlacemark *placemark=[placemarks firstObject];
            MKCoordinateSpan span=MKCoordinateSpanMake(0.1, 0.1);
            MKCoordinateRegion region=MKCoordinateRegionMake(placemark.location.coordinate, span);
            mapView.centerCoordinate=placemark.location.coordinate;
            _mapCenterCoordinate=mapView.centerCoordinate;
            mapView.region=region;
            [self loadDataWithCoordinate:placemark.location.coordinate Radius:5000];
        }];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MTAnnotation *)annotation
{
    if ([annotation isKindOfClass:NSClassFromString(@"MKUserLocation")]) {
        return nil;
    }
    MTAnnotationView *annotationView=[MTAnnotationView annotationWithMapView:mapView annotation:annotation];

    annotationView.image=[UIImage imageNamed:annotation.mapIcon];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeInfoLight];
    objc_setAssociatedObject(button, dealKey, annotation.deal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [button addTarget:self action:@selector(tapRightCalloutButton:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView=button;
    
    return annotationView;
}




#pragma mark ---点评API交互

- (void)loadDataWithCoordinate:(CLLocationCoordinate2D )coordinate Radius:(int)radius
{
    [MBProgressHUD showMessage:@"加载附近团购数据" toView:self.view];
    DPAPI *api=[[DPAPI alloc] init];
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    params[@"limit"]=@25;
    params[@"city"]=_selectedCity;
    if (self.selectedCategory && ![_selectedCategory isEqualToString:@"全部分类"]) {
        params[@"category"]=_selectedCategory;
    }
    params[@"latitude"]=@(coordinate.latitude);
    params[@"longitude"]=@(coordinate.longitude);
    params[@"radius"]=@(radius);
    [api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];
    
}




- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
//    NSLog(@"%@",result);
    [MBProgressHUD hideHUDForView:self.view];
    NSArray *resultArray=result[@"deals"];
    CLLocation *userLocation=_mapView.userLocation.location;
    [resultArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
        MTDeal *deal=[[MTDeal alloc] initWithDic:dic];
        [deal.businesses enumerateObjectsUsingBlock:^(NSDictionary *businessDic, NSUInteger idx, BOOL * _Nonnull stop) {
            MTBusiness *business=[[MTBusiness alloc] initWithDic:businessDic];
            CLLocation *currentLocation=[[CLLocation alloc] initWithLatitude:business.latitude.doubleValue longitude:business.longitude.doubleValue];
            if (self.islocalCity) {
                if ([userLocation distanceFromLocation:currentLocation]<=2000) {
                    [self addAnnotationWithBussines:business deal:deal];
                }
            }else{
                CLLocation *mapCenterLocation=[[CLLocation alloc] initWithLatitude:_mapCenterCoordinate.latitude longitude:_mapCenterCoordinate.longitude];
                if ([mapCenterLocation distanceFromLocation:currentLocation]<=5000) {
                    [self addAnnotationWithBussines:business deal:deal];
                }
            }
        }];
    }];
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view];
    if (error) {
        NSDictionary *dic=error.userInfo;
        NSString *errorMessage=dic[@"errorMessage"];
        NSRange leadingRange=[errorMessage rangeOfString:@"("];
        NSRange tailRange=[errorMessage rangeOfString:@")"];
        NSRange range=NSMakeRange(leadingRange.location+1, tailRange.location-leadingRange.location-1);
        NSString *errorMessageInChinese=[errorMessage substringWithRange:range];
        [MBProgressHUD showError:errorMessageInChinese toView:self.view];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
    }
}

#pragma  mark ---私有方法

- (void)addAnnotationWithBussines:(MTBusiness *)business deal:(MTDeal *)deal
{
    __block MTAnnotation *annotation=[[MTAnnotation alloc] init];
    CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(business.latitude.doubleValue, business.longitude.doubleValue);
    annotation.title=business.name;
    annotation.coordinate=coordinate;
    annotation.deal=deal;
    NSString *categorString=deal.categories.firstObject;


    for (MTCategory *obj in _categoryArray) {
        if ([obj.name isEqualToString:categorString]) {
            annotation.mapIcon=obj.mapIcon;
            [self.mapView addAnnotation:annotation];
            return;
        }else{
            for (NSString *subCategoryString in obj.subArray) {
                if ([subCategoryString isEqualToString:categorString]) {
                    annotation.mapIcon=obj.mapIcon;
                    [self.mapView addAnnotation:annotation];
                    return;
                }
            }
        }
    }
    
    annotation.mapIcon=@"ic_category_1";
    [self.mapView addAnnotation:annotation];
}




@end
