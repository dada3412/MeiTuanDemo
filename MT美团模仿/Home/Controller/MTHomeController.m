//
//  MTHomeCollectionController.m
//  MT美团模仿
//
//  Created by Nico on 16/8/26.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTHomeController.h"
#import "MTTopView.h"
#import "MTDropdownController.h"
#import "MTDropDownBackgroundView.h"
#import "MTCategory.h"
#import "MTRegion.h"
#import "DPAPI.h"
#import "MTCityViewController.h"
#import "MTNavigationController.h"
#import "MTConst.h"
#import "MTCity.h"
#import "MTCitiesManage.h"
#import "MTHomeTableViewCell.h"
#import "MTDeal.h"
#import "MTHomeTableViewCell.h"
#import "MTHomeTableViewFooter.h"
#import "MBProgressHUD+HM.h"
#import "UIView+AutoLayout.h"
#import "MTCollectionViewController.h"
#import "MTDealSearchViewController.h"
#import "MTDealDetailViewController.h"
#import "MTMapViewController.h"
#import "AwesomeMenu.h"
#import "MTDealCollectController.h"


@interface MTHomeController ()<HideView,DropdownDataSource,DPRequestDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,AwesomeMenuDelegate>

@property (strong, nonatomic)MTDropdownController *categoryController;
@property (strong, nonatomic)MTDropdownController *districtController;
@property (strong, nonatomic)MTDropdownController *sortController;

@property (weak, nonatomic) MTTopView *topView;
@property (weak, nonatomic)MTDropDownBackgroundView *dropDownBackgroundView;
@property (weak,nonatomic)UIButton *leftButton;
@property (strong, nonatomic)UITableView *tableView;
@property (strong, nonatomic)UIImageView *imageView;
@property (strong, nonatomic)MTHomeTableViewFooter *footerView;
@property (weak, nonatomic)UIRefreshControl *refreshControl;

@property (strong, nonatomic)NSMutableArray *categoryArray;
@property (strong, nonatomic)NSArray *regionArray;
@property (strong, nonatomic)NSMutableArray *sortArray;
@property (strong, nonatomic)NSMutableArray *dealsArray;

@property (weak,nonatomic)UIButton *selectedButton;
@property (weak, nonatomic)MTDropdownController *selectedController;
@property (strong, nonatomic)NSString *selectedCategory;
@property (strong, nonatomic)NSString *selectedRegion;
@property (assign,nonatomic) int selectedSort;
@property (strong, nonatomic)NSString *selectedCity;
@property (strong, nonatomic)DPRequest *lastRequest;
@property (assign, nonatomic)NSUInteger currentPage;
@property (assign, nonatomic)BOOL isAllLoaded;
@property (assign, nonatomic)BOOL isLoading;
@property (assign, nonatomic)BOOL isNewRequest;




//@property (strong,nonatomic)
@end

