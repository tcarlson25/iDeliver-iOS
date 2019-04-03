//
//  CreateOrderController.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/22/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateOrderController : UIViewController

@property UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UITextField *orderTitle;
@property (weak, nonatomic) IBOutlet UITextField *deliveryDate;
@property (weak, nonatomic) IBOutlet UILabel *welcomeMessage;
@property (weak, nonatomic) IBOutlet UILabel *padLocation;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSymbol;

- (IBAction)submitPressed:(id)sender;
- (IBAction)clearPressed:(id)sender;

- (void) handleOrderCreation:(NSMutableDictionary *)dataToSend;
- (void) createDatePicker;
- (void) clearInputs;
- (void) dateChanged;

@end
