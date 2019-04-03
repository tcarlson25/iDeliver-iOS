//
//  Order.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/16/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "Order.h"

@implementation Order

+ (void)getCompletedOrdersForUser:(NSString *)username :(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // setup request
    NSString *url = [NSString stringWithFormat:@"%@%@", ordersForUserBaseUrl, username];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // make request
    [[session dataTaskWithRequest:request completionHandler:handler] resume];
}

+ (void)getAllOrders:(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:orderBaseUrl]];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // make request
    [[session dataTaskWithRequest:request completionHandler:handler] resume];
}

+ (void)createOrder:(NSMutableDictionary *)dataToSend :(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create post request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:orderBaseUrl]];
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

- (void)confirmOrCompleteOrder:(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create put request
    NSString *url = [NSString stringWithFormat:@"%@%@", orderBaseUrl, [self orderId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"PUT"];
    NSError *error;
    
    NSMutableDictionary *dataToSend = [NSMutableDictionary dictionary];
    dataToSend[@"status"] = @"completed";
    
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

- (void)deleteOrder:(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create delete request
    NSString *url = [NSString stringWithFormat:@"%@%@", orderBaseUrl, [self orderId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"DELETE"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // make request
    [[session dataTaskWithRequest:request completionHandler:handler] resume];
}


- (void)completeWithAwait:(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create put request
    NSString *url = [NSString stringWithFormat:@"%@%@", orderBaseUrl, [self orderId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"PUT"];
    NSError *error;
    
    NSMutableDictionary *dataToSend = [NSMutableDictionary dictionary];
    dataToSend[@"status"] = @"completed-awaiting";
    
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


- (void)cancelOrder:(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create put request
    NSString *url = [NSString stringWithFormat:@"%@%@", orderBaseUrl, [self orderId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"PUT"];
    NSError *error;
    
    NSMutableDictionary *dataToSend = [NSMutableDictionary dictionary];
    dataToSend[@"status"] = @"canceled";
    
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

- (void)approveOrder:(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create put request
    NSString *url = [NSString stringWithFormat:@"%@%@", orderBaseUrl, [self orderId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"PUT"];
    NSError *error;
    
    NSMutableDictionary *dataToSend = [NSMutableDictionary dictionary];
    dataToSend[@"status"] = @"pending-shipment";
    
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

- (void)shipOrder:(void (^)(NSData *, NSURLResponse *, NSError *))handler {
    // create put request
    NSString *url = [NSString stringWithFormat:@"%@%@", orderBaseUrl, [self orderId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"PUT"];
    NSError *error;
    
    NSMutableDictionary *dataToSend = [NSMutableDictionary dictionary];
    dataToSend[@"status"] = @"pending-inroute";
    
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
