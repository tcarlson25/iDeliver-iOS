//
//  AdminPendingController.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/24/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Popup.h"
#import "SendButton.h"

@interface AdminPendingController : UITableViewController

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UILabel *popupMessage;

@property Popup *popup;
@property UIWindow *mainWindow;

- (IBAction)dismissPopup:(id)sender;

- (void)infoButtonAction;
- (void)getPendingOrders;
- (void)setupSendButton:(SendButton *)sender;
- (UIContextualAction *)cancelOrder:(NSIndexPath *)indexPath;
- (UIContextualAction *)approveOrder:(NSIndexPath *)indexPath;
- (UIContextualAction *)completeOrder:(NSIndexPath *)indexPath;

@end
