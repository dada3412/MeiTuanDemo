//
//  MTDealDetailViewController.m
//  MT美团模仿
//
//  Created by Nico on 16/9/4.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDealDetailViewController.h"
#import "MTDeal.h"
#import "MTDealTool.h"
#import "MTConst.h"
@interface MTDealDetailViewController ()<UIWebViewDelegate>
@property (nonatomic, strong)MTDeal *deal;
@end

@implementation MTDealDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIWebView *webView=[[UIWebView alloc] initWithFrame:self.view.frame];
    webView.delegate=self;
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_deal.deal_h5_url]]];
    UIImage *image=nil;
    if (_deal.isCollect) {
        image=[UIImage imageNamed:@"icon_collect_highlighted"];
    }else
        image=[UIImage imageNamed:@"icon_collect"];
    UIBarButtonItem *collectBarButton=[[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tapCollectButton:)];
    UIBarButtonItem *rightSpacing=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSpacing.width=-35;
    self.navigationItem.rightBarButtonItems=@[rightSpacing,collectBarButton];
}

- (void)tapCollectButton:(UIBarButtonItem *)barButton
{
    if (!_deal)
        return;

    self.deal.isCollect=!self.deal.isCollect;
    if (self.deal.isCollect) {
        [barButton setImage:[UIImage imageNamed:@"icon_collect_highlighted"]];
        [MTDealTool addDeal:self.deal];
    }else{
        [barButton setImage:[UIImage imageNamed:@"icon_collect"]];
        [MTDealTool removeDeal:self.deal];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MTCollectSelectedNotification object:nil userInfo:@{@"deal":_deal}];
}


- (void)setupDeals:(MTDeal *)deal
{
    _deal=deal;
    _deal.isCollect=[MTDealTool isTableContainDeal:_deal];
}

#pragma mark ---webView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    NSString *contentString=[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].outerHTML;"];
//    NSLog(@"%@",contentString);
    NSMutableString *js=[NSMutableString new];
    //删除顶部返回
    [js appendString:@"var header=document.getElementsByTagName('header')[0];"];
    [js appendString:@"header.parentNode.removeChild(header);"];
    //删除其他关联团购
    [js appendString:@"var relationGroup = document.getElementsByClassName('detail-info group-other group-last J_group-other')[0];"];
    [js appendString:@"relationGroup.parentNode.removeChild(relationGroup);"];
    //删除 其他人也看了
    [js appendString:@"var otherGroup = document.getElementsByClassName('detail-info group-other J_group-other')[0];"];
    [js appendString:@"otherGroup.parentNode.removeChild(otherGroup);"];
    
    //删除 footer
    [js appendString:@"var footerBox = document.getElementsByClassName('footer')[0];"];
    [js appendString:@"footerBox.parentNode.removeChild(footerBox);"];
    
    //删除 footer
    [js appendString:@"var footerButtonFix = document.getElementsByClassName('footer-btn-fix')[0];"];
    [js appendString:@"footerButtonFix .parentNode.removeChild(footerButtonFix);"];
    
    [webView stringByEvaluatingJavaScriptFromString:js];

}

@end
