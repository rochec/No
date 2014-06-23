//
//  UserNameTableViewController.m
//  No
//
//  Created by Chris Roche on 6/22/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import "UserNameTableViewController.h"

@interface UserNameTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@end

@implementation UserNameTableViewController

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
    self.userNameTextField.delegate = self;
    
    self.view.backgroundColor = [UIColor colorWithRed:169.0/255 green:67.0/255 blue:181.0/255 alpha:1.0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.navigationController setNavigationBarHidden:YES];
    
    
    self.userNameTextField.borderStyle = UITextBorderStyleNone;
    NSAttributedString *textFieldPlaceholder = [[NSAttributedString alloc] initWithString:@"CHOOSE YOUR USERNAME" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:20]}];
    self.userNameTextField.attributedPlaceholder = textFieldPlaceholder;
    self.userNameTextField.tintColor = [UIColor whiteColor];

    //[self.userNameTextField becomeFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.userNameTextField becomeFirstResponder];
}

//-(void)viewWillLayoutSubviews
//{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    
//    self.userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x + 10, cell.frame.origin.y + 10, cell.frame.size.width - 20, cell.frame.size.height - 20)];
//    
//    NSAttributedString *textFieldPlaceholder = [[NSAttributedString alloc] initWithString:@"CHOOSE YOUR USERNAME" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:30]}];
//    self.userNameTextField.attributedPlaceholder = textFieldPlaceholder;
//    
//    self.userNameTextField.defaultTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Bold" size:40]};
//    self.userNameTextField.adjustsFontSizeToFitWidth = YES;
//    self.userNameTextField.textAlignment = NSTextAlignmentCenter;
//    self.userNameTextField.tintColor = [UIColor whiteColor];
//    
//    self.userNameTextField.delegate = self;
//    self.userNameTextField.tag = indexPath.row;
//    
//    [cell addSubview:self.userNameTextField];
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 2;
//}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"NoCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    if (indexPath.row == 0)
//    {
//        self.userNameTextField.placeholder = @"CHOOSE YOUR USERNAME";
//        [self.userNameTextField becomeFirstResponder];
//    }
//    if (indexPath.row == 1)
//    {
//        self.userNameTextField.placeholder = @"GO";
//    }
//    
//    //if (indexPath.row == 1)
//    //{
//    //    cell.textLabel.text = @"GO";
//    //}
//    
//    return cell;
//}

#pragma mark - UITableView Delegate

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    switch (indexPath.row) {
//        case 0:
//            cell.backgroundColor = [UIColor colorWithRed:0.0/255 green:199.0/255 blue:166.0/255 alpha:1.0];
//            break;
//            
//        case 1:
//            cell.backgroundColor = [UIColor colorWithRed:0.0/255 green:230.0/255 blue:124.0/255 alpha:1.0];
//            break;
//    }
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 90;
//}

#pragma mark - UITextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self registerUser];
    [textField resignFirstResponder];
    return YES;
}


- (void)registerUser
{
    NSLog(@"register user");
    PFUser *user = [PFUser user];
    user.username = self.userNameTextField.text;
    user.password = @"p5@4fjdk!#jdk(";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
            [[NSUserDefaults standardUserDefaults] setObject:user.username forKey:@"UserName"];
            [[NSUserDefaults standardUserDefaults] setObject:user.password forKey:@"Password"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self performSegueWithIdentifier:@"toNo" sender:nil];
        }
        else
        {
            //username taken
            if (error.code == 202)
            {
                NSLog(@"username taken");
            }
        }
    }];
}




- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
