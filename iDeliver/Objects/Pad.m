//
//  Pad.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/22/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "Pad.h"

@implementation Pad

+ (void)getPadById: (NSString *)padId :(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler {
    // setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [padBaseUrl stringByAppendingString:padId];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // make request
    [[session dataTaskWithRequest:request completionHandler: handler] resume];
}

+ (void)updatePadLocation:(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:thingSpeakBaseUrl]];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // make request
    [[session dataTaskWithRequest:request completionHandler: handler] resume];
}

+ (void)createPad:(NSString *)padId :(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create post request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:padBaseUrl]];
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSMutableDictionary *dataToSend = [[NSMutableDictionary alloc] init];
    dataToSend[@"id"] = padId;
    dataToSend[@"pad_location"] = [NSNull null];
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

- (void)updatePadLocationDB:(NSString *)padLocation :(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create put request
    NSString *url = [NSString stringWithFormat:@"%@%@", padBaseUrl, [self padId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"PUT"];
    NSError *error;
    
    NSMutableDictionary *dataToSend = [NSMutableDictionary dictionary];
    dataToSend[@"pad_location"] = padLocation;
    
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