@implementation MTHomeController

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor lightGrayColor];
    [self setNavigationButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCityNotification:) name:MTCitySelectedNotification object:nil];
    self.selectedCity=@"深圳";
    
    MTTopView *topViw=[[MTTopView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, 38)];
    [self.view addSubview:topViw];
    _topView=topViw;
    
    CGFloat tableViewY=CGRectGetMaxY(_topView.frame);
    CGFloat tableViewW=SCREEN_WIDTH;
    CGFloat tableViewH=SCREEN_HEIGHT-tableViewY-64;
    CGRect tableViewFrame=CGRectMake(0, tableViewY, tableViewW, tableViewH);
    _tableView=[[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    _tableView.backgroundColor=[UIColor colorWithWhite:0.915 alpha:1.000];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    UINib *nib=[UINib nibWithNibName:@"MTHomeTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:reuseIdentifier];
    [self.view addSubview:self.tableView];
    
    UIRefreshControl *refreshControl=[[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle=[[NSAttributedString alloc] initWithString:@"努力加载中" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13],
                                                                                                        NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
    
    [self.tableView addSubview:refreshControl];
    _refreshControl=refreshControl;
    
    
    _footerView=[[MTHomeTableViewFooter alloc] init];
    _footerView.frame=CGRectMake(0, 0, SCREEN_WIDTH, 30);
    _footerView.backgroundColor=[UIColor whiteColor];
    _footerView.activity.hidesWhenStopped=YES;
    [_footerView.activity setColor:[UIColor darkGrayColor]];
    _footerView.label.text=@"上拉加载更多";
    _footerView.hidden=YES;
    
    _imageView=[[UIImageView alloc] initWithFrame:tableViewFrame];
    _imageView.image=[UIImage imageNamed:@"icon_deals_empty"];
    _imageView.contentMode=UIViewContentModeScaleAspectFit;
    _imageView.backgroundColor=[UIColor whiteColor];
    _imageView.hidden=YES;
    [self.view addSubview:_imageView];
    
    MTDropDownBackgroundView *dropDownBackgroundView=[[MTDropDownBackgroundView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topViw.frame), SCREEN_WIDTH, 0)];
    dropDownBackgroundView.delegate=self;
    [self.view addSubview:dropDownBackgroundView];
    _dropDownBackgroundView=dropDownBackgroundView;
    
    [topViw.categoryButton addTarget:self action:@selector(tapCategoryButton:) forControlEvents:UIControlEventTouchUpInside];
    [topViw.districtButton addTarget:self action:@selector(tapDistrictButton:) forControlEvents:UIControlEventTouchUpInside];
    [topViw.sortButton addTarget:self action:@selector(tapSortButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self loadLocalData];
    
    [self setAwesomeMenu];
    
    [self loadNewData];
    [self.categoryController view];
    [self.sortController view];
    [self.districtController view];
    [self.categoryController resetData];
    [self.sortController resetData];
    [self.districtController resetData];

}



- (void)loadLocalData
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"categories" ofType:@"plist"];
    NSArray *categoriesArray=[NSArray arrayWithContentsOfFile:path];
    [categoriesArray enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MTCategory *category=[MTCategory new];
        category.name=obj[@"name"];
        category.subArray=obj[@"subcategories"];
        [self.categoryArray addObject:category];
    }];
    
    MTCitiesManage *citiesManage=[MTCitiesManage shareCitiesManage];
    MTCity *city=[citiesManage cityWithName:_selectedCity];
    _regionArray=city.regionsArray;
    
    NSString *sortPath=[[NSBundle mainBundle] pathForResource:@"sorts" ofType:@"plist"];
    NSArray *sortArray=[NSArray arrayWithContentsOfFile:sortPath];
    [sortArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *label=obj[@"label"];
        if (label.length>0) {
            [self.sortArray addObject:label];
        }
    }];
    
}



- (void)setNavigationButton
{
    UIButton *leftButton=[[UIButton alloc] init];
    [leftButton addTarget:self action:@selector(tapSelectCityButton) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@"深圳" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [leftButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:MT_GLOBLE_COLOR forState:UIControlStateHighlighted];
    CGRect leftFrame=CGRectMake(0, 0, 40.f, 38);
    leftButton.frame=leftFrame;
    _leftButton=leftButton;
    UIBarButtonItem *leftBarButton=[[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *barSpacer=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barSpacer.width=-10;
    self.navigationItem.leftBarButtonItems=@[barSpacer,leftBarButton];
    
    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(mapFunction) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"icon_map"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"icon_map_highlighted"] forState:UIControlStateHighlighted];
    CGSize rightSize=rightButton.currentImage.size;
    CGRect rightFrame=CGRectMake(0, 0, rightSize.width, rightSize.height);
    rightButton.frame=rightFrame;
    UIBarButtonItem *barSpacer1=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barSpacer1.width=-10;
    UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItems=@[barSpacer1,rightBarButton];
    
    UISearchBar *searchBar=[[UISearchBar alloc] init];
    searchBar.searchBarStyle=UISearchBarStyleMinimal;
    [self setSearchBarApprence:searchBar];
    self.navigationItem.titleView=searchBar;
    searchBar.delegate=self;
    
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

- (void)setDropDownBackgroundViewHeightIsHidden:(BOOL)isHidden
{
    if (isHidden) {
        CGRect frame=_dropDownBackgroundView.frame;
        _dropDownBackgroundView.frame=CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0);
    }else{
        CGRect frame=_dropDownBackgroundView.frame;
        _dropDownBackgroundView.frame=CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, SCREEN_HEIGHT-frame.origin.y);
    }
}

#pragma mark ---set get 方法
- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading=isLoading;
    if (_isLoading) {
        [_footerView.activity startAnimating];
    }else
        [_footerView.activity stopAnimating];
}

