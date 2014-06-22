//
//  User.h
//  No
//
//  Created by Chris Roche on 6/22/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFUser

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;

-(id)initWithUserName:(NSString *)userName;

@end
