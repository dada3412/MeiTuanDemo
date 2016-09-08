//
//  MTDropDownTableViewCell.m
//  MT美团模仿
//
//  Created by Nico on 16/8/29.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MTDropDownTableViewCell.h"
#import "MTConst.h"
@implementation MTDropDownTableViewCell

+(instancetype) cellForTableView:(UITableView *)tableView withIdentifier:(NSString *)identifier
{
    MTDropDownTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[MTDropDownTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font=[UIFont systemFontOfSize:13.0];
        self.textLabel.highlightedTextColor=MT_GLOBLE_COLOR;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
