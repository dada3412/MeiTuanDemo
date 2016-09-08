//
//  MTCityViewController.m
//  MT美团模仿
//
//  Created by Nico on 16/8/30.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTCityViewController.h"
#import "MTConst.h"
#import "MTCitySearchController.h"
#import "UIView+AutoLayout.h"
#import "MTCitiesManage.h"


@interface MTCityViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;
@property (strong, nonatomic)NSArray *cityGroupsArray;
@property (strong, nonatomic)MTCitySearchController *citySearchController;
@property (strong, nonatomic)MTCitiesManage *citiesManage;

@end

@implementation MTCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"切换城市";
    [self setNavigationBarButton];
    [self setSearchBarApprence];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.sectionIndexColor=MT_GLOBLE_COLOR;
    self.searchBar.delegate=self;
    [self loadLocalData];
    [self.backgroundButton addTarget:self action:@selector(tapBackgroundButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (MTCitySearchController *)citySearchController
{
    if (!_citySearchController) {
        _citySearchController=[[MTCitySearchController alloc] init];
        [self.view addSubview:_citySearchController.view];
        [_citySearchController.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.searchBar withOffset:0];
        [_citySearchController.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeTop];
    }
    
    return _citySearchController;
}

- (void)tapBackgroundButton:(UIButton *)sender
{
    self.backgroundButton.hidden=YES;
    [self.searchBar resignFirstResponder];
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

- (void)setSearchBarApprence
{
    UITextField *searchField=[self.searchBar valueForKey:@"searchField"];
    if (searchField) {
        searchField.layer.cornerRadius=14.f;
        searchField.clipsToBounds=YES;
    }
    self.searchBar.tintColor=MT_GLOBLE_COLOR;
}

- (void)loadLocalData
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"cityGroups" ofType:@"plist"];
    _cityGroupsArray=[NSArray arrayWithContentsOfFile:path];
    
}

- (void)dismissCityViewController
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  --tableView delegate & dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _cityGroupsArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic=_cityGroupsArray[section];
    NSArray *citiesArray=dic[@"cities"];
    return citiesArray.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dic=_cityGroupsArray[section];
    return dic[@"title"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *const identifier=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dic=_cityGroupsArray[indexPath.section];
    NSArray *citiesArray=dic[@"cities"];
    cell.textLabel.text=citiesArray[indexPath.row];
    return cell;
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [_cityGroupsArray valueForKey:@"title"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _citiesManage=[MTCitiesManage shareCitiesManage];
    NSString *name=[self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    id city=[_citiesManage cityWithName:name];
    if (city) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MTCitySelectedNotification object:nil userInfo:@{@"city":city}];
    }
}

#pragma mark ---searchBar delegate


 - (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.backgroundButton.hidden=NO;
    searchBar.showsCancelButton=YES;
}

 - (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.backgroundButton.hidden=YES;
    searchBar.showsCancelButton=NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text=nil;
    [searchBar resignFirstResponder];
    self.backgroundButton.hidden=YES;
    searchBar.showsCancelButton=NO;
    _citySearchController.view.hidden=YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length>0) {
        self.citySearchController.view.hidden=NO;
        self.citySearchController.searchText=searchText;
    }else{
        self.citySearchController.view.hidden=YES;
    }
}

//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if (range.location>10) {
//        return NO;
//    }
//    return YES;
//}

#pragma mark ---私有接口

@end
