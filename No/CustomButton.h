//
//  CustomButton.h
//  No
//
//  Created by Chris Roche on 6/29/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SlideTableViewCell;

@interface CustomButton : UIButton

@property (strong, nonatomic) SlideTableViewCell *optionsCell;
@property (strong, nonatomic) NSIndexPath *buttonIndexPath;


@end
