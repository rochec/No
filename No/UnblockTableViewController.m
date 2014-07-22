//
//  UnblockTableViewController.m
//  No
//
//  Created by Chris Roche on 6/20/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import "UnblockTableViewController.h"

@interface UnblockTableViewController ()

@property (strong, nonatomic) NSMutableArray *blockedUsers;

@end

@implementation UnblockTableViewController

-(NSMutableArray *)blockedUsers
{
    if (!_blockedUsers)
    {
        _blockedUsers = [NSMutableArray arrayWithCapacity:3];
    }
    
    return _blockedUsers;
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
    [PFAnalytics trackEvent:@"unblockViewController Opened"];

    
    //self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view.backgroundColor = [UIColor colorWithRed:169.0/255 green:67.0/255 blue:181.0/255 alpha:1.0];
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
    
    //self.blockedUsers = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"blockedUsers"] mutableCopy];
    self.blockedUsers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"blockedUsers"]];
    NSLog(@"will appear");
    [self.blockedUsers addObject:@"DONE"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.blockedUsers count];
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
    
    cell.textLabel.text = self.blockedUsers[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

//-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    });
//    return nil;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == ([self.blockedUsers count] - 1))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
    
    else
    {
        NSString *userName = cell.textLabel.text;
        NSLog(@"userName: %@", userName);
        
        __block PFUser *user;
        PFUser *currentUser = [PFUser currentUser];
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:userName];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects)
            {
                user = [objects firstObject];
                
                PFQuery *query2 = [PFQuery queryWithClassName:@"Relationships"];
                [query2 whereKey:@"user" equalTo:user];
                [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (objects)
                    {
                        PFObject *relationships = [objects firstObject];
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        array = relationships[@"blockedUsers"];
                        for (int i = 0; i < [array count]; i++)
                        {
                            NSLog(@"inside array");
                            NSString *objectId = relationships[@"blockedUsers"][i];
                            if ([objectId isEqualToString:currentUser.objectId])
                            {
                                [array removeObjectAtIndex:i];
                                [relationships setObject:array forKey:@"blockedUsers"];
                                [relationships saveInBackground];
                            }
                            else
                            {
                                NSLog(@"user already unblocked");
                            }
                        }
                    }
                }];
            }
            else if (error)
            {
                NSLog(@"error %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UNBLOCK FAILED" message:@"THERE WAS AN ERROR UNBLOCKING THE USER.  PLEASE TRY AGAIN." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }];
        
        [UIView animateWithDuration:0.5 animations:^{
            //cell.textLabel.hidden = NO;
            cell.textLabel.text = @"UNBLOCKED";
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.blockedUsers removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                
                NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:self.blockedUsers];
                [temp removeLastObject];
                [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"blockedUsers"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            });
        }];
    }
}

-(void)toShareButton:(id)sender
{
    [self performSegueWithIdentifier:@"toShare" sender:sender];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (BOOL)prefersStatusBarHidden
{
    return YES;
}






@end
