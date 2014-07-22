//
//  ShareViewController.h
//  No
//
//  Created by Chris Roche on 7/13/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NoViewController;


@protocol ShareViewControllerDelegate <NSObject>

- (void)dismissAndAddUser;

@end

@interface ShareViewController : UIViewController

@property (weak, nonatomic) id <ShareViewControllerDelegate> delegate;
@property (strong, nonatomic) NoViewController *noVC;

@property (strong, nonatomic, readonly) NSMutableArray *cellTitles;
@property (strong, nonatomic) PFUser *userID;

@property (strong, nonatomic) NSString *shareURL;


@end
