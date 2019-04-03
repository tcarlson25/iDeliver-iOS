//
//  UserPendingController.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/22/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Popup.h"
#import "TrackButton.h"

@interface UserPendingController : UITableViewController

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UILabel *popupMessage;

@property Popup *popup;
@property UIWindow *mainWindow;

- (IBAction)dismissPopup:(id)sender;

- (void)infoButtonAction;
- (void)getPendingOrders:(NSString *)username;
- (void)setupTrackButton:(TrackButton *)sender;
- (UIContextualAction *)cancelOrder:(NSIndexPath *)indexPath;

@end
