//
//  Order.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/16/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const ordersForUserBaseUrl = @"https://ideliver-api.firebaseapp.com/order/user/";
static NSString *const orderBaseUrl = @"https://ideliver-api.firebaseapp.com/order/";

@interface Order : NSObject

@property NSString *orderId;
@property NSString *userId;
@property NSString *title;
@property NSString *deliveryDate;
@property NSString *padLocation;
@property NSString *status;

+ (void)getCompletedOrdersForUser: (NSString *)username :(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

+ (void)getAllOrders: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

+ (void)createOrder: (NSMutableDictionary *)dataToSend :(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

- (void)confirmOrCompleteOrder: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

- (void)completeWithAwait: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

- (void)deleteOrder: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

- (void)cancelOrder: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

- (void)approveOrder: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

- (void)shipOrder: (void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

@end