-(NSMutableArray *)dealsArray
{
    if (!_dealsArray) {
        _dealsArray=[[NSMutableArray alloc] init];
    }
    return _dealsArray;
}

-(NSMutableArray *)categoryArray
{
    if (!_categoryArray) {
        _categoryArray=[[NSMutableArray alloc] init];
    }
    return _categoryArray;
}

-(NSMutableArray *)sortArray
{
    if (!_sortArray) {
        _sortArray=[[NSMutableArray alloc] init];
    }
    return _sortArray;
}


-(MTDropdownController *)categoryController
{
    if (!_categoryController) {
        _categoryController=[[MTDropdownController alloc] initForSingleTableVie:NO];
        _categoryController.dataSource=self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCategoryNotification:) name:MTParameterSelectedNotification object:_categoryController];
    }
    return _categoryController;
}

-(MTDropdownController *)districtController
{
    if (!_districtController) {
        _districtController=[[MTDropdownController alloc] initForSingleTableVie:NO];
        _districtController.dataSource=self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDistrictNotification:) name:MTParameterSelectedNotification object:_districtController];

    }
    return _districtController;
}

-(MTDropdownController *)sortController
{
    if (!_sortController) {
        _sortController=[[MTDropdownController alloc] initForSingleTableVie:YES];
        _sortController.subArray=_sortArray;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSortNotification:) name:MTParameterSelectedNotification object:_sortController];

    }
    return _sortController;
}

-(void)setSelectedController:(MTDropdownController *)selectedController
{
    if (!selectedController) {
        [_selectedController.view removeFromSuperview];
    }else{
        if (_selectedController) {
            [_selectedController.view removeFromSuperview];
        }
        [_dropDownBackgroundView addSubview:selectedController.view];
    }
    _selectedController=selectedController;
}

-(void)setSelectedCity:(NSString *)selectedCity
{
    _selectedCity=selectedCity;
    self.selectedCategory=nil;
    self.selectedRegion=nil;
    self.selectedSort=0;
    
    CGFloat width=[_selectedCity boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0]} context:nil].size.width;
    CGRect frame=_leftButton.frame;
    _leftButton.frame=CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height);
    [_leftButton setTitle:_selectedCity forState:UIControlStateNormal];
    
    [_categoryController resetData];
    [_districtController resetData];
    [_sortController resetData];

}

-(void)setSelectedCategory:(NSString *)selectedCategory
{
    _selectedCategory=selectedCategory;
    if (_selectedCategory) {
        [_topView.categoryButton setTitle:_selectedCategory forState:UIControlStateNormal];
    }else{
        MTCategory *category=_categoryArray[0];
        [_topView.categoryButton setTitle:category.name forState:UIControlStateNormal];
    }
}

-(void)setSelectedRegion:(NSString *)selectedRegion
{
    _selectedRegion=selectedRegion;
    if (_selectedRegion) {
        [_topView.districtButton setTitle:_selectedRegion forState:UIControlStateNormal];
    }else{
        if (_regionArray.count>0) {
            MTRegion *region=_regionArray[0];
            [_topView.districtButton setTitle:region.name forState:UIControlStateNormal];
            return;
        }
        [_topView.districtButton setTitle:@"全部" forState:UIControlStateNormal];
        
    }
}

-(void)setSelectedSort:(int)selectedSort
{
    _selectedSort=selectedSort;
    NSString *sortString=_sortArray[_selectedSort];
    [_topView.sortButton setTitle:sortString forState:UIControlStateNormal];

}

#pragma mark --parameter seleted notification

- (void)selectedCityNotification:(NSNotification *)note
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSDictionary *dic=note.userInfo;
    if (!dic) {
        return;
    }

    MTCity *city=dic[@"city"];
    if ([city.name isEqualToString:_selectedCity]) {
        return;
    }
    _regionArray=city.regionsArray;
    self.selectedCity=city.name;
    [self loadNewData];
}

-(void)receiveCategoryNotification:(NSNotification *)note
{
    NSDictionary *dic=note.userInfo;
    NSString *name=dic[@"name"];
    if ([_topView.categoryButton.titleLabel.text isEqualToString:name]) {
        self.selectedButton.selected=NO;
        self.selectedButton=nil;
        self.selectedController=nil;
        [self setDropDownBackgroundViewHeightIsHidden:YES];
        return;
    }
    _selectedCategory=name;
    [self.selectedButton setTitle:name forState:UIControlStateNormal];
    
    self.selectedButton.selected=NO;
    self.selectedButton=nil;
    self.selectedController=nil;
    [self setDropDownBackgroundViewHeightIsHidden:YES];
    [self loadNewData];
}

