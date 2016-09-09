//
//  MTDealMapViewController.m
//  MT美团模仿
//
//  Created by Nico on 16/9/9.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDealMapViewController.h"

@interface MTDealMapViewController ()

@end

@implementation MTDealMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBarButton
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"btn_navigation_close"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btn_navigation_close_hl"] forState:UIControlStateHighlighted];
    CGSize size=button.currentImage.size;
    button.frame=CGRectMake(0, 0, size.width, size.height);
    [button addTarget:self action:@selector(dismissCityViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem * barSpacer=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barSpacer.width=-10;
    self.navigationItem.leftBarButtonItems=@[barSpacer,leftBarButtonItem];
}

- (void)dismissCityViewController
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
