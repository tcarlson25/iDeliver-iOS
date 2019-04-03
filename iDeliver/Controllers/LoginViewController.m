//
//  LoginViewController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/13/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "Popup.h"
#import "Pad.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize usernameInput, passwordInput, errorMessage, loadingSymbol;

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainWindow = [UIApplication sharedApplication].keyWindow;
    _popup = [[Popup alloc] initWith:_mainWindow :_popupView :_popupMessage];
    
    // setup tap to get out of keyboard
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // setup info button
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _infoLogoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setRightBarButtonItem:_infoLogoButton animated:YES];
    
    // set username border color
    usernameInput.layer.cornerRadius=8.0f;
    usernameInput.layer.masksToBounds=YES;
    usernameInput.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    usernameInput.layer.borderWidth= 0.5f;
    
    // set password border color
    passwordInput.layer.cornerRadius=8.0f;
    passwordInput.layer.masksToBounds=YES;
    passwordInput.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    passwordInput.layer.borderWidth= 0.5f;
}

- (void)infoButtonAction {
    NSString *teamName = @"CSCE 483 - Team Aggie Drone Systems";
    NSString *members = @"Krista Capps\nTyler Carlson\nAustin Gonzalez\nAbdurrahman Najjar\nSrishti Sanghvi\nChristian Tovar";
    [_popup showPopup:[NSString stringWithFormat:@"%@\n\n%@", teamName, members]];
}

- (IBAction)loginPressed:(UIButton *)sender {
    [errorMessage setHidden:true];
    NSString *username = [usernameInput text];
    NSString *password = [passwordInput text];
    
    if ([username length] == 0 || [password length] == 0) {
        [errorMessage setHidden:false];
        [errorMessage setText:@"No blank fields allowed."];
        return;
    }
    
    [loadingSymbol startAnimating];
    [self handleLogin:username :password];
}

- (IBAction)signupPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"signupSeque" sender:sender];
}

- (IBAction)dismissPopup:(id)sender {
    [_popup dismissPopup];
}

- (void)handleLogin:(NSString *)username :(NSString *)password {
    [User isValidLogin:username :^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSError *err = nil;
        NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
        
        if (err) {
            NSLog(@"Error parsing JSON: %@", err);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self->loadingSymbol stopAnimating];
                [self->errorMessage setHidden:false];
                [self->errorMessage setText:[err localizedDescription]];
            });
        } else {
            NSLog(@"JSON: %@", jsonDictionary);
            int code = [jsonDictionary[@"code"] intValue];
            if (code != 200) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self->loadingSymbol stopAnimating];
                    [self->errorMessage setHidden:false];
                    NSString *responseMessage = jsonDictionary[@"message"];
                    [self->errorMessage setText:responseMessage];
                });
            } else {
                NSString* passwordOnFile = [[jsonDictionary objectForKey:@"data"]objectForKey:@"password"];
                if ([password isEqualToString:passwordOnFile]) {
                    [User setLoggedInUser:[[User alloc] init]];
                    BOOL isAdmin = [[[jsonDictionary objectForKey:@"data"]objectForKey:@"admin"] boolValue];
                    [User.loggedInUser setUsername:username];
                    NSString *name = [[jsonDictionary objectForKey:@"data"]objectForKey:@"name"];
                    [User.loggedInUser setName:name];
                    [User.loggedInUser setAdmin:isAdmin];
                    
                    // get pad on file
                    NSString *padId = [[jsonDictionary objectForKey:@"data"]objectForKey:@"pad_id"];
                    if ((NSNull *)padId != [NSNull null]) {
                        [Pad getPadById:padId :^(NSData *data, NSURLResponse *response, NSError *error) {
                            NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                            NSError *err = nil;
                            NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
                            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
                            
                            if (err) {
                                NSLog(@"Error parsing JSON: %@", err);
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self->loadingSymbol stopAnimating];
                                    [self->errorMessage setHidden:false];
                                    NSString *responseMessage = jsonDictionary[@"message"];
                                    [self->errorMessage setText:responseMessage];
                                    [User.loggedInUser setPad:nil];
                                });
                            } else {
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self->loadingSymbol stopAnimating];
                                    BOOL isAdmin = [User.loggedInUser admin];
                                    NSString *tabBarType;
                                    if (isAdmin) {
                                        tabBarType = @"adminTabBar";
                                    } else {
                                        tabBarType = @"userTabBar";
                                    }
                                    
                                    [User.loggedInUser setPad:[[Pad alloc] init]];
                                    NSString *padLocation = [[jsonDictionary objectForKey:@"data"]objectForKey:@"pad_location"];
                                    [User.loggedInUser.pad setPadId:padId];
                                    [User.loggedInUser.pad setPadLocation:padLocation];
                                    
                                    UITabBarController *tabBar = [[self storyboard] instantiateViewControllerWithIdentifier:tabBarType];
                                    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                                    [[appDelegate window] setRootViewController:tabBar];
                                });
                            }
                        }];
                    } else {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self->loadingSymbol stopAnimating];
                            BOOL isAdmin = [User.loggedInUser admin];
                            NSString *tabBarType;
                            if (isAdmin) {
                                tabBarType = @"adminTabBar";
                            } else {
                                tabBarType = @"userTabBar";
                            }
                            
                            [User.loggedInUser setPad:[[Pad alloc] init]];
                            
                            UITabBarController *tabBar = [[self storyboard] instantiateViewControllerWithIdentifier:tabBarType];
                            AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                            [[appDelegate window] setRootViewController:tabBar];
                        });
                    }
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self->loadingSymbol stopAnimating];
                        [self->errorMessage setHidden:false];
                        [self->errorMessage setText:@"Invalid Password for User."];
                    });
                }
                
            }
        }
    }];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

@end
