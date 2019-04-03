//
//  Pad.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/22/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const padBaseUrl = @"https://ideliver-api.firebaseapp.com/pad/";
static NSString *const thingSpeakBaseUrl = @"https://api.thingspeak.com/channels/606459/feeds.json?api_key=6WNFFVW8TD84C3CT";

@interface Pad : NSObject

@property NSString *padId;
@property NSString *padLocation;

+ (void)getPadById: (NSString *)padId :(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

+ (void)updatePadLocation:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

+ (void)createPad:(NSString *)padId :(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

- (void)updatePadLocationDB:(NSString *)padLocation :(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler;

@end