-(void)receiveDistrictNotification:(NSNotification *)note
{
    NSDictionary *dic=note.userInfo;
    NSString *name=dic[@"name"];
    if ([_topView.districtButton.titleLabel.text isEqualToString:name]) {
        self.selectedButton.selected=NO;
        self.selectedButton=nil;
        self.selectedController=nil;
        [self setDropDownBackgroundViewHeightIsHidden:YES];
        return;
    }
    self.selectedRegion=name;
    self.selectedButton.selected=NO;
    self.selectedButton=nil;
    self.selectedController=nil;
    [self setDropDownBackgroundViewHeightIsHidden:YES];
    [self loadNewData];
}

-(void)receiveSortNotification:(NSNotification *)note
{
    NSDictionary *dic=note.userInfo;
    NSIndexPath *indexPath=dic[@"subSelectedIdexPath"];
    if (self.selectedSort==indexPath.row) {
        self.selectedButton.selected=NO;
        self.selectedButton=nil;
        self.selectedController=nil;
        [self setDropDownBackgroundViewHeightIsHidden:YES];
        return;
    }
    self.selectedSort=(int)indexPath.row;
    
    self.selectedButton.selected=NO;
    self.selectedButton=nil;
    self.selectedController=nil;
    [self setDropDownBackgroundViewHeightIsHidden:YES];
    [self loadNewData];
}

#pragma mark ---navigationBar button selector
-(void)tapSelectCityButton
{
    if (_selectedButton) {
        _selectedButton.selected=NO;
//        self.selectedButton=nil;
        self.selectedController=nil;
        [self setDropDownBackgroundViewHeightIsHidden:YES];
    }
    MTCityViewController *cityViewController=[[MTCityViewController alloc] init];
    MTNavigationController *nvc=[[MTNavigationController alloc] initWithRootViewController:cityViewController];
    nvc.modalPresentationStyle=UIModalPresentationPageSheet;
    [self presentViewController:nvc animated:YES completion:nil];
}

-(void)mapFunction
{
    MTMapViewController *mvc=[[MTMapViewController alloc] init];
    mvc.selectedCity=_selectedCity;
    [self presentViewController:mvc animated:YES completion:nil];
}

#pragma mark ---点评API交互
- (void)loadDataWithPage:(NSUInteger)page
{
    DPAPI *api=[[DPAPI alloc] init];
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    params[@"limit"]=@(limitNum);
    params[@"city"]=_selectedCity;
    if (self.selectedCategory && ![_selectedCategory isEqualToString:@"全部分类"]) {
        params[@"category"]=_selectedCategory;
    }
    
    if (self.selectedRegion && ![_selectedRegion isEqualToString:@"全部"]) {
        params[@"region"]=_selectedRegion;
    }
    
    if (self.selectedSort) {
        params[@"sort"]=@(_selectedSort+1);
    }
    
    params[@"page"]=@(page);
    NSLog(@"%@",params.description);
    
    _lastRequest=[api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];
    
}

