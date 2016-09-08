//
//  MTCollectionViewController.m
//  MT美团模仿
//
//  Created by Nico on 16/9/2.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTCollectionViewController.h"
#import "MTDealDetailViewController.h"
#import "MTDealCollectionViewCell.h"
#import "MTDeal.h"
#import "MTConst.h"
#import "MTDeal.h"

#define COLLECTION_SPAN 10.f
#define COLLECTION_INSET 10.f

@interface MTCollectionViewController ()<UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>



@end

@implementation MTCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const headerReuseIdentifier = @"header";

- (instancetype)init
{

    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dealsArray=[[NSMutableArray alloc] init];
 
    self.collectionView.backgroundColor=[UIColor whiteColor];
    _imageView=[[UIImageView alloc] initWithFrame:self.view.frame];
    _imageView.image=[UIImage imageNamed:@"icon_deals_empty"];
    _imageView.contentMode=UIViewContentModeScaleAspectFit;
    _imageView.backgroundColor=[UIColor whiteColor];
    _imageView.hidden=YES;
    [self.view addSubview:_imageView];
    
    UINib *nib=[UINib nibWithNibName:@"MTDealCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
    
    nib=[UINib nibWithNibName:@"MTHeaderCollectionReusableView" bundle:nil];
    [self.collectionView registerNib:nib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseIdentifier];
    
    self.currentPage=1;
    self.isNewRequest=YES;
    [self loadDataWithPage:1];
    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section==1) {
        return 0;
    }
    
    return _dealsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MTDealCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    MTDeal *deal=_dealsArray[indexPath.row];
    [cell setDeal:deal];
    return cell;
}
//
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MTHeaderCollectionReusableView *reusableView=nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section==1) {
        _headerView=[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
 withReuseIdentifier:headerReuseIdentifier forIndexPath:indexPath];
        _headerView.label.text=@"上拉加载更多";
        
        reusableView=_headerView;
    }
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (_dealsArray.count==0 || section==0 || _isAllLoaded) {
        return CGSizeZero;
    }
    return CGSizeMake(SCREEN_WIDTH, 35);
}



#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTDealDetailViewController *vc=[[MTDealDetailViewController alloc] init];
    MTDeal *deal=_dealsArray[indexPath.row];
    [vc setupDeals:deal];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark <UICollectionViewFlowLayoutDelegate>
 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width=(SCREEN_WIDTH-COLLECTION_INSET*2-COLLECTION_SPAN)/2.f;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(COLLECTION_INSET, COLLECTION_INSET, COLLECTION_INSET, COLLECTION_INSET);
}






#pragma mark <UIScrollViewDelegate>
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_isAllLoaded || _isNewRequest) {
        return;
    }
    if (scrollView.contentSize.height-scrollView.contentOffset.y<scrollView.frame.size.height-30 && !_isLoading) {
        _headerView.label.text=@"加载中";
        [_headerView.activity startAnimating];
        self.currentPage++;
        [self loadDataWithPage:_currentPage];
        self.isLoading=YES;
    }else if (scrollView.contentSize.height-scrollView.contentOffset.y>scrollView.frame.size.height-30 && !_isLoading)
    {
        _headerView.label.text=@"上拉加载更多";
    }
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"content offset %lf, content hight: %lf, height %lf",scrollView.contentOffset.y,scrollView.contentSize.height,scrollView.frame.size.height);
//    return;
    if (_isAllLoaded || _isNewRequest) {
        return;
    }
    if (scrollView.contentSize.height-scrollView.contentOffset.y<scrollView.frame.size.height-30 &&!_isLoading) {
        _headerView.label.text=@"松开加载更多";
    }else if (scrollView.contentSize.height-scrollView.contentOffset.y>scrollView.frame.size.height-30 &&!_isLoading){
        _headerView.label.text=@"上拉加载更多";
    }
    if (_isLoading) {
        _headerView.label.text=@"加载中";
    }
    
}



@end
