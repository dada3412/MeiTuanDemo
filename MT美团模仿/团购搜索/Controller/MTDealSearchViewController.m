//
//  MTDealSearchTableViewController.m
//  MT美团模仿
//
//  Created by Nico on 16/9/3.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDealSearchViewController.h"
#import "MTPopularSearchCollectionViewCell.h"
#import "MTDealSearchResultController.h"
#import "MTConst.h"
#import "UIView+AutoLayout.h"

#define BG_COLOR ([UIColor colorWithWhite:0.938 alpha:1.000])

@interface MTDealSearchViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) NSArray *collectionArray;
@property (strong,nonatomic) NSMutableArray *historyArray;
@property (strong, nonatomic) UIButton *button;
@property (weak, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIView *topHeaderView;
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation MTDealSearchViewController

NSString *const collectionIdentity=@"collectionIdentity";
NSString *const tableViewIdentity=@"tableViewIdentity";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self topHeaderView];
    self.tableView.backgroundColor=BG_COLOR;
    self.tableView.tableFooterView=[[UIView alloc] init];
    
    
    _historyArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"searchHistory"] mutableCopy];
    _collectionArray=[@[@"可颂坊",@"楼兰",@"佳田",@"玉蝶坊",@"肯德基",@"麦当劳",@"真功夫",@"华奥通",@"烤全羊"] copy];
    
    UINib *nib=[UINib nibWithNibName:@"MTPopularSearchCollectionViewCell" bundle:nil];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:collectionIdentity];
    UISearchBar *searchBar=[[UISearchBar alloc] init];
    searchBar.searchBarStyle=UISearchBarStyleMinimal;
    [self setSearchBarApprence:searchBar];
    self.navigationItem.titleView=searchBar;
    searchBar.delegate=self;
    self.searchBar=searchBar;
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0, 0, SCREEN_WIDTH, 44.f);
    button.backgroundColor=[UIColor whiteColor];
    [button setTitle:@"清除搜索记录" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(delectSearchHistory) forControlEvents:UIControlEventTouchUpInside];
    _button=button;
    
}

- (void)delectSearchHistory
{
    [_historyArray removeAllObjects];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [_searchBar becomeFirstResponder];
    [self.tableView reloadData];
}

-(NSMutableArray *)historyArray
{
    if (!_historyArray) {
        _historyArray=[[NSMutableArray alloc] initWithCapacity:10];
    }
    return _historyArray;
}

- (UILabel *)labelWithTitle:(NSString *)title
{
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    titleLabel.backgroundColor=BG_COLOR;
    titleLabel.text=[NSString stringWithFormat:@"  %@",title];
    titleLabel.textAlignment=NSTextAlignmentLeft;
    titleLabel.textColor=[UIColor lightGrayColor];
    titleLabel.font=[UIFont systemFontOfSize:12.f];
    
    return titleLabel;
}

- (void)setSearchBarApprence:(UISearchBar *)searchBar
{
    UITextField *searchField=[searchBar valueForKey:@"searchField"];
    if (searchField) {
        searchField.layer.cornerRadius=14.f;
        searchField.clipsToBounds=YES;
    }
    searchBar.tintColor=MT_GLOBLE_COLOR;
    searchBar.placeholder=@"请输入商品名称地址等等";
}

- (UIView *)topHeaderView
{
    if (!_topHeaderView) {
        UILabel *titleLabel=[self labelWithTitle:@"热门搜索"];
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        CGFloat spacing=2.0;
        layout.itemSize=CGSizeMake((SCREEN_WIDTH-spacing)/3.f, 35.f);
        layout.minimumLineSpacing=1;
        layout.minimumInteritemSpacing=0;
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), SCREEN_WIDTH, 105) collectionViewLayout:layout];
        _collectionView.backgroundColor=BG_COLOR;
        _collectionView.scrollEnabled=NO;
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        
        CGFloat viewH=_collectionView.frame.size.height+titleLabel.frame.size.height;
        _topHeaderView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, viewH)];
        [_topHeaderView addSubview:titleLabel];
        [_topHeaderView addSubview:_collectionView];
    }
    return _topHeaderView;
}




#pragma mark <UICollectionViewDelegate & UICollectionViewDataSource>



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _collectionArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTPopularSearchCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:collectionIdentity forIndexPath:indexPath];
    NSString *title=_collectionArray[indexPath.row];
    cell.titleLabel.text=title;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    
    if (self.city) {
        params[@"city"]=self.city;
    }
    NSString *popularString=_collectionArray[indexPath.row];
    
    params[@"keyword"]=popularString;
    MTDealSearchResultController *vc=[MTDealSearchResultController new];
    vc.params=params;
    [self.navigationController pushViewController:vc animated:NO];
}


#pragma mark <UIScrolViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark <UITableViewDelegate & UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_historyArray.count>0) {
        return 3;
    }else
        return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section!=1) {
        return 0;
    }
    return self.historyArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return CGRectGetMaxY(_topHeaderView.frame);
    }
    if (section==1) {
        return 35.f;
    }
    
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return _topHeaderView;
    }
    if (section==1) {
        return [self labelWithTitle:@"历史搜索"];
    }
    
    return _button;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text=_historyArray[indexPath.row];
    cell.imageView.image=[UIImage imageNamed:@"icon_search"];
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    
    if (self.city) {
        params[@"city"]=self.city;
    }
    NSString *searchString=_historyArray[indexPath.row];
    
    params[@"keyword"]=searchString;
    MTDealSearchResultController *vc=[MTDealSearchResultController new];
    vc.params=params;
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark <searchBar delegate>

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    
    if (self.city) {
        params[@"city"]=self.city;
    }
    if (searchBar.text.length>0) {
        NSString *string=[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (string.length>0) {
            params[@"keyword"]=searchBar.text;
            MTDealSearchResultController *vc=[MTDealSearchResultController new];
            vc.params=params;
            [self.navigationController pushViewController:vc animated:NO];
            if (![self.historyArray containsObject:string]) {
                [self.historyArray insertObject:string atIndex:0];
            }
        }else
            [searchBar resignFirstResponder];
    }
}


#pragma mark  私有接口
- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] setObject:_historyArray forKey:@"searchHistory"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.searchBar resignFirstResponder];
}

@end
