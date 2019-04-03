//
//  DemoUtility.m
//  GSDemo
//
//  Created by Austin Gonzalez on 10/22/18.
//  Copyright © 2018 Austin Gonzalez. All rights reserved.
//

#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>
inline void ShowMessage(NSString *title, NSString *message, id target, NSString *cancleBtnTitle)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:target cancelButtonTitle:cancleBtnTitle otherButtonTitles:nil];
        [alert show];
    });
}
@implementation DemoUtility
+(DJIFlightController*) fetchFlightController {
    if (![DJISDKManager product]) {
        return nil;
    }
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).flightController;
    }
    return nil;
}
@end
