//
//  MTCollectionViewController.h
//  MT美团模仿
//
//  Created by Nico on 16/9/2.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD+HM.h"
#import "MTHeaderCollectionReusableView.h"

@interface MTCollectionViewController : UICollectionViewController
@property (strong,nonatomic)NSMutableDictionary *params;
@property (assign, nonatomic)NSUInteger currentPage;
@property (assign, nonatomic)BOOL isAllLoaded;
@property (assign, nonatomic)BOOL isNewRequest;
@property (assign, nonatomic)BOOL isLoading;
@property (strong, nonatomic)NSMutableArray *dealsArray;
@property (strong,nonatomic)UIImageView *imageView;
@property (strong,nonatomic)MTHeaderCollectionReusableView *headerView;

- (void)loadDataWithPage:(NSUInteger)page;

@end
