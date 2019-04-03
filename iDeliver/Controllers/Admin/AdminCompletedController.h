//
//  AdminCompletedController.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/24/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Popup.h"

@interface AdminCompletedController : UITableViewController

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UILabel *popupMessage;

@property Popup *popup;
@property UIWindow *mainWindow;

- (IBAction)dismissPopup:(id)sender;

- (void)infoButtonAction;
- (void)getCompletedOrders;

@end
