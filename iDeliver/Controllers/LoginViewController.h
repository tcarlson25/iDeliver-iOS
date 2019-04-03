//
//  LoginViewController
//  iDeliver
//
//  Created by Tyler Carlson on 10/13/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Popup.h"

@interface LoginViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UILabel *popupMessage;
@property UIWindow *mainWindow;
@property Popup *popup;
@property (strong, nonatomic) UIBarButtonItem *infoLogoButton;

@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSymbol;

- (IBAction)loginPressed:(UIButton *)sender;
- (IBAction)signupPressed:(UIButton *)sender;
//- (IBAction)submitPressed:(UIButton *)sender;
- (IBAction)dismissPopup:(id)sender;
- (void)infoButtonAction;

- (void)handleLogin:(NSString *)username :(NSString *)password;
//- (void) handleSignup :(NSMutableDictionary *)dataToSend;

@end

