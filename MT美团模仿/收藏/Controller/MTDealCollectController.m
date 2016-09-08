//
//  MTDealCollectController.m
//  MT美团模仿
//
//  Created by Nico on 16/9/5.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDealCollectController.h"
#import "MTDealTool.h"
#import "MTConst.h"
#import "MTDeal.h"
@interface MTDealCollectController ()
@property (nonatomic,strong)NSMutableArray *selectedArray;
@property (nonatomic,assign)BOOL isEdit;
@property (nonatomic,strong)UIBarButtonItem *exitButton;
@property (nonatomic,strong)UIBarButtonItem *barSpacer;
@property (nonatomic,strong)UIBarButtonItem *allSelectButton;
@property (nonatomic,strong)UIBarButtonItem *deselectButton;
@end

@implementation MTDealCollectController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedArray=[NSMutableArray array];
    [self setNavigationBarButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectChanged:) name:MTCollectSelectedNotification object:nil];
    self.imageView.image=[UIImage imageNamed:@"icon_collects_empty"];
}

- (void)setNavigationBarButton
{
    self.navigationItem.title=@"收藏";
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"btn_navigation_close"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btn_navigation_close_hl"] forState:UIControlStateHighlighted];
    CGSize size=button.currentImage.size;
    button.frame=CGRectMake(0, 0, size.width, size.height);
    [button addTarget:self action:@selector(dismissCityViewController) forControlEvents:UIControlEventTouchUpInside];
    _exitButton=[[UIBarButtonItem alloc] initWithCustomView:button];
    _barSpacer=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    _barSpacer.width=-10;
    self.navigationItem.leftBarButtonItems=@[_barSpacer,_exitButton];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(removeCollect:)];
    
    _allSelectButton=[[UIBarButtonItem alloc] initWithTitle:@"全部" style:UIBarButtonItemStylePlain target:self action:@selector(selectAll)];
    _deselectButton=[[UIBarButtonItem alloc] initWithTitle:@"取消全部" style:UIBarButtonItemStylePlain target:self action:@selector(deselectAll)];
}
#pragma mark ---导航栏buttom方法
- (void)dismissCityViewController
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeCollect:(UIBarButtonItem *)btn
{
    self.isEdit=!_isEdit;
    if (self.isEdit) {
        self.collectionView.allowsMultipleSelection=YES;
        self.navigationItem.leftBarButtonItems=@[_barSpacer,_exitButton,_allSelectButton,_deselectButton];
        [btn setTitle:@"完成"];
        [self.dealsArray enumerateObjectsUsingBlock:^(MTDeal *deal, NSUInteger idx, BOOL * _Nonnull stop) {
            deal.isEdit=YES;
        }];
        [self.collectionView reloadData];
    }else{
        self.collectionView.allowsMultipleSelection=NO;
        self.navigationItem.leftBarButtonItems=@[_barSpacer,_exitButton];
        [btn setTitle:@"删除"];
        [self.selectedArray enumerateObjectsUsingBlock:^(MTDeal *deal, NSUInteger idx, BOOL * _Nonnull stop) {
            if (deal.isSelected) {
                [MTDealTool removeDeal:deal];
                [self.dealsArray removeObject:deal];
            }
        }];
        [self.dealsArray enumerateObjectsUsingBlock:^(MTDeal *deal, NSUInteger idx, BOOL * _Nonnull stop) {
            deal.isEdit=NO;
        }];
        [_selectedArray removeAllObjects];
        [self.collectionView reloadData];
    }
}

- (void)selectAll
{
    self.selectedArray=[self.dealsArray mutableCopy];
    [self.selectedArray enumerateObjectsUsingBlock:^(MTDeal *deal, NSUInteger idx, BOOL * _Nonnull stop) {
        deal.isSelected=YES;
    }];
    [self.collectionView reloadData];
}

- (void)deselectAll
{
    [self.selectedArray enumerateObjectsUsingBlock:^(MTDeal *deal, NSUInteger idx, BOOL * _Nonnull stop) {
        deal.isSelected=NO;
    }];
    [self.selectedArray removeAllObjects];
    [self.collectionView reloadData];
}

#pragma mark ---监听notification
- (void)collectChanged:(NSNotification *)note
{
    NSDictionary *userInfo=note.userInfo;
    MTDeal *deal=userInfo[@"deal"];
    if ([MTDealTool isTableContainDeal:deal]) {
        [self.dealsArray insertObject:deal atIndex:0];
    }else{
        [self.dealsArray removeObject:deal];
        if (self.dealsArray.count==0) {
            self.imageView.hidden=NO;
        }
    }
    
    [self.collectionView reloadData];
}



#pragma mark 父类公共接口
- (void)loadDataWithPage:(NSUInteger)page
{
    
    [self.headerView.activity stopAnimating];
    self.isLoading=YES;
    NSInteger total_num=[MTDealTool countOfDealCollect];
    if (total_num==0) {
        self.dealsArray=nil;
        [self.collectionView reloadData];
        self.isAllLoaded=YES;
        self.imageView.hidden=NO;
        return;
    }
    self.imageView.hidden=YES;
    self.isNewRequest=NO;
    NSArray *array=[MTDealTool dealArrayWithPage:page];
    [self.dealsArray addObjectsFromArray:array];
    if (self.dealsArray.count==total_num) {
        self.isAllLoaded=YES;
    }
    [self.collectionView reloadData];
    self.isLoading=NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MTCollectSelectedNotification object:nil];
}

#pragma  mark ---collectionView delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.allowsMultipleSelection) {
        MTDeal *deal=self.dealsArray[indexPath.row];
        deal.isSelected=!deal.isSelected;
        if (deal.isSelected) {
            [self.selectedArray addObject:deal];
        }else
            [self.selectedArray removeObject:deal];
        
    }
    else
        [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

@end