- (void)loadNewData
{
    if (_dealsArray.count==0) {
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    [_refreshControl beginRefreshing];
//    self.tableView.contentInset=UIEdgeInsetsMake(70, 0, 0, 0);
    self.currentPage=1;
    [self loadDataWithPage:1];
    _isNewRequest=YES;
}


- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (request!=_lastRequest) {
        return;
    }
    [_refreshControl endRefreshing];
    self.isLoading=NO;
    NSUInteger totleCount=[result[@"total_count"] integerValue];
    if (totleCount==0) {
        _dealsArray=nil;
        [_tableView reloadData];
        _imageView.hidden=NO;
        return;
    }
    _imageView.hidden=YES;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    if (_currentPage==1) {
        [self.dealsArray removeAllObjects];
        _isNewRequest=NO;
        _footerView.hidden=NO;
    }
    NSArray *resultArray=result[@"deals"];
    
    [resultArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
        MTDeal *deal=[[MTDeal alloc] initWithDic:dic];
        [self.dealsArray addObject:deal];
    }];
    if (self.dealsArray.count==totleCount) {
        self.isAllLoaded=YES;
    }
    [self.tableView reloadData];
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    [_refreshControl endRefreshing];
    if (_currentPage!=1) {
        _isNewRequest=NO;
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


#pragma mark ---tapTopViewButton

- (void)tapCategoryButton:(UIButton *)sender
{
    sender.selected=!sender.isSelected;
    
    if (sender.selected) {
        _selectedButton.selected=NO;
        _selectedButton=sender;
        if (self.selectedController!=nil) {
            self.selectedController=nil;
            [self setDropDownBackgroundViewHeightIsHidden:YES];
        }
        [self setDropDownBackgroundViewHeightIsHidden:NO];
        self.selectedController=self.categoryController;
    }else{
        _selectedButton=nil;
        self.selectedController=nil;
        [UIView animateWithDuration:0.2 animations:^{
            [self setDropDownBackgroundViewHeightIsHidden:YES];
        }];
    }
 
}

- (void)tapDistrictButton:(UIButton *)sender
{
    if (_regionArray.count==0) {
        return;
    }
    sender.selected=!sender.isSelected;
    
    if (sender.selected) {
        _selectedButton.selected=NO;
        _selectedButton=sender;
        if (self.selectedController!=nil) {
            self.selectedController=nil;
            [self setDropDownBackgroundViewHeightIsHidden:YES];
        }
        [self setDropDownBackgroundViewHeightIsHidden:NO];

        self.selectedController=self.districtController;
    }else{
        _selectedButton=nil;
        self.selectedController=nil;
        [UIView animateWithDuration:0.2 animations:^{
            [self setDropDownBackgroundViewHeightIsHidden:YES];
        }];
    }
}

- (void)tapSortButton:(UIButton *)sender
{
    sender.selected=!sender.isSelected;
    
    if (sender.selected) {
        _selectedButton.selected=NO;
        _selectedButton=sender;
        if (self.selectedController!=nil) {
            self.selectedController=nil;
            [self setDropDownBackgroundViewHeightIsHidden:YES];
        }
        [self setDropDownBackgroundViewHeightIsHidden:NO];
        self.selectedController=self.sortController;
    }else{
        _selectedButton=nil;
        self.selectedController=nil;
        [UIView animateWithDuration:0.2 animations:^{
            [self setDropDownBackgroundViewHeightIsHidden:YES];
        }];
    }
}

#pragma mark ---HideView Delegate
-(void)hideView
{
    _selectedButton.selected=NO;
    self.selectedController=nil;
    [UIView animateWithDuration:0.2 animations:^{
        [self setDropDownBackgroundViewHeightIsHidden:YES];
    }];
}

#pragma mark --dropdown dataSource
-(NSUInteger)numberOfRowsInMainOfDropdownController:(MTDropdownController *)dropdownDoubleController
{
    if (dropdownDoubleController==_categoryController) {
        return _categoryArray.count;
    }else if(dropdownDoubleController==_districtController){
        return _regionArray.count;
    }else
        return _sortArray.count;
}

-(id<DropdownData>)itemOfMainInDropdownController:(MTDropdownController *)dropdownDoubleController WithIndex:(NSUInteger)index
{
    if (dropdownDoubleController==_categoryController) {
        return _categoryArray[index];
    }else if (dropdownDoubleController==_districtController) {
        if (_regionArray.count>0) {
            return _regionArray[index];
        }
        return nil;
    }else
        return _sortArray[index];
}

#pragma mark <UITableViewDataSource>
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return self.dealsArray.count;
    }else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        MTHomeTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        MTDeal *deal=self.dealsArray[indexPath.row];
        [cell setDeal:deal];
        return cell;
    }else
        return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==1) {
        return _footerView;
    }else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!_isAllLoaded && section==1) {
        return 30;
    }
    return 0;
}

#pragma mark <UITableViewDelegate>
/*取消cell左边的缩进*/
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTDealDetailViewController *mvc=[MTDealDetailViewController new];
    [mvc setupDeals:_dealsArray[indexPath.row]];
    [self.navigationController pushViewController:mvc animated:YES];
}



