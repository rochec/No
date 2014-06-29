//
//  NoViewController.m
//  No
//
//  Created by Chris Roche on 6/22/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import "NoViewController.h"
#import "ShareTableViewController.h"
#import "CustomButton.h"

typedef void(^myCompletion)(BOOL);

@interface NoViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ShareTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic, readwrite) NSMutableArray *cellTitles;
@property (strong, nonatomic) UITextField *addTextField;
@property (strong, nonatomic) UIButton *shareButton;

@property (strong, nonatomic) UITableViewCell *slideCell;
@property (strong, nonatomic) UITableViewCell *optionsCell;
@property (strong, nonatomic) UITableViewCell *swipedCell;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *middleButton;
@property (strong, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *blockButton;

@property (strong, nonatomic) PFUser *userID;

@end

@implementation NoViewController

-(NSMutableArray *)cellTitles
{
    if (!_cellTitles)
    {
        _cellTitles = [NSMutableArray arrayWithCapacity: 10];
    }
    
    return _cellTitles;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyboardNotifications];

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
    
    //self.cellTitles = [@[self.userID.username, @"FIND FREINDS", @"INVITE", @"+"] mutableCopy];

    //[@[@"FIND FREINDS", @"INVITE", @"+"] mutableCopy];
    //[self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"cellTitles"])
    {
        self.cellTitles = [@[@"FIND FREINDS", @"INVITE", @"+"] mutableCopy];
        [[NSUserDefaults standardUserDefaults] setObject:self.cellTitles forKey:@"cellTitles"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        self.cellTitles = [[NSUserDefaults standardUserDefaults] objectForKey:@"cellTitles"];

    }
    
    [super viewWillAppear:animated];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillLayoutSubviews
{
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 75, self.view.bounds.size.height - 75, 50.0, 50.0)];
    //[self.shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage imageNamed:@"addthis500"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(toShareButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toShare"])
    {
        ShareTableViewController *controller = segue.destinationViewController;
        controller.userID = self.userID;
        controller.delegate = self;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"NoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.cellTitles[indexPath.row];
    
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];


    if (indexPath.row == [self.cellTitles count] - 2)
    {
        //get current cell
        
        //add new cell offscreen
        self.slideCell = [[UITableViewCell alloc] init];
        self.slideCell.frame = CGRectMake(-self.view.bounds.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        [self.tableView addSubview:self.slideCell];
        
        NSLog(@"cell y: %f", cell.frame.origin.y);
        NSLog(@"slideCell y: %f", self.slideCell.frame.origin.y);
        
        self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x - self.slideCell.frame.size.width , self.slideCell.bounds.origin.y, self.slideCell.frame.size.width / 3, self.slideCell.frame.size.height)];
        self.leftButton.backgroundColor = [UIColor colorWithRed:68.0/255 green:112.0/255 blue:202.0/255 alpha:1.0];
        [self.leftButton addTarget:self action:@selector(log) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *leftButtonTitle = [[NSAttributedString alloc] initWithString:@"SMS" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:30]}];
        [self.leftButton setAttributedTitle:leftButtonTitle forState:UIControlStateNormal];
        self.leftButton.alpha = 0.0;
        [self.slideCell addSubview:self.leftButton];
        
        self.middleButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x - (self.slideCell.frame.size.width / 3) * 2, self.slideCell.bounds.origin.y, self.slideCell.frame.size.width / 3, self.slideCell.frame.size.height)];
        self.middleButton.backgroundColor = [UIColor colorWithRed:169.0/255 green:67.0/255 blue:181.0/255 alpha:1.0];
        [self.middleButton addTarget:self action:@selector(postToTwitter) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *middleButtonTitle = [[NSAttributedString alloc] initWithString:@"TWTR" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:30]}];
        [self.middleButton setAttributedTitle:middleButtonTitle forState:UIControlStateNormal];
        self.middleButton.alpha = 0.0;
        [self.slideCell addSubview:self.middleButton];
        
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
    else if ([self.cellTitles count] == 4 && indexPath.row == 0)
    {
        return indexPath;
    }
    else if ([self.cellTitles count] > 4 && (indexPath.row >= 0 && indexPath.row <= [self.cellTitles count] - 4))
    {
        
        return indexPath;
    }
    else
        return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cellTitles count] > 4 && (indexPath.row >= 0 && indexPath.row <= [self.cellTitles count] - 4))
    {
        NSLog(@"send push 2");
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
                
                PFUser *currentUser = [PFUser currentUser];
                
                PFPush *push = [[PFPush alloc] init];
                [push setChannel:string];
                [push setMessage:[NSString stringWithFormat:@"%@ SENT YOU A NO!", currentUser.username]];
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
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [tableView endUpdates];

                    
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                        [tableView beginUpdates];
//                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//                        [tableView endUpdates];
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        cell.textLabel.alpha = 1.0;
                         });

  //                  });
                    
                }];
            }
            else
            {
                NSLog(@"error %@", error);
                
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO FAILED" message:@"THERE WAS AN ERROR SENDING YOUR NO.  PLEASE TRY AGAIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
    
    else if ([self.cellTitles count] == 4 && indexPath.row == 0)
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
                
                PFUser *currentUser = [PFUser currentUser];
                
                PFPush *push = [[PFPush alloc] init];
                [push setChannel:string];
                [push setMessage:[NSString stringWithFormat:@"%@ SENT YOU A NO!", currentUser.username]];
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
            else if ([objects count] == 0)
            {
                NSLog(@"no user by that name");
                
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
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [tableView beginUpdates];
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [tableView endUpdates];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            cell.textLabel.alpha = 1.0;
                        });
                    });
                    
                }];
            }
            else
            {
                NSLog(@"error %@", error);
                
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO FAILED" message:@"THERE WAS AN ERROR SENDING YOUR NO.  PLEASE TRY AGAIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }


}

