//
//  SignupViewController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/18/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "SignupViewController.h"
#import "AppDelegate.h"
#import "User.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup tap to get out of keyboard
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // set username border color
    _usernameInput.layer.cornerRadius=8.0f;
    _usernameInput.layer.masksToBounds=YES;
    _usernameInput.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    _usernameInput.layer.borderWidth= 0.5f;
    
    // set password border color
    _passwordInput.layer.cornerRadius=8.0f;
    _passwordInput.layer.masksToBounds=YES;
    _passwordInput.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    _passwordInput.layer.borderWidth= 0.5f;
    
    // set name boarder color
    _nameInput.layer.cornerRadius=8.0f;
    _nameInput.layer.masksToBounds=YES;
    _nameInput.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    _nameInput.layer.borderWidth= 0.5f;
}

- (IBAction)submitPressed:(UIButton *)sender {
    [_errorMessage setHidden:true];
    NSString *username = [_usernameInput text];
    NSString *password = [_passwordInput text];
    NSString *name = [_nameInput text];
    BOOL admin = [_adminSwitch isOn];
    
    if ([username length] == 0 || [password length] == 0 || [name length] == 0) {
        [_errorMessage setHidden:false];
        [_errorMessage setText:@"No blank fields allowed."];
        return;
    }
    [_loadingSymbol startAnimating];
    
    // create data for post request
    NSMutableDictionary *dataToSend = [NSMutableDictionary dictionary];
    dataToSend[@"id"] = username;
    dataToSend[@"password"] = password;
    dataToSend[@"name"] = name;
    dataToSend[@"admin"] = [NSNumber numberWithBool:admin];
    [self handleSignup:dataToSend];
}

- (void) handleSignup :(NSMutableDictionary *)dataToSend {
    [User isValidSignup:dataToSend :^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        NSError *err = nil;
        NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
        
        if (err) {
            NSLog(@"Error parsing JSON: %@", err);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self->_loadingSymbol stopAnimating];
                [self->_errorMessage setHidden:false];
                [self->_errorMessage setText:[err localizedDescription]];
            });
        } else {
            int code = [jsonDictionary[@"code"] intValue];
            if (code != 201) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self->_loadingSymbol stopAnimating];
                    [self->_errorMessage setHidden:false];
                    NSString *responseMessage = jsonDictionary[@"message"];
                    [self->_errorMessage setText:responseMessage];
                });
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self->_loadingSymbol stopAnimating];
                    BOOL admin = jsonDictionary[@"data.admin"];
                    NSString *username = [[jsonDictionary objectForKey:@"data"]objectForKey:@"id"];
                    NSString *tabBarType;
                    if (admin) {
                        tabBarType = @"adminTabBar";
                    } else {
                        tabBarType = @"userTabBar";
                    }
                    
                    [User setLoggedInUser:[[User alloc] init]];
                    [User.loggedInUser setUsername:username];
                    [User.loggedInUser setName:[[jsonDictionary objectForKey:@"data"]objectForKey:@"name"]];
                    [User.loggedInUser setAdmin:admin];
                    [User.loggedInUser setPad:[[Pad alloc] init]];
                    
                    UITabBarController *tabBar = [[self storyboard] instantiateViewControllerWithIdentifier:tabBarType];
                    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                    [[appDelegate window] setRootViewController:tabBar];
                });
            }
        }
    }];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}


@end
