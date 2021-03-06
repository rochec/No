//
//  ShareTableViewController.m
//  No
//
//  Created by Chris Roche on 6/20/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import "ShareTableViewController.h"
#import "NoViewController.h"
#import "UnblockTableViewController.h"

#import <MessageUI/MessageUI.h>
#import <iAd/iAd.h>

@interface ShareTableViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate, ADBannerViewDelegate>

@property (strong, nonatomic, readwrite) NSMutableArray *cellTitles;
@property (strong, nonatomic) UITextField *addTextField;

@property (strong, nonatomic) ADBannerView *adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

@end

@implementation ShareTableViewController
{
    CGRect _adFrame;
}

-(NSMutableArray *)cellTitles
{
    if (!_cellTitles)
    {
        _cellTitles = [NSMutableArray arrayWithCapacity: 7];
    }
    
    return _cellTitles;
}

-(void)dealloc
{
    [self.adBannerView removeFromSuperview];
    NSLog(@"dealloc %@", self);
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [PFAnalytics trackEvent:@"shareViewController Opened"];
    
    [self loadAdBanner];

//    self.adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
//    self.adBannerView.frame = CGRectMake(0, self.view.frame.size.height, self.adBannerView.frame.size.width, self.adBannerView.frame.size.height);
//    //self.tableView.tableFooterView = self.adBannerView;
//    self.adBannerView.delegate = self;
//    [self.view addSubview:self.adBannerView];
    
    //self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view.backgroundColor = [UIColor colorWithRed:169.0/255 green:67.0/255 blue:181.0/255 alpha:1.0];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    //self.tableView.editing = NO;
    
    NSInteger nosReceived = [[NSUserDefaults standardUserDefaults] integerForKey:@"nosReceived"];

    NSString *nosReceivedString = [NSString stringWithFormat:@"NO'S: %ld", nosReceived];
        
    self.cellTitles = [@[self.userID.username, @"INVITE", @"FIND FRIENDS", @"UNBLOCK", nosReceivedString, @"+", @"DONE"] mutableCopy];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toUnblock"])
    {
        UnblockTableViewController *controller = segue.destinationViewController;
        
        controller.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
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
    return 7;
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
            
        case 4:
            cell.backgroundColor = [UIColor colorWithRed:0.0/255 green:167.0/255 blue:137.0/255 alpha:1.0];
            break;
            
        case 5:
            cell.backgroundColor = [UIColor colorWithRed:246.0/255 green:199.0/255 blue:0.0/255 alpha:1.0];
            break;
            
        case 6:
            cell.backgroundColor = [UIColor colorWithRed:68.0/255 green:112.0/255 blue:202.0/255 alpha:1.0];
            break;
            
        default:
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
    if (indexPath.row == [self.cellTitles count] - 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self dismissViewControllerAnimated:YES completion:nil];
    
//            [self dismissViewControllerAnimated:YES completion:^{
//                [self.noVC loadAdBanner];
//            }];
        });
        return nil;
    }
    else if (indexPath.row == [self.cellTitles count] - 4)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"toUnblock" sender:nil];
        });
        return nil;
        
    }
    else if (indexPath.row == [self.cellTitles count] - 6)
    {
        //get current cell
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        //add new cell offscreen
        UITableViewCell *slideCell = [[UITableViewCell alloc] init];
        slideCell.frame = CGRectMake(-self.view.bounds.size.width, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        [self.view addSubview:slideCell];
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x - slideCell.frame.size.width , slideCell.bounds.origin.y, slideCell.frame.size.width / 3, slideCell.frame.size.height)];
        leftButton.backgroundColor = [UIColor colorWithRed:68.0/255 green:112.0/255 blue:202.0/255 alpha:1.0];
        [leftButton addTarget:self action:@selector(mail) forControlEvents:UIControlEventTouchUpInside];
        NSAttributedString *leftButtonTitle = [[NSAttributedString alloc] initWithString:@"MAIL" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:30]}];
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
    else if (indexPath.row == [self.cellTitles count] - 2)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
//            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//            cell.textLabel.hidden = YES;
//            
//            self.addTextField = [[UITextField alloc] initWithFrame:CGRectMake(cell.bounds.origin.x + 10, cell.bounds.origin.y + 10, cell.bounds.size.width - 20, cell.bounds.size.height - 20)];
//            
//            NSAttributedString *textFieldPlaceholder = [[NSAttributedString alloc] initWithString:@"TYPE USERNAME TO ADD" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:20]}];
//            self.addTextField.attributedPlaceholder = textFieldPlaceholder;
//            
//            self.addTextField.defaultTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:40]};
//            self.addTextField.adjustsFontSizeToFitWidth = YES;
//            self.addTextField.textAlignment = NSTextAlignmentCenter;
//            self.addTextField.tintColor = [UIColor whiteColor];
//            
//            self.addTextField.delegate = self;
//            self.addTextField.tag = indexPath.row;
//            
//            [cell addSubview:self.addTextField];
//            
//            [self.addTextField becomeFirstResponder];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate dismissAndAddUser];
            }];
            
        });
        
        return indexPath;
    }
    else
    {
        return nil;
    }
}

