//
//  MTHomeTableViewCell.m
//  MT美团模仿
//
//  Created by Nico on 16/9/1.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTHomeTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MTDeal.h"
@interface MTHomeTableViewCell()
@property (strong,nonatomic)MTDeal *deal;
@end

@implementation MTHomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
