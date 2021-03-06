//
//  NoViewController.m
//  No
//
//  Created by Chris Roche on 6/22/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import "NoViewController.h"
#import "ShareTableViewController.h"

#import "ShareViewController.h"

#import "CustomButton.h"
#import "SlideTableViewCell.h"

#import <MessageUI/MessageUI.h>
#import <iAd/iAd.h>

typedef void(^myCompletion)(BOOL);

@interface NoViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, ShareTableViewControllerDelegate, ADBannerViewDelegate, ShareViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (strong, nonatomic, readwrite) NSMutableArray *cellTitles;
@property (strong, nonatomic) NSMutableArray *blockedUsers;

@property (strong, nonatomic) UITextField *addTextField;
//@property (strong, nonatomic) UIButton *shareButton;

@property (strong, nonatomic) UITableViewCell *slideCell;
@property (strong, nonatomic) UITableViewCell *optionsCell;
@property (strong, nonatomic) UITableViewCell *swipedCell;

@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *middleButton;
@property (strong, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *blockButton;

@property (strong, nonatomic) NSString *shareURL;

@property (strong, nonatomic) PFUser *userID;


- (IBAction)shareButtonPressed:(UIButton *)sender;

//@property (strong, nonatomic) UIView *contentView;
//@property (strong, nonatomic) ADBannerView *adBannerView;
//@property (nonatomic) BOOL adBannerViewIsVisible;

@end

@implementation NoViewController
{
    CGPoint touchLocation;
    
    __block BOOL isBLocked;
    BOOL friendCellRemoved;
}

-(NSMutableArray *)cellTitles
{
    if (!_cellTitles)
    {
        _cellTitles = [NSMutableArray arrayWithCapacity: 10];
    }
    
    return _cellTitles;
}

-(NSMutableArray *)blockedUsers
{
    if (!_blockedUsers)
    {
        _blockedUsers = [[NSMutableArray alloc] init];
    }
    
    return _blockedUsers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    [PFAnalytics trackEvent:@"noViewController Opened"];
    
    [self queryForShareURL];
    
    //self.canDisplayBannerAds = YES;
    //[self loadAdBanner];

    self.slideCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    
    PFUser *user = [PFUser currentUser];
    if (user)
    {
        self.userID = user;
    }
    else
    {
        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"];
        
        [PFUser logInWithUsernameInBackground:userName password:password block:^(PFUser *user, NSError *error) {
            if (user)
            {
                self.userID = user;
            }
            else
            {
                NSLog(@"error: %@", error);
            }
        }];
    }
    
    
    //self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:169.0/255 green:67.0/255 blue:181.0/255 alpha:1.0];
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeGestureRecognizer];
}

-(void)dealloc
{
    NSLog(@"dealloc %@", self);
}

