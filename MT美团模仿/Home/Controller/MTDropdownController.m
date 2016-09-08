//
//  MTDropdownDoubleController.m
//  MT美团模仿
//
//  Created by Nico on 16/8/27.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDropdownController.h"
#import "MTDropDownTableViewCell.h"
#import "MTConst.h"
@interface MTDropdownController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UITableView *subTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainTableViewWidthConstraint;
@property (assign, nonatomic) BOOL isSingleTableView;
@property (strong, nonatomic)NSIndexPath *mainSelectedIndexpath;
@property (strong, nonatomic)NSIndexPath *subSelectedIndexpath;

@end

@implementation MTDropdownController


NSString *const mainIdentifier=@"mainCell";
NSString *const subIdentifier=@"subCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainTableView.dataSource=self;
    self.mainTableView.delegate=self;
    self.subTableView.dataSource=self;
    self.subTableView.delegate=self;
    
    NSUInteger count;
    if (_isSingleTableView) {
        [self hideMainTableView];
        count=self.subArray.count;
    }else
        count=[self tableView:self.mainTableView numberOfRowsInSection:0];
    CGFloat height=44.0*count>520?520:44.0*count;
    self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, height);
}



#pragma mark --tableView dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==_mainTableView) {
        return [self.dataSource numberOfRowsInMainOfDropdownController:self];
    }else
        return _subArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTDropDownTableViewCell *cell=nil;
    if (tableView==_mainTableView) {
        cell=[MTDropDownTableViewCell cellForTableView:tableView withIdentifier:mainIdentifier];
        
        cell.textLabel.text=[[self.dataSource itemOfMainInDropdownController:self WithIndex:indexPath.row] name];
        NSArray *subArray=[[self.dataSource itemOfMainInDropdownController:self WithIndex:indexPath.row] subArray];
        if (subArray) {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }else{
        cell=[MTDropDownTableViewCell cellForTableView:tableView withIdentifier:subIdentifier];
        cell.textLabel.text=self.subArray[indexPath.row];
        cell.imageView.image=[UIImage imageNamed:@"bg_login_textfield"];
        cell.imageView.highlightedImage=[UIImage imageNamed:@"ic_choosed"];
    }
    return cell;
}

#pragma mark --tableView delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==_mainTableView) {
        self.subArray=[[self.dataSource itemOfMainInDropdownController:self WithIndex:indexPath.row] subArray];
        _mainSelectedIndexpath=indexPath;
        if (self.subArray.count>0) {
        }else
        {
            NSString *name=[[self.dataSource itemOfMainInDropdownController:self WithIndex:indexPath.row] name];
            NSDictionary *dic=@{@"name":name,
                                @"mainSeletedIndexPath":_mainSelectedIndexpath
                                };
            [[NSNotificationCenter defaultCenter] postNotificationName:MTParameterSelectedNotification object:self userInfo:dic];
        }
        [self.subTableView reloadData];
    }else{
        _subSelectedIndexpath=indexPath;
        NSString *name=_subArray[indexPath.row];
        NSDictionary *dic=nil;
        if (!_isSingleTableView) {
            if (indexPath.row==0) {
                name=[[self.dataSource itemOfMainInDropdownController:self WithIndex:_mainSelectedIndexpath.row] name];
            }
            dic=@{@"name":name,
            @"mainSeletedIndexPath" : _mainSelectedIndexpath,
            @"subSelectedIdexPath" : _subSelectedIndexpath
                };
        }else
            dic=@{@"name":name,
                  @"subSelectedIdexPath" : _subSelectedIndexpath
                  };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MTParameterSelectedNotification object:self userInfo:dic];
    }
    
}

#pragma mark ---公共接口

-(void)hideMainTableView
{
    self.mainTableViewWidthConstraint.constant=0;
}

- (instancetype)initForSingleTableVie:(BOOL)isSingleTableView
{
    if (self=[super init]) {
        _isSingleTableView=isSingleTableView;
    }
    return self;
}

- (void)resetData
{
    [self.mainTableView reloadData];
    [self.subTableView reloadData];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    if (!_isSingleTableView) {
        [self.mainTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        if ([[self.dataSource itemOfMainInDropdownController:self WithIndex:indexPath.row] subArray].count>0) {
            [self tableView:self.mainTableView didSelectRowAtIndexPath:indexPath];
        }

    }
    if (_subArray.count>0) {
        [self.subTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

@end
