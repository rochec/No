//
//  CustomButton.h
//  No
//
//  Created by Chris Roche on 6/29/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton

@property (strong, nonatomic) UITableViewCell *slideCell;

-(id)initWithFrame:(CGRect)frame withCell:(UITableViewCell *)cell;

@end
