//
//  CustomButton.m
//  No
//
//  Created by Chris Roche on 6/29/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withCell:nil];
}

-(id)initWithFrame:(CGRect)frame withCell:(UITableViewCell *)cell
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.slideCell = cell;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