-(void)viewWillAppear:(BOOL)animated
{
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"cellTitles"])
    {
        self.cellTitles = [@[@"FIND FRIENDS", @"INVITE", @"+"] mutableCopy];
        [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        self.cellTitles = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"cellTitles"]];
    }
    
    self.blockedUsers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"blockedUsers"]];
    friendCellRemoved = [[NSUserDefaults standardUserDefaults] boolForKey:@"FriendCellRemoved"];
    
    [super viewWillAppear:animated];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillLayoutSubviews
{
    //self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 75, self.view.bounds.size.height - 75, 50.0, 50.0)];
    //[self.shareButton setTitle:@"Share" forState:UIControlStateNormal];
    //[self.shareButton setImage:[UIImage imageNamed:@"addthis500"] forState:UIControlStateNormal];
    //[self.shareButton addTarget:self action:@selector(toShareButton:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:self.shareButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toShareVC"])
    {
        ShareViewController *controller = segue.destinationViewController;
        controller.userID =self.userID;
        controller.delegate = self;
        controller.noVC = self;
        controller.shareURL = self.shareURL;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cellTitles count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowColorNumber;
    for (int i = 0; i < 8; i++)
    {
        rowColorNumber = indexPath.row % 8;
        
        switch (rowColorNumber) {
            case 0:
                cell.backgroundColor = [UIColor colorWithRed:0.0/255 green:199.0/255 blue:166.0/255 alpha:1.0];
                break;
                
            case 1:
                cell.backgroundColor = [UIColor colorWithRed:0.0/255 green:230.0/255 blue:124.0/255 alpha:1.0];
                break;
                
            case 2:
                cell.backgroundColor = [UIColor colorWithRed:12.0/255 green:155.0/255 blue:225.0/255 alpha:1.0];
                break;
                
            case 3:
                cell.backgroundColor = [UIColor colorWithRed:48.0/255 green:72.0/255 blue:93.0/255 alpha:1.0];
                break;
                
            case 4:
                cell.backgroundColor = [UIColor colorWithRed:0.0/255 green:167.0/255 blue:137.0/255 alpha:1.0];
                break;
                
            case 5:
                cell.backgroundColor = [UIColor colorWithRed:246.0/255 green:199.0/255 blue:0.0/255 alpha:1.0];
                break;
                
            case 6:
                cell.backgroundColor = [UIColor colorWithRed:68.0/255 green:112.0/255 blue:202.0/255 alpha:1.0];
                break;
                
            case 7:
                cell.backgroundColor = [UIColor colorWithRed:169.0/255 green:67.0/255 blue:181.0/255 alpha:1.0];
                break;
        }

    }
}


- (SlideTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"NoCell";
    SlideTableViewCell *cell = (SlideTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[SlideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.cellTitles[indexPath.row];
    cell.textLabel.alpha = 1.0;


    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get current cell being interacted with
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];

    //if Invite cell
    if (indexPath.row == [self.cellTitles count] - 2)
    {
        
        //add new cell offscreen
        self.slideCell = [[UITableViewCell alloc] init];
        self.slideCell.frame = CGRectMake(-self.view.bounds.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        [self.tableView addSubview:self.slideCell];
        
        //add Mail button
        self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x - self.slideCell.frame.size.width , self.slideCell.bounds.origin.y, self.slideCell.frame.size.width / 3, self.slideCell.frame.size.height)];
        self.leftButton.backgroundColor = [UIColor colorWithRed:68.0/255 green:112.0/255 blue:202.0/255 alpha:1.0];
        [self.leftButton addTarget:self action:@selector(mail) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *leftButtonTitle = [[NSAttributedString alloc] initWithString:@"MAIL" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:30]}];
        [self.leftButton setAttributedTitle:leftButtonTitle forState:UIControlStateNormal];
        self.leftButton.alpha = 0.0;
        [self.slideCell addSubview:self.leftButton];
        
        //add Twitter button
        self.middleButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x - (self.slideCell.frame.size.width / 3) * 2, self.slideCell.bounds.origin.y, self.slideCell.frame.size.width / 3, self.slideCell.frame.size.height)];
        self.middleButton.backgroundColor = [UIColor colorWithRed:169.0/255 green:67.0/255 blue:181.0/255 alpha:1.0];
        [self.middleButton addTarget:self action:@selector(postToTwitter) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *middleButtonTitle = [[NSAttributedString alloc] initWithString:@"TWTR" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:30]}];
        [self.middleButton setAttributedTitle:middleButtonTitle forState:UIControlStateNormal];
        self.middleButton.alpha = 0.0;
        [self.slideCell addSubview:self.middleButton];
        
        //add Facebook button
        self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x - self.slideCell.frame.size.width / 3, self.slideCell.bounds.origin.y, self.slideCell.frame.size.width / 3, self.slideCell.frame.size.height)];
        self.rightButton.backgroundColor = [UIColor colorWithRed:255.0/255 green:55.0/255 blue:61.0/255 alpha:1.0];
        [self.rightButton addTarget:self action:@selector(postToFacebook) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *rightButtonTitle = [[NSAttributedString alloc] initWithString:@"FCBK" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:30]}];
        [self.rightButton setAttributedTitle:rightButtonTitle forState:UIControlStateNormal];
        self.rightButton.alpha = 0.0;
        [self.slideCell addSubview:self.rightButton];
        
        //animate new cell onscreen and old cell off
        [UIView animateWithDuration:0.3 animations:^{
            self.slideCell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
            
            self.leftButton.frame = CGRectMake(self.slideCell.frame.origin.x, self.slideCell.bounds.origin.y, self.leftButton.frame.size.width, self.leftButton.frame.size.height);
            
            self.middleButton.frame = CGRectMake(self.slideCell.frame.origin.x + self.middleButton.frame.size.width, self.slideCell.bounds.origin.y, self.middleButton.frame.size.width, self.middleButton.frame.size.height);
            
            self.rightButton.frame = CGRectMake(self.slideCell.frame.origin.x + self.rightButton.frame.size.width * 2, self.slideCell.bounds.origin.y, self.rightButton.frame.size.width, self.rightButton.frame.size.height);
            
            self.leftButton.alpha = 1.0;
            self.middleButton.alpha = 1.0;
            self.rightButton.alpha = 1.0;
            
            cell.frame = CGRectMake(self.view.frame.size.width + 1, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
            cell.alpha = 0.5;
        }];
        return nil;
    }
    //if add friend cell
    else if (indexPath.row == [self.cellTitles count] - 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.hidden = YES;
            
            self.addTextField = [[UITextField alloc] initWithFrame:CGRectMake(cell.bounds.origin.x + 10, cell.bounds.origin.y + 10, cell.bounds.size.width - 20, cell.bounds.size.height - 20)];
            
            NSAttributedString *textFieldPlaceholder = [[NSAttributedString alloc] initWithString:@"TYPE USERNAME TO ADD" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:20]}];
            self.addTextField.attributedPlaceholder = textFieldPlaceholder;
            
            self.addTextField.defaultTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:40]};
            self.addTextField.adjustsFontSizeToFitWidth = YES;
            self.addTextField.textAlignment = NSTextAlignmentCenter;
            self.addTextField.tintColor = [UIColor whiteColor];
            
            self.addTextField.delegate = self;
            self.addTextField.tag = indexPath.row;
            
            [cell addSubview:self.addTextField];
            
            [self.addTextField becomeFirstResponder];
            
        });
        
        return indexPath;
    }
