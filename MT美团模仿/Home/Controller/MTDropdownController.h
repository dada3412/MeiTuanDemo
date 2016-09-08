//
//  MTDropdownDoubleController.h
//  MT美团模仿
//
//  Created by Nico on 16/8/27.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTDropdownController;
@protocol DropdownData <NSObject>
- (NSString *)name;
- (NSArray *)subArray;
@end

@protocol DropdownDataSource <NSObject>
- (NSUInteger) numberOfRowsInMainOfDropdownController:(MTDropdownController *)dropdownDoubleController;
- (id<DropdownData>)itemOfMainInDropdownController:(MTDropdownController *)dropdownDoubleController WithIndex:(NSUInteger)index;
@end



@interface MTDropdownController : UIViewController
@property (nonatomic,weak)id<DropdownDataSource>dataSource;
@property (strong, nonatomic)NSArray *subArray;
- (instancetype)initForSingleTableVie:(BOOL)isSingleTableView;
- (void)resetData;
@end
