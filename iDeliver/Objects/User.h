//
//  User.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/16/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pad.h"

static NSString *const userBaseUrl = @"https://ideliver-api.firebaseapp.com/user/";

@interface User : NSObject

@property NSString *username;
@property NSString *password;
@property BOOL admin;
@property NSString *name;
@property Pad *pad;

@property(class, copy) User *loggedInUser;

+ (void)isValidLogin: (NSString *)username :(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

+ (void)isValidSignup: (NSMutableDictionary *)dataToSend :(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

- (void)updateUserPad: (NSString *)padLocation :(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

@end
