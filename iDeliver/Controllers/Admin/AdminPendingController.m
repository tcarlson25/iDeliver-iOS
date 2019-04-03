//
//  AdminPendingController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/24/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "AdminPendingController.h"
#import "AdminPendingCell.h"
#import "Order.h"
#import "User.h"
#import "Popup.h"
#import "DJIRootViewController.h"

@interface AdminPendingController ()
@property NSMutableDictionary *userToOrders;
@end

@implementation AdminPendingController

UIRefreshControl *adminPendingRefreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainWindow = [UIApplication sharedApplication].keyWindow;
    _popup = [[Popup alloc] initWith:_mainWindow :_popupView :_popupMessage];
    
    // setup info button
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setRightBarButtonItem:modalButton animated:YES];
    
    // get table data
    _userToOrders = [[NSMutableDictionary alloc] init];
    [self getPendingOrders];
    
    // set some table settings
    [[[[self navigationController] navigationBar] topItem] setTitle:@"Pending"];
    [self.navigationController.navigationBar setPrefersLargeTitles:true];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // set refresh control
    adminPendingRefreshControl = [[UIRefreshControl alloc] init];
    [adminPendingRefreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [[self tableView] setRefreshControl:adminPendingRefreshControl];
    
    [[self tableView] setBackgroundView:nil];
    [[self tableView] setBackgroundColor:[UIColor whiteColor]];
}

- (void)infoButtonAction {
    NSString *description = @"Pending deliveries contain orders that are awaiting admin approval, awaiting to be shipped, and in route. Admins can see all user's deliveries and send/ship them.";
    NSString *swipeLeftHelp = @"Swipe Left - Approve/Complete Delivery";
    NSString *swipeRightHelp = @"Swipe Right - Cancel a Delivery";
    NSString *colorCodeGreen = @"Green - Delivery is in route";
    NSString *colorCodeYellow = @"Yellow - Delivery is awaiting approval/shipment";
    [_popup showPopup:[NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@\n\n%@", description, swipeLeftHelp,   swipeRightHelp, colorCodeGreen, colorCodeYellow]];
}

- (IBAction)dismissPopup:(id)sender {
    [_popup dismissPopup];
}

- (void)getPendingOrders {
    [Order getAllOrders:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSError *err = nil;
        NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
        
        if (err) {
            NSLog(@"Error parsing JSON: %@", err);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self->_popup showPopup:[err localizedDescription]];
            });
        } else {
            NSLog(@"JSON: %@", jsonDictionary);
            int code = [jsonDictionary[@"code"] intValue];
            if (code != 200) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self->_popup showPopup:jsonDictionary[@"message"]];
                });
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSArray *foundOrders = jsonDictionary[@"data"];
                    for (NSDictionary *jsonOrder in foundOrders) {
                        NSString *status = jsonOrder[@"status"];
                        if (![status isEqualToString:@"pending-approval"] && ![status isEqualToString:@"pending-shipment"] && ![status isEqualToString:@"pending-inroute"]) {
                            continue;
                        }
                        NSString *userId =jsonOrder[@"user_id"];
                        Order *order = [[Order alloc] init];
                        [order setOrderId:jsonOrder[@"id"]];
                        [order setUserId:userId];
                        [order setTitle:jsonOrder[@"title"]];
                        [order setDeliveryDate:jsonOrder[@"delivery_date"]];
                        if ([jsonOrder[@"pad_location"] isEqual:[NSNull null]]) {
                            [order setPadLocation:@"N/A"];
                        } else {
                            [order setPadLocation:jsonOrder[@"pad_location"]];
                        }
                        [order setStatus:status];
                        NSMutableArray<Order *> *userOrders = [self->_userToOrders valueForKey:userId];
                        if (userOrders != nil) {
                            // user does exist in dictionary
                            [userOrders addObject:order];
                            [self->_userToOrders setObject:userOrders forKey:userId];
                        } else {
                            // user does not exist in dictionary
                            userOrders = [[NSMutableArray alloc] init];
                            [userOrders addObject:order];
                            [self->_userToOrders setObject:userOrders forKey:userId];
                        }
                    }
                    [[self tableView] reloadData];
                });
            }
        }
    }];
}

// refresh control
- (void)refreshTable {
    _userToOrders = [[NSMutableDictionary alloc] init];
    [self getPendingOrders];
    [adminPendingRefreshControl endRefreshing];
    [[self tableView] reloadData];
}

// setup left swipe on cell
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    AdminPendingCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    if ([[[cell status] text] isEqualToString:@"Awaiting Approval"]) {
        UIContextualAction *action = [self approveOrder:indexPath];
        [actions addObject:action];
    } else if ([[[cell status] text] isEqualToString:@"In Route"]) {
        UIContextualAction *action = [self completeAwaitOrder:indexPath];
        [actions addObject:action];
    }
    UISwipeActionsConfiguration *actionsConfig = [UISwipeActionsConfiguration configurationWithActions:actions];
    return actionsConfig;
}

// setup right swipe on cell
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *action = [self cancelOrder:indexPath];
    NSArray *actions = @[action];
    UISwipeActionsConfiguration *actionsConfig = [UISwipeActionsConfiguration configurationWithActions:actions];
    return actionsConfig;
}

