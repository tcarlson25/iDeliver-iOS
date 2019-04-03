//
//  UserNoPadController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/31/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "UserNoPadController.h"
#import "User.h"
#import "Pad.h"
#import "AppDelegate.h"

@interface UserNoPadController ()

@end

@implementation UserNoPadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup tap to get out of keyboard
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // set color of text box
    _padIdInput.layer.cornerRadius=8.0f;
    _padIdInput.layer.masksToBounds=YES;
    _padIdInput.layer.borderColor=[[UIColor colorNamed:@"mainGray"] CGColor];
    _padIdInput.layer.borderWidth= 0.5f;
}

- (IBAction)padIdSubmitPressed:(id)sender {
    [_errorMessage setHidden:true];
    NSString *padId = [_padIdInput text];
    BOOL isConnect = [_regOrConSwitch isOn];
    
    if ([padId length] == 0) {
        [_errorMessage setHidden:false];
        [_errorMessage setText:@"No blank fields allowed."];
        return;
    }
    [_loadSymbol startAnimating];

    if (isConnect) {
        [self handleConnectPad:padId];
    } else {
        [self handleRegisterPad:padId];
    }
}

- (void)handleConnectPad:(NSString *)padId {
    [Pad getPadById:padId :^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSError *err = nil;
        NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
        NSString *padLocation;
        if (err) {
            NSLog(@"Error parsing JSON: %@", err);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self->_loadSymbol stopAnimating];
                [self->_errorMessage setHidden:false];
                [self->_errorMessage setText:[err localizedDescription]];
            });
        } else {
            NSLog(@"JSON: %@", jsonDictionary);
            int code = [jsonDictionary[@"code"] intValue];
            if (code != 200) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self->_loadSymbol stopAnimating];
                    [self->_errorMessage setHidden:false];
                    NSString *responseMessage = jsonDictionary[@"message"];
                    [self->_errorMessage setText:responseMessage];
                });
            } else {
                padLocation = [[jsonDictionary objectForKey:@"data"]objectForKey:@"pad_location"];
                [User.loggedInUser updateUserPad:padId :^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    NSError *err = nil;
                    NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
                    
                    if (err) {
                        NSLog(@"Error parsing JSON: %@", err);
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self->_loadSymbol stopAnimating];
                            [self->_errorMessage setHidden:false];
                            [self->_errorMessage setText:[err localizedDescription]];
                        });
                    } else {
                        NSLog(@"JSON: %@", jsonDictionary);
                        int code = [jsonDictionary[@"code"] intValue];
                        if (code != 200) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self->_loadSymbol stopAnimating];
                                [self->_errorMessage setHidden:false];
                                NSString *responseMessage = jsonDictionary[@"message"];
                                [self->_errorMessage setText:responseMessage];
                            });
                        } else {
                            // successfully found pad and updated user's pad_id
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self->_loadSymbol stopAnimating];
                                [User.loggedInUser.pad setPadId:padId];
                                [User.loggedInUser.pad setPadLocation:padLocation];
                                
                                UITabBarController *tabBar = [[self storyboard] instantiateViewControllerWithIdentifier:@"userTabBar"];
                                AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                                [[appDelegate window] setRootViewController:tabBar];
                            });
                        }
                    }
                }];
            }
        }
    }];
}

- (void)handleRegisterPad:(NSString *)padId {
    [Pad createPad:padId :^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSError *err = nil;
        NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
        NSString *padLocation;
        if (err) {
            NSLog(@"Error parsing JSON: %@", err);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self->_loadSymbol stopAnimating];
                [self->_errorMessage setHidden:false];
                [self->_errorMessage setText:[err localizedDescription]];
            });
        } else {
            NSLog(@"JSON: %@", jsonDictionary);
            int code = [jsonDictionary[@"code"] intValue];
            if (code != 201) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self->_loadSymbol stopAnimating];
                    [self->_errorMessage setHidden:false];
                    NSString *responseMessage = jsonDictionary[@"message"];
                    [self->_errorMessage setText:responseMessage];
                });
            } else {
                padLocation = [[jsonDictionary objectForKey:@"data"]objectForKey:@"pad_location"];
                [User.loggedInUser updateUserPad:padId :^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    NSError *err = nil;
                    NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
                    
                    if (err) {
                        NSLog(@"Error parsing JSON: %@", err);
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self->_loadSymbol stopAnimating];
                            [self->_errorMessage setHidden:false];
                            [self->_errorMessage setText:[err localizedDescription]];
                        });
                    } else {
                        NSLog(@"JSON: %@", jsonDictionary);
                        int code = [jsonDictionary[@"code"] intValue];
                        if (code != 200) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self->_loadSymbol stopAnimating];
                                [self->_errorMessage setHidden:false];
                                NSString *responseMessage = jsonDictionary[@"message"];
                                [self->_errorMessage setText:responseMessage];
                            });
                        } else {
                            // successfully found pad and updated user's pad_id
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self->_loadSymbol stopAnimating];
                                [User.loggedInUser.pad setPadId:padId];
                                [User.loggedInUser.pad setPadLocation:padLocation];
                                
                                UITabBarController *tabBar = [[self storyboard] instantiateViewControllerWithIdentifier:@"userTabBar"];
                                AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                                [[appDelegate window] setRootViewController:tabBar];
                            });
                        }
                    }
                }];
            }
        }
    }];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

@end