//    else if ([self.cellTitles count] == 4 && indexPath.row == 0)
//    {
//        return indexPath;
//    }
    else if ([self.cellTitles count] >= 4 && (indexPath.row >= 0 && indexPath.row <= [self.cellTitles count] - 4))
    {
        return indexPath;
    }
    else
    {
        if (friendCellRemoved == YES)
        {
            return indexPath;
        }
        else
        {
            return nil;
        }
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if a friend exists and the user taps on a row with a friend in it
    if ([self.cellTitles count] >= 4 && (indexPath.row >= 0 && indexPath.row <= [self.cellTitles count] - 4) && friendCellRemoved == NO)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.hidden = YES;
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
        [cell addSubview:spinner];
        [spinner startAnimating];
        
        __block PFUser *user;
        NSString *userName = self.cellTitles[indexPath.row];
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:userName];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects firstObject] != nil)
            {
                user = [objects firstObject];
                NSString *string = [NSString stringWithFormat:@"user_%@", user.objectId];
                [self checkForBlockedUser:user];
                
                if ([self userBlockedCheck] == NO)
                {
                    PFUser *currentUser = [PFUser currentUser];
                    
                    PFPush *push = [[PFPush alloc] init];
                    [push setChannel:string];
                    
                    [push setMessage:[NSString stringWithFormat:@"FROM %@", currentUser.username]];
                    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded)
                        {
                            [spinner stopAnimating];
                            [spinner removeFromSuperview];
                            [UIView animateWithDuration:0.1 animations:^{
                                cell.textLabel.hidden = NO;
                                cell.textLabel.text = @"NO SENT!";
                            } completion:^(BOOL finished) {
                                NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:0];
                                [self.tableView moveRowAtIndexPath:indexPath toIndexPath:indexPath2];
                                
                                NSString *firstObject = self.cellTitles[indexPath.row];
                                [self.cellTitles removeObjectAtIndex:indexPath.row];
                                [self.cellTitles insertObject:firstObject atIndex:0];
                                
                                [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                    cell.textLabel.text = userName;
                                    [self.tableView reloadData];
                                });
                            }];
                        }
                    }];
                }
                else
                {
                    [spinner stopAnimating];
                    [spinner removeFromSuperview];
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        cell.textLabel.hidden = NO;
                        cell.textLabel.text = @"BLOCKED";
                    } completion:^(BOOL finished) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [UIView animateWithDuration:0.3 animations:^{
                                cell.textLabel.alpha = 0.0;
                            } completion:^(BOOL finished) {
                                [self.cellTitles removeObjectAtIndex:indexPath.row];
                                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                
                                [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                            }];
                        });
                    }];
                }
                
            }
            else if ([objects count] == 0)
            {
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                
                [self.cellTitles removeObjectAtIndex:indexPath.row];
                
                [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                cell.textLabel.alpha = 1.0;
                cell.textLabel.hidden = NO;
                
                [UIView animateWithDuration:1.0 animations:^{
                    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:35.0];
                    cell.textLabel.alpha = 0.0;
                    cell.textLabel.text = @"NO SUCH USER";
                } completion:^(BOOL finished) {
                    
                    [tableView beginUpdates];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];

                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        cell.textLabel.alpha = 1.0;
                         });
                }];
            }
            else
            {
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO FAILED" message:@"THERE WAS AN ERROR SENDING YOUR NO.  PLEASE TRY AGAIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
    
    else if (friendCellRemoved == YES && [self.cellTitles count] >= 3 && (indexPath.row >= 0 && indexPath.row <= [self.cellTitles count] - 3))
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.hidden = YES;
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
        [cell addSubview:spinner];
        [spinner startAnimating];
        
        __block PFUser *user;
        NSString *userName = self.cellTitles[indexPath.row];
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:userName];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects firstObject] != nil)
            {
                user = [objects firstObject];
                NSString *string = [NSString stringWithFormat:@"user_%@", user.objectId];
                [self checkForBlockedUser:user];
                
                if ([self userBlockedCheck] == NO)
                {
                    PFUser *currentUser = [PFUser currentUser];
                    
                    PFPush *push = [[PFPush alloc] init];
                    [push setChannel:string];
                    
                    [push setMessage:[NSString stringWithFormat:@"FROM %@", currentUser.username]];
                    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded)
                        {
                            [spinner stopAnimating];
                            [spinner removeFromSuperview];
                            [UIView animateWithDuration:0.1 animations:^{
                                cell.textLabel.hidden = NO;
                                cell.textLabel.text = @"NO SENT!";
                            } completion:^(BOOL finished) {
                                NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:0];
                                [self.tableView moveRowAtIndexPath:indexPath toIndexPath:indexPath2];
                                
                                NSString *firstObject = self.cellTitles[indexPath.row];
                                [self.cellTitles removeObjectAtIndex:indexPath.row];
                                [self.cellTitles insertObject:firstObject atIndex:0];
                                
                                [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                    cell.textLabel.text = userName;
                                    [self.tableView reloadData];
                                });
                            }];
                        }
                    }];
                }
                else
                {
                    [spinner stopAnimating];
                    [spinner removeFromSuperview];
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        cell.textLabel.hidden = NO;
                        cell.textLabel.text = @"BLOCKED";
                    } completion:^(BOOL finished) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [UIView animateWithDuration:0.3 animations:^{
                                cell.textLabel.alpha = 0.0;
                            } completion:^(BOOL finished) {
                                [self.cellTitles removeObjectAtIndex:indexPath.row];
                                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                
                                [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                            }];
                        });
                    }];
                }
                
            }
            else if ([objects count] == 0)
            {
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                
                [self.cellTitles removeObjectAtIndex:indexPath.row];
                
                [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                cell.textLabel.alpha = 1.0;
                cell.textLabel.hidden = NO;
                
                [UIView animateWithDuration:1.0 animations:^{
                    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:35.0];
                    cell.textLabel.alpha = 0.0;
                    cell.textLabel.text = @"NO SUCH USER";
                } completion:^(BOOL finished) {
                    
                    [tableView beginUpdates];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        cell.textLabel.alpha = 1.0;
                    });
                }];
            }
            else
            {
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO FAILED" message:@"THERE WAS AN ERROR SENDING YOUR NO.  PLEASE TRY AGAIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
    
    //if only 1 friend exists and the user taps on a row with a friend in it
//    else if ([self.cellTitles count] == 4 && indexPath.row == 0)
//    {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        cell.textLabel.hidden = YES;
//        
//        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        spinner.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
//        [cell addSubview:spinner];
//        [spinner startAnimating];
//        
//        __block PFUser *user;
//        NSString *userName = self.cellTitles[indexPath.row];
//        PFQuery *query = [PFUser query];
//        [query whereKey:@"username" equalTo:userName];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if ([objects firstObject] != nil)
//            {
//                user = [objects firstObject];
//                NSString *string = [NSString stringWithFormat:@"user_%@", user.objectId];
//                
//                [self checkForBlockedUser:user];
//                
//                if ([self userBlockedCheck] == NO)
//                {
//                     PFUser *currentUser = [PFUser currentUser];
//                     
//                     PFPush *push = [[PFPush alloc] init];
//                     [push setChannel:string];
//                     [push setMessage:[NSString stringWithFormat:@"FROM %@", currentUser.username]];
//                     [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                         if (succeeded)
//                         {
//                             [spinner stopAnimating];
//                             [spinner removeFromSuperview];
//                             [UIView animateWithDuration:0.1 animations:^{
//                                 cell.textLabel.hidden = NO;
//                                 cell.textLabel.text = @"NO SENT!";
//                             } completion:^(BOOL finished) {
//                                 NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:0];
//                                 [self.tableView moveRowAtIndexPath:indexPath toIndexPath:indexPath2];
//                                 
//                                 NSString *firstObject = self.cellTitles[indexPath.row];
//                                 [self.cellTitles removeObjectAtIndex:indexPath.row];
//                                 [self.cellTitles insertObject:firstObject atIndex:0];
//                                 
//                                 [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
//                                 [[NSUserDefaults standardUserDefaults] synchronize];
//                                 
//                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                                     cell.textLabel.text = userName;
//                                     [self.tableView reloadData];
//                                 });
//                             }];
//                         }
//                     }];
//
//                 }
//                else
//                {
//                    [spinner stopAnimating];
//                    [spinner removeFromSuperview];
//                    
//                    [UIView animateWithDuration:0.5 animations:^{
//                        cell.textLabel.hidden = NO;
//                        cell.textLabel.text = @"BLOCKED";
//                    } completion:^(BOOL finished) {
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                            [UIView animateWithDuration:0.3 animations:^{
//                                cell.textLabel.alpha = 0.0;
//                            } completion:^(BOOL finished) {
//                                [self.cellTitles removeObjectAtIndex:indexPath.row];
//                                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                                
//                                [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
//                                [[NSUserDefaults standardUserDefaults] synchronize];
//                            }];
//                        });
//                        
//                    }];
//                }
//                            }
//            else if ([objects count] == 0)
//            {
//                [spinner stopAnimating];
//                [spinner removeFromSuperview];
//                
//                [self.cellTitles removeObjectAtIndex:indexPath.row];
//                
//                [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                
//                cell.textLabel.alpha = 1.0;
//                cell.textLabel.hidden = NO;
//                
//                [UIView animateWithDuration:1.0 animations:^{
//                    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:35.0];
//                    cell.textLabel.alpha = 0.0;
//                    cell.textLabel.text = @"NO SUCH USER";
//                } completion:^(BOOL finished) {
//                    
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                        [tableView beginUpdates];
//                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                        [tableView endUpdates];
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                            cell.textLabel.alpha = 1.0;
//                        });
//                    });
//                    
//                }];
//            }
//            else
//            {
//                [spinner stopAnimating];
//                [spinner removeFromSuperview];
//                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO FAILED" message:@"THERE WAS AN ERROR SENDING YOUR NO.  PLEASE TRY AGAIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//            }
//        }];
//    }


}

#pragma mark Social

//-(void)toShareButton:(id)sender
//{
//    [self performSegueWithIdentifier:@"toShareVC" sender:sender];
//}

- (void)postToFacebook
{
    PFUser *currentUser = [PFUser currentUser];
    NSString *postText = [NSString stringWithFormat:@"I WANNA NO YOU!\nADD MY USERNAME: %@ TO NO ME.\nGET NO: %@", currentUser.username, self.shareURL];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *fbPost = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbPost setInitialText:postText];
        [fbPost addImage:[self screenShotForSocialMedia]];
        [self presentViewController:fbPost animated:YES completion:nil];
    }
}

