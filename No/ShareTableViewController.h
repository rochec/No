//
//  ShareTableViewController.h
//  No
//
//  Created by Chris Roche on 6/20/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareTableViewControllerDelegate <NSObject>

- (void)dismissAndAddUser;

@end

@interface ShareTableViewController : UITableViewController

@property (weak, nonatomic) id <ShareTableViewControllerDelegate> delegate;

@property (strong, nonatomic, readonly) NSMutableArray *cellTitles;
@property (strong, nonatomic) PFUser *userID;

@end