#pragma mark <UIScrollViewDelegate>
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_isAllLoaded || _isNewRequest) {
        return;
    }
    if (scrollView.contentSize.height-scrollView.contentOffset.y<scrollView.frame.size.height-30 && !_isLoading) {
        _footerView.label.text=@"加载中";
        self.currentPage++;
        [self loadDataWithPage:_currentPage];
        self.isLoading=YES;
    }else if (scrollView.contentSize.height-scrollView.contentOffset.y>scrollView.frame.size.height-30 && !_isLoading)
    {
        _footerView.label.text=@"上拉加载更多";
    }
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isAllLoaded || _isNewRequest) {
        return;
    }
    if (scrollView.contentSize.height-scrollView.contentOffset.y<scrollView.frame.size.height-30 &&!_isLoading) {
        _footerView.label.text=@"松开加载更多";
    }else if (scrollView.contentSize.height-scrollView.contentOffset.y>scrollView.frame.size.height-30 &&!_isLoading){
        _footerView.label.text=@"上拉加载更多";
    }
    if (_isLoading) {
        _footerView.label.text=@"加载中";
    }
    
}

#pragma mark <UISearchBarDelegate>


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    MTDealSearchViewController *dvc=[[MTDealSearchViewController alloc] init];
    dvc.city=self.selectedCity;
    [self.navigationController pushViewController:dvc animated:YES];
    return NO;
}

#pragma mark ---set menu & awesomeMenu delegate

- (void)setAwesomeMenu
{
    UIImage *backgroundImage=[UIImage imageNamed:@"bg_pathMenu_black_normal"];
    UIImage *backgroundHightlightImage=[UIImage imageNamed:@"icon_pathMenu_background_normal"];
    AwesomeMenuItem *item1=[[AwesomeMenuItem alloc] initWithImage:backgroundImage
                                                 highlightedImage:nil
                                                     ContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_normal"]
                                          highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_highlighted"]];
    
    AwesomeMenuItem *item2=[[AwesomeMenuItem alloc] initWithImage:backgroundImage
                                                 highlightedImage:nil
                                                     ContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_normal"]
                                          highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_highlighted"]];
    
    AwesomeMenuItem *item3=[[AwesomeMenuItem alloc] initWithImage:backgroundImage
                                                 highlightedImage:nil
                                                     ContentImage:[UIImage imageNamed:@"icon_pathMenu_more_normal"]
                                          highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_more_highlighted"]];
    
    AwesomeMenuItem *startItem=[[AwesomeMenuItem alloc] initWithImage:backgroundHightlightImage
                                                     highlightedImage:nil
                                                         ContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_normal"]
                                              highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_highlighted"]];
    
    AwesomeMenu *awesomeMenu=[[AwesomeMenu alloc] initWithFrame:CGRectZero startItem:startItem menuItems:@[item1,item2,item3]];
    awesomeMenu.startPoint=CGPointMake(20, 180);
    awesomeMenu.rotateAddButton=NO;
    awesomeMenu.menuWholeAngle=M_PI_2;
    awesomeMenu.alpha=0.5;
    awesomeMenu.delegate=self;
    [self.view addSubview:awesomeMenu];
    [awesomeMenu autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [awesomeMenu autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    [awesomeMenu autoSetDimensionsToSize:CGSizeMake(200, 200)];
}

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    
    menu.contentImage=[UIImage imageNamed:@"icon_pathMenu_mine_normal"];
    menu.alpha=0.5;
    if (idx==0) {
        MTDealCollectController *vc=[[MTDealCollectController alloc] init];
        MTNavigationController *nvc=[[MTNavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:nil];
    }
    
    if (idx==1 || idx==2) {
        [self alertWithTitle:@"暂无此功能"];
    }
    
}

- (void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu
{
    menu.contentImage=[UIImage imageNamed:@"icon_pathMenu_cross_normal"];
    menu.alpha=0.9;
}
- (void)awesomeMenuWillAnimateClose:(AwesomeMenu *)menu
{
    menu.contentImage=[UIImage imageNamed:@"icon_pathMenu_mine_normal"];
    menu.alpha=0.5;
}

#pragma mark ---Handle RefreshControl

- (void)handleRefresh
{
    
    [self loadNewData];
}

#pragma mark ---Alert Controller
- (void)alertWithTitle:(NSString *)title
{
    UIAlertAction *alertAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark --私有方法
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MTParameterSelectedNotification object:_categoryController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MTParameterSelectedNotification object:_districtController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MTParameterSelectedNotification object:_sortController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MTCitySelectedNotification object:nil];

}

@end