- (void)postToTwitter
{
    PFUser *currentUser = [PFUser currentUser];
    NSString *postText = [NSString stringWithFormat:@"I WANNA NO YOU!\nADD MY USERNAME: %@ TO NO ME.\nGET NO: %@", currentUser.username, self.shareURL];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:postText];
        [tweetSheet addImage:[self screenShotForSocialMedia]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

- (void)mail
{
    PFUser *currentUser = [PFUser currentUser];
    
    UIImage *image = [self screenShotForSocialMedia];
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(image)];
    
    NSString *subject = @"NO";
    //NSString *URL = @"www.apple.com/no";
    NSString *body = [NSString stringWithFormat:@"I WANNA NO YOU!\nADD MY NO USERNAME: %@.\n(IF YOU DON'T HAVE THE NO APP GET IT HERE: %@)", currentUser.username, self.shareURL];
    NSLog(@"shareURL in mail sheet: %@", self.shareURL);
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:subject];
    [mailController setMessageBody:body isHTML:NO];
    [mailController addAttachmentData:data mimeType:@"image/png" fileName:@"NO"];
    
    [self presentViewController:mailController animated:YES completion:nil];
    
}

- (void)queryForShareURL
{

    __block NSString *URL = [[NSString alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"AppURL"];
    [query whereKeyExists:@"itunesURL"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects)
        {
            NSLog(@"shareURL found");
            PFObject *object = [objects firstObject];
            URL = object[@"itunesURL"];
            NSLog(@"shareURL: %@", URL);
            self.shareURL = URL;
        }
        else
        {
            URL = @"www.kpowapps.com";
            self.shareURL = URL;
        }
    }];
}

