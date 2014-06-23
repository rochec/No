//
//  NoViewController.m
//  No
//
//  Created by Chris Roche on 6/22/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import "NoViewController.h"
#import "ShareTableViewController.h"

@interface NoViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ShareTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic, readwrite) NSMutableArray *cellTitles;
@property (strong, nonatomic) UITextField *addTextField;
@property (strong, nonatomic) UIButton *shareButton;

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
    
    self.cellTitles = [@[self.userID.username, @"FIND FREINDS", @"INVITE", @"+"] mutableCopy];
    
    //[self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
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
    switch (indexPath.row) {
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
            
        default:
            cell.backgroundColor = [UIColor redColor];
            break;
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
//    
//    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:40];
    
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
    if (indexPath.row == [self.cellTitles count] - 2)
    {
        //get current cell
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        //add new cell offscreen
        UITableViewCell *slideCell = [[UITableViewCell alloc] init];
        slideCell.frame = CGRectMake(-self.view.bounds.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        [self.tableView addSubview:slideCell];
        
        NSLog(@"cell y: %f", cell.frame.origin.y);
        NSLog(@"slideCell y: %f", slideCell.frame.origin.y);
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x - slideCell.frame.size.width , slideCell.bounds.origin.y, slideCell.frame.size.width / 3, slideCell.frame.size.height)];
        leftButton.backgroundColor = [UIColor colorWithRed:68.0/255 green:112.0/255 blue:202.0/255 alpha:1.0];
        [leftButton addTarget:self action:@selector(log) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *leftButtonTitle = [[NSAttributedString alloc] initWithString:@"SMS" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:30]}];
        [leftButton setAttributedTitle:leftButtonTitle forState:UIControlStateNormal];
        leftButton.alpha = 0.0;
        [slideCell addSubview:leftButton];
        
        UIButton *middleButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x - (slideCell.frame.size.width / 3) * 2, slideCell.bounds.origin.y, slideCell.frame.size.width / 3, slideCell.frame.size.height)];
        middleButton.backgroundColor = [UIColor colorWithRed:169.0/255 green:67.0/255 blue:181.0/255 alpha:1.0];
        [middleButton addTarget:self action:@selector(postToTwitter) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *middleButtonTitle = [[NSAttributedString alloc] initWithString:@"TWTR" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:30]}];
        [middleButton setAttributedTitle:middleButtonTitle forState:UIControlStateNormal];
        middleButton.alpha = 0.0;
        [slideCell addSubview:middleButton];
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x - slideCell.frame.size.width / 3, slideCell.bounds.origin.y, slideCell.frame.size.width / 3, slideCell.frame.size.height)];
        rightButton.backgroundColor = [UIColor colorWithRed:255.0/255 green:55.0/255 blue:61.0/255 alpha:1.0];
        [rightButton addTarget:self action:@selector(postToFacebook) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *rightButtonTitle = [[NSAttributedString alloc] initWithString:@"FCBK" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:30]}];
        [rightButton setAttributedTitle:rightButtonTitle forState:UIControlStateNormal];
        rightButton.alpha = 0.0;
        [slideCell addSubview:rightButton];
        
        //animate new cell onscreen and old cell off
        [UIView animateWithDuration:0.3 animations:^{
            slideCell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
            
            leftButton.frame = CGRectMake(slideCell.frame.origin.x, slideCell.bounds.origin.y, leftButton.frame.size.width, leftButton.frame.size.height);
            
            middleButton.frame = CGRectMake(slideCell.frame.origin.x + middleButton.frame.size.width, slideCell.bounds.origin.y, middleButton.frame.size.width, middleButton.frame.size.height);
            
            rightButton.frame = CGRectMake(slideCell.frame.origin.x + rightButton.frame.size.width * 2, slideCell.bounds.origin.y, rightButton.frame.size.width, rightButton.frame.size.height);
            
            leftButton.alpha = 1.0;
            middleButton.alpha = 1.0;
            rightButton.alpha = 1.0;
            
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
    else
        return nil;
}

#pragma mark Social

-(void)toShareButton:(id)sender
{
    [self performSegueWithIdentifier:@"toShare" sender:sender];
}

- (void)postToFacebook
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *fbPost = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbPost setInitialText:@"I wanna No you!\nAdd my No username by tapping here: http://www.no.com/username"];
        [fbPost addImage:[self screenShotForSocialMedia]];
        [self presentViewController:fbPost animated:YES completion:nil];
    }
}

- (void)postToTwitter
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"I wanna No you!\nAdd my No username by tapping here: http://www.no.com/username"];
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
    
    cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    cell.textLabel.hidden = NO;
}

- (void)queryForUser
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    
    if (![userName isEqualToString:self.addTextField.text])
    {
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:self.addTextField.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects firstObject] != nil)
            {
                PFUser *user = [objects firstObject];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.cellTitles count] - 3 inSection:0];
                [self.cellTitles insertObject:user.username atIndex:indexPath.row];
                //[self.cellTitles insertObject:user.username atIndex:[self.cellTitles count] - 2];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                //[self.tableView reloadData];
            }
            else
            {
                NSLog(@"error %@", error);
            }
        }];
    }
    else
    {
        NSLog(@"that's you");
    }
    
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
