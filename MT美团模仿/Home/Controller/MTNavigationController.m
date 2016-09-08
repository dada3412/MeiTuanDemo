//
//  MTNavigationController.m
//  MT美团模仿
//
//  Created by Nico on 16/8/27.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTNavigationController.h"
#import "MTConst.h"
@interface MTNavigationController ()

@end

@implementation MTNavigationController

+ (void)initialize
{
    UINavigationBar *navigationBar=[UINavigationBar appearance];
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar_normal"] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setTintColor:MT_GLOBLE_COLOR];
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
}

//- (instancetype)init
//{
//    if (self=[super init]) {
////        [self.navigationItem.backBarButtonItem setTitle:@""];
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