- (UIImage *)screenShotForSocialMedia
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                             withString:[string uppercaseString]];
    return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSString *rawString = [textField text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    NSRange range = [rawString rangeOfCharacterFromSet:whitespace];

    if ([trimmed length] == 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
    }
    else if (range.location != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO" message:@"PLEASE REMOVE THE SPACES FROM YOUR NAME AND TRY AGAIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        if (friendCellRemoved == NO && [self.cellTitles count] < 6)
        {
            [self queryForUser];
            NSLog(@"if");
        }
        else if (friendCellRemoved == NO && [self.cellTitles count] >= 6)
        {
            NSLog(@"else if");
            [self.cellTitles removeObjectAtIndex:[self.cellTitles count] - 3];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.cellTitles count] - 3 inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            
            friendCellRemoved = YES;
            
            [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
            [[NSUserDefaults standardUserDefaults] setBool:friendCellRemoved forKey:@"FriendCellRemoved"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self queryForUser];
        }
        else
        {
            [self queryForUser];
        }
    }
    
//    if (![textField.text isEqualToString:@""])
//    {
//            [self queryForUser];
//    }
    
    [self resetAddCell];
    
    return YES;
}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.cellTitles count] - 2 inSection:0];
    
    self.tableView.contentInset = contentInsets;
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    // commented out logic for iAds
    
