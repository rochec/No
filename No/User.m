//
//  User.m
//  No
//
//  Created by Chris Roche on 6/22/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import "User.h"

@implementation User

-(id)initWithUserName:(NSString *)userName
{
    self = [super init];
    if (self)
    {
        self.userName = userName;
        self.password = @"p5@4fjdk!#jdk(";
    }
    
    return self;
}

-(id)init
{
    self = [self initWithUserName:nil];
    
    return self;
}

@end
