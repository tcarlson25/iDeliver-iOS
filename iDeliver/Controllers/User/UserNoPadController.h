//
//  UserNoPadController.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/31/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserNoPadController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *regOrConSwitch;
@property (weak, nonatomic) IBOutlet UITextField *padIdInput;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadSymbol;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
- (IBAction)padIdSubmitPressed:(id)sender;

-(void) handleConnectPad:(NSString *)padId;
-(void) handleRegisterPad:(NSString *)padId;

@end