//    if (self.adBannerView.bannerLoaded)
//    {
//        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 50, 0);
//        //UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.cellTitles count] - 2 inSection:0];
//        NSNumber *rate = aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
//
//        [UIView animateWithDuration:rate.floatValue animations:^{
//            self.tableView.contentInset = contentInsets;
//        }];
//        //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
//    else
//    {
//        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//        
//        NSNumber *rate = aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
//        [UIView animateWithDuration:rate.floatValue animations:^{
//            self.tableView.contentInset = contentInsets;
//            self.tableView.scrollIndicatorInsets = contentInsets;
//        }];
//    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    NSNumber *rate = aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }];
    
    
}

#pragma mark - ShareTableViewControllerDelegate

-(void)dismissAndAddUser
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.cellTitles count] - 1 inSection:0];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:
     UITableViewScrollPositionNone];
    
    [self.tableView.delegate tableView:self.tableView willSelectRowAtIndexPath:indexPath];
}

#pragma mark - MFMailComposeControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:controller completion:nil];
}

#pragma mark - AdBannerViewDelegate

//-(void)bannerViewDidLoadAd:(ADBannerView *)banner
//{
//    NSLog(@"banner ad loaded");
//    
//    [UIView animateWithDuration:0.1 animations:^{
//        self.adBannerView.frame = CGRectMake(0, self.view.frame.size.height - self.adBannerView.frame.size.height, self.adBannerView.frame.size.width, self.adBannerView.frame.size.height);
//        
//        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 50, 0);
//        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.cellTitles count] - 2 inSection:0];
//        
//        self.tableView.contentInset = contentInsets;
//        //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }];
//    
//    
//}
//
//-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
//{
//    NSLog(@"banner ad failed");
//    
//    [UIView animateWithDuration:0.1 animations:^{
//        self.adBannerView.frame = CGRectMake(0, self.view.frame.size.height, self.adBannerView.frame.size.width, self.adBannerView.frame.size.height);
//        
//        UIEdgeInsets contenInsets = UIEdgeInsetsZero;
//        self.tableView.contentInset = contenInsets;
//    }];
//}

#pragma mark - AdBanner Methods

//- (void)createAdBannerView {
//    Class classAdBannerView = NSClassFromString(@"ADBannerView");
//    if (classAdBannerView != nil) {
//        self.adBannerView = [[classAdBannerView alloc]
//                              initWithFrame:CGRectZero];
//
//        [_adBannerView setFrame:CGRectOffset([_adBannerView frame], 0,
//                                             -50)];
//        [_adBannerView setDelegate:self];
//        
//        [self.view addSubview:_adBannerView];        
//    }
//}

#pragma mark - Helper Methods

- (void)resetAddCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.addTextField.tag inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self.addTextField removeFromSuperview];
    cell.textLabel.hidden = NO;
    cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
}

- (void)queryForUser
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    NSMutableArray *friends = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"cellTitles"] mutableCopy];
    
    if (![userName isEqualToString:self.addTextField.text])
    {
        if (![friends containsObject:self.addTextField.text])
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                NSIndexPath *indexPath;
                
                if (friendCellRemoved == YES)
                {
                    indexPath = [NSIndexPath indexPathForRow:[self.cellTitles count] - 2 inSection:0];

                }
                else
                {
                    indexPath = [NSIndexPath indexPathForRow:[self.cellTitles count] - 3 inSection:0];

                }
                
                [self.cellTitles insertObject:self.addTextField.text atIndex:indexPath.row];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                
                [self.leftButton removeFromSuperview];
                [self.middleButton removeFromSuperview];
                [self.rightButton removeFromSuperview];
                
                self.slideCell.frame = CGRectMake(0, self.slideCell.frame.origin.y, self.slideCell.frame.size.width, self.slideCell.frame.size.height);
                self.slideCell = nil;
                
                [self resetAddCell];
            });
        }
        else
        {
            NSLog(@"name already exists");
        }
    }
    else
    {
        NSLog(@"that's you");
    }
}

