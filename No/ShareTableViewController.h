//
//  ShareTableViewController.h
//  No
//
//  Created by Chris Roche on 6/20/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareTableViewController : UITableViewController

@property (strong, nonatomic, readonly) NSMutableArray *cellTitles;
@property (strong, nonatomic) NSString *userName;

@end
