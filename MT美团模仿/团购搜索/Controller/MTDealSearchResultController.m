//
//  MTDealSearchResultController.m
//  MT美团模仿
//
//  Created by Nico on 16/9/5.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDealSearchResultController.h"
#import "MTDealSearchViewController.h"
#import "MTConst.h"
#import "DPAPI.h"
#import "MTDeal.h"

@interface MTDealSearchResultController ()<DPRequestDelegate>
@property (strong,nonatomic)DPRequest *lastRequest;
@end

@implementation MTDealSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---点评API交互
- (void)loadDataWithPage:(NSUInteger)page
{
    DPAPI *api=[[DPAPI alloc] init];
    self.params[@"limit"]=@(limitNum);
    
    self.params[@"page"]=@(page);
    self.isLoading=YES;
    self.lastRequest=[api requestWithURL:@"v1/deal/find_deals" params:self.params delegate:self];
}


- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (request!=_lastRequest) {
        return;
    }
    [self.headerView.activity stopAnimating];
    self.isLoading=NO;
    NSUInteger totleCount=[result[@"total_count"] integerValue];
    if (totleCount==0) {
        self.isAllLoaded=YES;
        self.dealsArray=nil;
        [self.collectionView reloadData];
        self.imageView.hidden=NO;
        return;
    }
    self.imageView.hidden=YES;
    self.isNewRequest=NO;
    NSArray *resultArray=result[@"deals"];
    [resultArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
        MTDeal *deal=[[MTDeal alloc] initWithDic:dic];
        [self.dealsArray addObject:deal];
    }];
    if (self.dealsArray.count==totleCount) {
        self.isAllLoaded=YES;
    }
    [self.collectionView reloadData];
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    if (request!=_lastRequest) {
        return;
    }
    [self.headerView.activity stopAnimating];
    if (self.currentPage!=1) {
        self.isNewRequest=NO;
    }
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
        self.isLoading=NO;
    }
}





@end