- (void)didSwipe:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        //detect cell that user swiped and will animate off screen
        CGPoint swipeLocation = [recognizer locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
        SlideTableViewCell *swipedCell = (SlideTableViewCell *)cell;
        self.swipedCell = swipedCell;
        
        //background table cell for options buttons
        SlideTableViewCell *optionsCell = [[SlideTableViewCell alloc] init];
        optionsCell.frame = CGRectMake(self.view.bounds.size.width + 1, swipedCell.frame.origin.y, swipedCell.frame.size.width, swipedCell.frame.size.height);
        [self.tableView addSubview:optionsCell];
        
        
        //create Cancel Button
        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width + 1, optionsCell.bounds.origin.y, optionsCell.frame.size.width / 3, swipedCell.frame.size.height)];
        
        cancelButton.backgroundColor = [UIColor colorWithRed:169.0/255 green:67.0/255 blue:181.0/255 alpha:1.0];
        
        [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *cancelButtonTitle = [[NSAttributedString alloc] initWithString:@"CANCEL" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:25]}];
        [cancelButton setAttributedTitle:cancelButtonTitle forState:UIControlStateNormal];
        cancelButton.tag = swipedIndexPath.row;
        cancelButton.optionsCell = optionsCell;
        
        [optionsCell addSubview: cancelButton];
        
        //create Delete Button
        CustomButton *deleteButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width + optionsCell.frame.size.width / 3, optionsCell.bounds.origin.y, cancelButton.frame.size.width, optionsCell.frame.size.height)];
        deleteButton.backgroundColor = [UIColor colorWithRed:68.0/255 green:112.0/255 blue:202.0/255 alpha:1.0];
        [deleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        
        NSAttributedString *deleteButtonTitle = [[NSAttributedString alloc] initWithString:@"DELETE" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:25]}];
        [deleteButton setAttributedTitle:deleteButtonTitle forState:UIControlStateNormal];
        deleteButton.tag = swipedIndexPath.row;
        deleteButton.optionsCell = optionsCell;
        [optionsCell addSubview:deleteButton];
        
        //create Block Button
        CustomButton *blockButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width + (cancelButton.frame.size.width * 2), optionsCell.bounds.origin.y, cancelButton.frame.size.width, cancelButton.frame.size.height)];
        blockButton.backgroundColor = [UIColor colorWithRed:255.0/255 green:55.0/255 blue:61.0/255 alpha:1.0];
        
        [blockButton addTarget:self action:@selector(block:) forControlEvents:UIControlEventTouchUpInside];
        
        NSAttributedString *blockButtonTitle = [[NSAttributedString alloc] initWithString:@"BLOCK" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:25]}];
        [blockButton setAttributedTitle:blockButtonTitle forState:UIControlStateNormal];
        
        blockButton.tag = swipedIndexPath.row;
        blockButton.optionsCell = optionsCell;
        [optionsCell addSubview:blockButton];
        
        //for use in button target action
        swipedCell.cancelButton = cancelButton;
        
        //animate cell and button on screen state
        [UIView animateWithDuration:0.3 animations:^{
            
            optionsCell.frame = CGRectMake(self.view.bounds.origin.x, swipedCell.frame.origin.y, optionsCell.frame.size.width, optionsCell.frame.size.height);
            
            cancelButton.frame = CGRectMake(self.view.bounds.origin.x, optionsCell.bounds.origin.y, cancelButton.frame.size.width, swipedCell.frame.size.height);
            
            deleteButton.frame = CGRectMake(self.view.bounds.origin.x + cancelButton.frame.size.width, swipedCell.bounds.origin.y, deleteButton.frame.size.width, deleteButton.frame.size.height);
            
            blockButton.frame = CGRectMake(self.view.bounds.origin.x + (cancelButton.frame.size.width * 2), blockButton.bounds.origin.y, blockButton.frame.size.width, blockButton.frame.size.height);
            
            swipedCell.frame = CGRectMake(-swipedCell.frame.size.width, swipedCell.frame.origin.y, swipedCell.frame.size.width, swipedCell.frame.size.height);
        }];
    }
}

