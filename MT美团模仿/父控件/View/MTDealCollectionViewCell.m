//
//  MTDealCollectionViewCell.m
//  MT美团模仿
//
//  Created by Nico on 16/9/2.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDealCollectionViewCell.h"
#import "MTDeal.h"
#import "UIImageView+WebCache.h"


@implementation MTDealCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDeal:(MTDeal *)deal
{
    NSURL *url=[NSURL URLWithString:deal.image_url];
    [self.contentImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    self.contentTitleLabel.text=deal.title;
    self.descriptionLabel.text=deal.dealDescription;
    NSString *listPrice=[self adjustPrice:deal.list_price.stringValue];
    self.originalPriceLabel.text=[NSString stringWithFormat:@"¥ %@",listPrice];
    
    NSString *currentPrice=[self adjustPrice:deal.current_price.stringValue];
    self.priceLabel.text=[NSString stringWithFormat:@"¥ %@",currentPrice];
    self.countLabel.text=[NSString stringWithFormat:@"已售%@",deal.purchase_count];
    
    if (deal.isEdit) {
        self.coverView.hidden=NO;
    }else
        self.coverView.hidden=YES;
    if (deal.isSelected) {
        self.selectedImageView.hidden=NO;
    }else
        self.selectedImageView.hidden=YES;
}

- (NSString *)adjustPrice:(NSString *)price
{
    NSRange range=[price rangeOfString:@"."];
    if (range.length==0) {
        return price;
    }
    NSString *decimalNum=[price substringFromIndex:range.location];
    if (decimalNum.length<=3) {
        return price;
    }else{
        NSRange adjudtRange=NSMakeRange(0, range.location+3);
        return [price substringWithRange:adjudtRange];
    }

}

@end
