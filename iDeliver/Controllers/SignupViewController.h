//
//  SignupViewController.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/18/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSymbol;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UISwitch *adminSwitch;

- (IBAction)submitPressed:(UIButton *)sender;

- (void) handleSignup :(NSMutableDictionary *)dataToSend;

@end
