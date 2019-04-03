//
//  CreateOrderController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/22/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "CreateOrderController.h"
#import "User.h"
#import "Order.h"

@interface CreateOrderController ()

@end

@implementation CreateOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDatePicker];
    
    // set error message color to red
    [_errorMessage setTextColor:[UIColor colorNamed:@"invalidRed"]];
    
    // set nav title
    [[[[self navigationController] navigationBar] topItem] setTitle:@"Order"];
    [self.navigationController.navigationBar setPrefersLargeTitles:true];
    [_welcomeMessage setText:[NSString stringWithFormat:@"Welcome %@!", [User.loggedInUser name]]];
    if (User.loggedInUser.pad.padLocation != (id)[NSNull null] && User.loggedInUser.pad.padLocation != nil) {
        [_padLocation setText:[User.loggedInUser.pad padLocation]];
    } else {
        [_padLocation setText:@"N/A"];
    }
    
    // setup tap to get out of keyboard
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // set color of text box
    _orderTitle.layer.cornerRadius=8.0f;
    _orderTitle.layer.masksToBounds=YES;
    _orderTitle.layer.borderColor=[[UIColor colorNamed:@"mainGray"] CGColor];
    _orderTitle.layer.borderWidth= 0.5f;
    
    _deliveryDate.layer.cornerRadius=8.0f;
    _deliveryDate.layer.masksToBounds=YES;
    _deliveryDate.layer.borderColor=[[UIColor colorNamed:@"mainGray"] CGColor];
    _deliveryDate.layer.borderWidth= 0.5f;
}

// refresh control
- (void) clearInputs {
    [_orderTitle setText:@""];
    [_deliveryDate setText:@""];
    if (User.loggedInUser.pad.padLocation != (id)[NSNull null] && User.loggedInUser.pad.padLocation != nil) {
        [_padLocation setText:[User.loggedInUser.pad padLocation]];
    } else {
        [_padLocation setText:@"N/A"];
    }
    [_errorMessage setTextColor:[UIColor colorNamed:@"invalidRed"]];
    [_errorMessage setHidden:true];
}

- (void) createDatePicker {
    _datePicker = [[UIDatePicker alloc] init];
    [_datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [_datePicker setMinuteInterval:30];
    [_deliveryDate setInputView:_datePicker];
    
    UIToolbar *dateToolbar = [[UIToolbar alloc] init];
    [dateToolbar sizeToFit];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateChanged)];
    
    [dateToolbar setItems:[NSArray arrayWithObject:doneButton] animated:true];
    [_deliveryDate setInputAccessoryView:dateToolbar];
}

- (void)dateChanged {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"MM/dd/yyyy-h:mm a"];
    [self.deliveryDate setText:[NSString stringWithFormat:@"%@", [formatter stringFromDate:_datePicker.date]]];
    [[self view] endEditing:true];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)submitPressed:(id)sender {
    [_errorMessage setHidden:true];
    NSString *orderTitle = [_orderTitle text];
    NSString *deliveryDate = [_deliveryDate text];
    NSString *padLocation = [User.loggedInUser.pad padLocation];
    
    if ([orderTitle length] == 0 || [deliveryDate length] == 0) {
        [_errorMessage setHidden:false];
        [_errorMessage setText:@"No blank fields allowed."];
        return;
    }
    if (padLocation == nil || padLocation == (id)[NSNull null]) {
        [_errorMessage setHidden:false];
        [_errorMessage setText:@"Pad Location must be updated."];
        return;
    }
    [_loadingSymbol startAnimating];
    
    // create data for post request
    NSMutableDictionary *dataToSend = [NSMutableDictionary dictionary];
    dataToSend[@"title"] = orderTitle;
    dataToSend[@"delivery_date"] = deliveryDate;
    dataToSend[@"pad_location"] = padLocation;
    dataToSend[@"status"] = @"pending-approval";
    dataToSend[@"user_id"] = [User.loggedInUser username];
    [self handleOrderCreation:dataToSend];
}

- (IBAction)clearPressed:(id)sender {
    [self clearInputs];
}

- (void) handleOrderCreation:(NSMutableDictionary *)dataToSend {
    [Order createOrder:dataToSend :^(NSData *data, NSURLResponse *response, NSError *error) {
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
                    [self->_errorMessage setHidden:false];
                    [self->_errorMessage setTextColor:[UIColor colorNamed:@"validGreen"]];
                    [self->_errorMessage setText:@"Order Successfully Created."];
                });
            }
        }
    }];
}

@end
