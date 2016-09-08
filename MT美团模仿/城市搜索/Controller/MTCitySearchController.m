//
//  MTCitySearchController.m
//  MT美团模仿
//
//  Created by Nico on 16/8/30.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTCitySearchController.h"
#import "MTCity.h"
#import "MTConst.h"
#import "MTCitiesManage.h"
@interface MTCitySearchController ()
@property (strong,nonatomic)NSArray *resultArray;
@property (strong,nonatomic)MTCitiesManage *citiesManage;
@end

@implementation MTCitySearchController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setSearchText:(NSString *)searchText
{
    _searchText=[searchText copy];
    _searchText=searchText.lowercaseString;
    _searchText=[_searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains %@ or pinYin contains %@  or pinYinHead contains %@ ", _searchText, _searchText, _searchText];
    _citiesManage=[MTCitiesManage shareCitiesManage];
    _resultArray=[_citiesManage.citiesArray filteredArrayUsingPredicate:predicate];
    NSLog(@"result :%@",_resultArray.description);
    [self.tableView reloadData];
}


#pragma mark - Tableview dataSource & delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * const identifier=@"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    MTCity *city=_resultArray[indexPath.row];
    cell.textLabel.text=city.name;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"一共搜索到%lu个结果",_resultArray.count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_resultArray[indexPath.row]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MTCitySelectedNotification object:nil userInfo:@{@"city":_resultArray[indexPath.row]}];
    }
}

@end