-(void)log
{
    NSLog(@"button pressed");
}

- (void)dismissView
{
    NSLog(@"dismiss view");
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)mail
{
    
    __block NSString *URL = [[NSString alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"AppURL"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects)
        {
            PFObject *object = [objects firstObject];
            URL = object[@"itunesURL"];
            [self presentMailSheetWithURL:URL];
        }
        else
        {
            URL = @"www.itunes.com";
            [self presentMailSheetWithURL:URL];
        }
    }];
    
    
}

- (void)presentMailSheetWithURL:(NSString *)URL
{
    PFUser *currentUser = [PFUser currentUser];
    
    UIImage *image = [self screenShotForSocialMedia];
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(image)];
    
    NSString *subject = @"NO";
    //NSString *URL = @"www.apple.com/no";
    NSString *body = [NSString stringWithFormat:@"I WANNA NO YOU!\nADD MY NO USERNAME: %@.\n(IF YOU DON'T HAVE THE NO APP GET IT HERE: %@)", currentUser.username, URL];
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:subject];
    [mailController setMessageBody:body isHTML:NO];
    [mailController addAttachmentData:data mimeType:@"image/png" fileName:@"NO"];
    
    [self presentViewController:mailController animated:YES completion:nil];
}

- (UIImage *)screenShotForSocialMedia
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.cellTitles count] - 3 inSection:0];
        [self.cellTitles insertObject:textField.text atIndex:indexPath.row];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadData];
        });
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

#pragma marki - MFMailComposeControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:controller completion:nil];
}

#pragma mark - AdBannerViewDelegate

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"banner ad loaded");
    
    if (!self.adBannerView)
    {
        self.adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        self.adBannerView.frame = CGRectMake(0, self.view.frame.size.height, self.adBannerView.frame.size.width, self.adBannerView.frame.size.height);
        //self.tableView.tableFooterView = self.adBannerView;
        self.adBannerView.delegate = self;
        [self.view addSubview:self.adBannerView];
        NSLog(@"ad created and added");
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        //self.adBannerView.frame = CGRectMake(0, self.tableView.bounds.size.height - self.adBannerView.frame.size.height, self.adBannerView.frame.size.width, self.adBannerView.frame.size.height);
        self.adBannerView.frame = CGRectMake(0, _adFrame.origin.y, self.adBannerView.frame.size.width, self.adBannerView.frame.size.height);
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 50, 0);
        
        self.tableView.contentInset = contentInsets;
    }];
    
//    if (!self.adBannerViewIsVisible) {
//        [UIView animateWithDuration:0.1 animations:^{
//            self.adBannerView.frame = CGRectMake(0, self.tableView.bounds.size.height - self.adBannerView.frame.size.height, self.adBannerView.frame.size.width, self.adBannerView.frame.size.height);
//            
//            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 50, 0);
//            
//            self.tableView.contentInset = contentInsets;
//            
//            self.adBannerViewIsVisible = YES;
//        }];
//    }
    
    
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"banner ad failed");
    
    self.adBannerViewIsVisible = NO;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.adBannerView.frame = CGRectMake(0, self.tableView.frame.size.height, self.adBannerView.frame.size.width, self.adBannerView.frame.size.height);
        NSLog(@"adBanner frame: %f", self.tableView.frame.size.height);
        
        UIEdgeInsets contenInsets = UIEdgeInsetsZero;
        self.tableView.contentInset = contenInsets;
    }];
    
    [self.adBannerView removeFromSuperview];
    self.adBannerView = nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect iAdFrame = self.adBannerView.frame;
    CGFloat newOriginY = self.tableView.contentOffset.y + self.tableView.frame.size.height - iAdFrame.size.height;
    CGRect newiAdFrame = CGRectMake(iAdFrame.origin.x, newOriginY, iAdFrame.size.width, iAdFrame.size.height);
    self.adBannerView.frame = newiAdFrame;
    
    _adFrame = newiAdFrame;
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

- (void)loadAdBanner
{
    self.adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    self.adBannerView.frame = CGRectMake(0, self.tableView.frame.size.height, self.adBannerView.frame.size.width, self.adBannerView.frame.size.height);
    self.adBannerView.delegate = self;
    [self.view addSubview:self.adBannerView];
}










@end
