//
//  MTDealCollectionViewCell.h
//  MT美团模仿
//
//  Created by Nico on 16/9/2.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MTDeal;
@interface MTDealCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIView *coverView;

- (void)setDeal:(MTDeal *)deal;
@end
