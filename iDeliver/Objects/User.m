//
//  User.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/16/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "User.h"

@implementation User

static User *loggedInUser;

+ (User *)loggedInUser {
    // uncomment these lines to automatically login as this user without going through the login screen
//    User *tempUser = [[User alloc] init];
//    [tempUser setUsername:@"tcarlson"];
//    [tempUser setAdmin:false];
//    [tempUser setName:@"Tyler Carlson"];
//    Pad *tempPad = [[Pad alloc] init];
//    [tempPad setPadLocation:@"30.622370, -96.325851"];
//    [tempPad setPadId:@"0EutknxSWvwRmu5N6XyY"];
//    [tempUser setPad:tempPad];
//    loggedInUser = tempUser;
    //----------------------------------
    
    return loggedInUser;
}

+ (void) setLoggedInUser:(User *)user {
    loggedInUser = user;
}

+ (void)isValidLogin: (NSString *)username :(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [userBaseUrl stringByAppendingString:username];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // make request
    [[session dataTaskWithRequest:request completionHandler: handler] resume];
}

+ (void)isValidSignup:(NSMutableDictionary *)dataToSend :(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create post request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:userBaseUrl]];
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToSend options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSData *requestData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // make request
    [[session dataTaskWithRequest:request completionHandler:handler] resume];
}

- (void)updateUserPad:(NSString *)padId :(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create put request
    NSString *url = [NSString stringWithFormat:@"%@%@", userBaseUrl, [self username]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"PUT"];
    NSError *error;
    
    NSMutableDictionary *dataToSend = [NSMutableDictionary dictionary];
    dataToSend[@"pad_id"] = padId;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToSend options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSData *requestData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // make request
    [[session dataTaskWithRequest:request completionHandler:handler] resume];
}

@end