#pragma mark Social

-(void)toShareButton:(id)sender
{
    [self performSegueWithIdentifier:@"toShare" sender:sender];
}

- (void)postToFacebook
{
    PFUser *currentUser = [PFUser currentUser];
    NSString *postText = [NSString stringWithFormat:@"I WANNA NO YOU!\nADD MY USERNAME: %@ TO NO ME.", currentUser.username];
    
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
    NSString *postText = [NSString stringWithFormat:@"I WANNA NO YOU!\nADD MY USERNAME: %@ TO NO ME.", currentUser.username];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:postText];
        [tweetSheet addImage:[self screenShotForSocialMedia]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
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
    
    if (![textField.text isEqualToString:@""])
    {
            [self queryForUser];
    }
    
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
   
//    NSNumber *rate = aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
//    [UIView animateWithDuration:rate.floatValue animations:^{
//        self.tableView.contentInset = contentInsets;
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }];
    
    
    //scrollView.scrollIndicatorInsets = contentInsets;
    
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, self.addTextField.frame.origin) ) {
//        [self.tableView scrollRectToVisible:self.addTextField.frame animated:YES];
//    }

}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
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
    
    if (![userName isEqualToString:self.addTextField.text])
    {

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            //PFUser *user = [objects firstObject];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.cellTitles count] - 3 inSection:0];
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
        });
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
        
        CGPoint swipeLocation = [recognizer locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        UITableViewCell* swipedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
        self.swipedCell = swipedCell;
        
        self.optionsCell = [[UITableViewCell alloc] init];
        self.optionsCell.frame = CGRectMake(self.view.bounds.size.width + 1, swipedCell.frame.origin.y, swipedCell.frame.size.width, swipedCell.frame.size.height);
        [self.tableView addSubview:self.optionsCell];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width + 1, self.optionsCell.bounds.origin.y, self.optionsCell.frame.size.width / 3, swipedCell.frame.size.height)];
        
        self.cancelButton.backgroundColor = [UIColor colorWithRed:169.0/255 green:67.0/255 blue:181.0/255 alpha:1.0];
        
        [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *cancelButtonTitle = [[NSAttributedString alloc] initWithString:@"CANCEL" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:25]}];
        [self.cancelButton setAttributedTitle:cancelButtonTitle forState:UIControlStateNormal];
        
        [self.optionsCell addSubview: self.cancelButton];
        
        self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width + self.optionsCell.frame.size.width / 3, self.optionsCell.bounds.origin.y, self.cancelButton.frame.size.width, self.optionsCell.frame.size.height)];
        self.deleteButton.backgroundColor = [UIColor colorWithRed:68.0/255 green:112.0/255 blue:202.0/255 alpha:1.0];
        [self.deleteButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        NSAttributedString *deleteButtonTitle = [[NSAttributedString alloc] initWithString:@"DELETE" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:25]}];
        [self.deleteButton setAttributedTitle:deleteButtonTitle forState:UIControlStateNormal];
        [self.optionsCell addSubview:self.deleteButton];
        
        self.blockButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width + (self.cancelButton.frame.size.width * 2), self.optionsCell.bounds.origin.y, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height)];
        self.blockButton.backgroundColor = [UIColor colorWithRed:255.0/255 green:55.0/255 blue:61.0/255 alpha:1.0];
        
        [self.blockButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        NSAttributedString *blockButtonTitle = [[NSAttributedString alloc] initWithString:@"BLOCK" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:25]}];
        [self.blockButton setAttributedTitle:blockButtonTitle forState:UIControlStateNormal];
        [self.optionsCell addSubview:self.blockButton];
        
        
        [UIView animateWithDuration:0.3 animations:^{
            
            NSLog(@"swipedCell Y: %f", swipedCell.frame.origin.y);
            self.optionsCell.frame = CGRectMake(self.view.bounds.origin.x, swipedCell.frame.origin.y, self.optionsCell.frame.size.width, self.optionsCell.frame.size.height);
            NSLog(@"optionsCell Y: %f", self.optionsCell.frame.origin.y);
            self.cancelButton.frame = CGRectMake(self.view.bounds.origin.x, self.optionsCell.bounds.origin.y, self.cancelButton.frame.size.width, swipedCell.frame.size.height);
            self.deleteButton.frame = CGRectMake(self.optionsCell.frame.origin.x + self.optionsCell.frame.size.width / 3, self.optionsCell.bounds.origin.y, self.deleteButton.frame.size.width, self.deleteButton.frame.size.height);
            self.blockButton.frame = CGRectMake(self.optionsCell.frame.origin.x + (self.blockButton.frame.size.width * 2), self.blockButton.bounds.origin.y, self.blockButton.frame.size.width, self.blockButton.frame.size.height);
            
            swipedCell.frame = CGRectMake(-swipedCell.frame.size.width, swipedCell.frame.origin.y, swipedCell.frame.size.width, swipedCell.frame.size.height);
        }];
    }
}

- (void)cancel
{
    
    
    self.swipedCell.frame = CGRectMake(self.view.bounds.size.width + 1, self.swipedCell.frame.origin.y, self.swipedCell.frame.size.width, self.swipedCell.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        self.optionsCell.alpha = 0.0;
        self.swipedCell.frame = CGRectMake(self.view.bounds.origin.x, self.swipedCell.frame.origin.y, self.swipedCell.frame.size.width, self.swipedCell.frame.size.height);
        
    } completion:^(BOOL finished) {
        [self.swipedCell removeFromSuperview];
    }];
   
}

#pragma mark - Blocks

- (void)animateCell:(myCompletion) compblock
{
    compblock(YES);
}



- (void)log
{
    NSLog(@"button pressed");
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}










@end