// control for canceling an order (right swipe)
- (UIContextualAction *)cancelOrder:(NSIndexPath *)indexPath {
    NSArray<NSString *> *allKeys = [_userToOrders allKeys];
    NSString *sectionKey = [allKeys objectAtIndex:indexPath.section];
    NSMutableArray<Order *> *userOrders = [_userToOrders objectForKey:sectionKey];
    Order *order = userOrders[indexPath.row];
    
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:normal title:@"Cancel" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [order cancelOrder:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSError *err = nil;
            NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
            
            if (err) {
                NSLog(@"Error parsing JSON: %@", err);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self->_popup showPopup:[err localizedDescription]];
                });
            } else {
                NSLog(@"JSON: %@", jsonDictionary);
                int code = [jsonDictionary[@"code"] intValue];
                if (code != 200) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self->_popup showPopup:jsonDictionary[@"message"]];
                    });
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [userOrders removeObjectAtIndex:indexPath.row];
                        [self->_userToOrders setObject:userOrders forKey:sectionKey];
                        [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    });
                }
            }
        }];
        completionHandler(true);
    }];
    [action setBackgroundColor: [UIColor colorNamed:@"invalidRed"]];
    return action;
}

// control for approving an order (right swipe)
- (UIContextualAction *)approveOrder:(NSIndexPath *)indexPath {
    NSArray<NSString *> *allKeys = [_userToOrders allKeys];
    NSString *sectionKey = [allKeys objectAtIndex:indexPath.section];
    NSMutableArray<Order *> *userOrders = [_userToOrders objectForKey:sectionKey];
    Order *order = userOrders[indexPath.row];
    
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:normal title:@"Approve" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [order approveOrder:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSError *err = nil;
            NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
            
            if (err) {
                NSLog(@"Error parsing JSON: %@", err);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self->_popup showPopup:[err localizedDescription]];
                });
            } else {
                NSLog(@"JSON: %@", jsonDictionary);
                int code = [jsonDictionary[@"code"] intValue];
                if (code != 200) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self->_popup showPopup:jsonDictionary[@"message"]];
                    });
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        AdminPendingCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
                        [[cell status] setText:@"Awaiting Shipment"];
                        [[cell sendButton] setEnabled:true];
                    });
                }
            }
        }];
        completionHandler(true);
    }];
    [action setBackgroundColor: [UIColor colorNamed:@"validGreen"]];
    return action;
}

// control for completing an order (right swipe)
- (UIContextualAction *)completeAwaitOrder:(NSIndexPath *)indexPath {
    NSArray<NSString *> *allKeys = [_userToOrders allKeys];
    NSString *sectionKey = [allKeys objectAtIndex:indexPath.section];
    NSMutableArray<Order *> *userOrders = [_userToOrders objectForKey:sectionKey];
    Order *order = userOrders[indexPath.row];
    
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:normal title:@"Complete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [order completeWithAwait:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSError *err = nil;
            NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
            
            if (err) {
                NSLog(@"Error parsing JSON: %@", err);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self->_popup showPopup:[err localizedDescription]];
                });
            } else {
                NSLog(@"JSON: %@", jsonDictionary);
                int code = [jsonDictionary[@"code"] intValue];
                if (code != 200) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self->_popup showPopup:jsonDictionary[@"message"]];
                    });
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [userOrders removeObjectAtIndex:indexPath.row];
                        [self->_userToOrders setObject:userOrders forKey:sectionKey];
                        [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    });
                }
            }
        }];
        completionHandler(true);
    }];
    [action setBackgroundColor: [UIColor colorNamed:@"validGreen"]];
    return action;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_userToOrders count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray<NSString *> *allKeys = [_userToOrders allKeys];
    NSString *sectionKey = [allKeys objectAtIndex:section];
    NSArray<Order *> *userOrders = [_userToOrders objectForKey:sectionKey];
    return [userOrders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray<NSString *> *allKeys = [_userToOrders allKeys];
    NSString *sectionKey = [allKeys objectAtIndex:section];
    return sectionKey;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AdminPendingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adminPendingCell" forIndexPath:indexPath];
    
    NSArray<NSString *> *allKeys = [_userToOrders allKeys];
    NSString *sectionKey = [allKeys objectAtIndex:indexPath.section];
    NSArray<Order *> *userOrders = [_userToOrders objectForKey:sectionKey];
    Order *order = userOrders[indexPath.row];
    
    // setup send button
    [[cell sendButton] setOrder:order];
    [[cell sendButton] addTarget:self action:@selector(setupSendButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [[cell orderNumber] setText:[NSString stringWithFormat:@"#%@", order.orderId]];
    [[cell orderTitle] setText:order.title];
    [[cell deliveryDate] setText:order.deliveryDate];
    [[cell location] setText:order.padLocation];
    
    NSString *status = order.status;
    [[cell confirmedBar] setBackgroundColor:[UIColor colorNamed:@"pendingYellow"]];
    if ([status isEqualToString:@"pending-approval"]) {
        [[cell status] setText:@"Awaiting Approval"];
        [[cell sendButton] setEnabled:false];
    } else if ([status isEqualToString:@"pending-shipment"]) {
        [[cell status] setText:@"Awaiting Shipment"];
        [[cell sendButton] setEnabled:true];
    } else if ([status isEqualToString:@"pending-inroute"]) {
        [[cell status] setText:@"In Route"];
        [[cell sendButton] setEnabled:false];
    }
    
    return cell;
}

- (void)setupSendButton:(SendButton *)sender {
    UINavigationController *adminNav = [self.tabBarController.viewControllers objectAtIndex:0];
    DJIRootViewController *adminController = [[adminNav childViewControllers] objectAtIndex:0];
    [adminController setOrderToDeliver:[sender order]];
    [[self tabBarController] setSelectedViewController:adminNav];
}

@end