- (void)block:(CustomButton *)sender
{
    SlideTableViewCell *optionsCell = sender.optionsCell;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    SlideTableViewCell *cell = (SlideTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.frame = CGRectMake(self.view.bounds.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        
        cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        optionsCell.alpha = 0.0;
        cell.cancelButton.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [cell.cancelButton removeFromSuperview];
        [optionsCell removeFromSuperview];
        
        //[self.blockedUsers addObject:cell.textLabel.text];
        [self setBlockeduser:cell.textLabel.text atIndex:sender.tag];
    }];
}

-(void)delete:(CustomButton *)sender
{
    SlideTableViewCell *optionsCell = sender.optionsCell;

    [self.cellTitles removeObjectAtIndex:sender.tag];
   
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        optionsCell.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [optionsCell removeFromSuperview];
        [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
}

- (void)cancel:(CustomButton *)sender
{
    SlideTableViewCell *optionsCell = sender.optionsCell;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    SlideTableViewCell *cell = (SlideTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.frame = CGRectMake(self.view.bounds.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        
        cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        optionsCell.alpha = 0.0;
        cell.cancelButton.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [cell.cancelButton removeFromSuperview];
        [optionsCell removeFromSuperview];
    }];
}

//- (void)loadAdBanner
//{
//    self.adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
//    self.adBannerView.frame = CGRectMake(0, self.view.frame.size.height, self.adBannerView.frame.size.width, self.adBannerView.frame.size.height);
//    self.adBannerView.delegate = self;
//    [self.view addSubview:self.adBannerView];
//}

#pragma mark - Blocked Users

- (void)setBlockeduser:(NSString *)username atIndex:(NSUInteger)index
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects)
        {
            PFUser *user = [objects firstObject];
            
            PFQuery *queryObject = [PFQuery queryWithClassName:@"Relationships"];
            [queryObject whereKey:@"user" equalTo:user];
            [queryObject findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (objects)
                {
                    PFObject *relationships = [objects firstObject];
                    
                    PFUser *currentUser = [PFUser currentUser];
                    
                    NSArray *blockedUsersOnServer = relationships[@"blockedUsers"];
                    if (![blockedUsersOnServer containsObject:currentUser.objectId])
                    {
                        [relationships addObject:currentUser.objectId forKey:@"blockedUsers"];
                        [relationships saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            
                            if (error)
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR BLOCKING USER" message:@"THERE WAS AN ERROR BLOCKING THIS USER.\nPLEASE TRY AGAIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alert show];
                            }
                            
                            else if (succeeded)
                            {
                                NSLog(@"success");
                                
                                if (![self.blockedUsers containsObject:user.username])
                                {
                                    [self.blockedUsers addObject:user.username];
                                    [[NSUserDefaults standardUserDefaults] setObject:self.blockedUsers forKey:@"blockedUsers"];
                                }
                                
                                [self.cellTitles removeObjectAtIndex:index];
                                [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
                                
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                
                                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                            }
                            
                            else
                            {
                                NSLog(@"else");
                            }
                        }];
                    }
                    
                    else
                    {
                        NSArray *blockedUsers = [[NSUserDefaults standardUserDefaults] arrayForKey:@"blockedUsers"];
                        
                        if (![blockedUsers containsObject:user.username])
                        {
                            [self.blockedUsers addObject:user.username];
                            [[NSUserDefaults standardUserDefaults] setObject:self.blockedUsers forKey:@"blockedUsers"];
                        }
                        else
                        {
                            NSLog(@"user already blocked");
                        }
                        
                        [self.cellTitles removeObjectAtIndex:index];
                        [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        
                        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            }];
        }
        
        else
        {
            NSLog(@"error %@", error);
        }
    }];
}

- (void)checkForBlockedUser:(PFUser *)user
{
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Relationships"];
    [query whereKey:@"user" equalTo:currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects)
        {
            NSLog(@"objects found for block");
            PFObject *relationships = [objects firstObject];
            NSArray *array = relationships[@"blockedUsers"];
            if ([array containsObject:user.objectId])
            {
                isBLocked = YES;
            }
            else
            {
                isBLocked = NO;
            }
        }
        else if (error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR SENDING MESSAGE" message:@"THERE WAS AN ERROR SENDING YOUR MESSAGE.\nPLEASE TRY AGAIN" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            isBLocked = YES;
        }
        else
        {
            isBLocked = NO;
        }
    }];
}

- (BOOL)userBlockedCheck
{
    if (isBLocked) {
        return YES;
    }
    else
    {
        return NO;
    }
}




- (BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark - IBActions

- (IBAction)shareButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"toShareVC" sender:sender];
}


















@end
