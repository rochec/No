//
//  SlideTableViewCell.m
//  No
//
//  Created by Chris Roche on 6/29/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import "SlideTableViewCell.h"

@implementation SlideTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
