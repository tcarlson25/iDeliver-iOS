//
//  UserCompletedController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/16/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "UserCompletedController.h"
#import "CompletedCell.h"
#import "Order.h"
#import "User.h"
#import "Popup.h"

@interface UserCompletedController ()
@property NSMutableArray<Order *> *orders;
@end

@implementation UserCompletedController

UIRefreshControl *userCompletedRefreshControl;

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
    _orders = [[NSMutableArray alloc] init];
    [self getCompletedOrders: [User.loggedInUser username]];
    
    // set some table settings
    [[[[self navigationController] navigationBar] topItem] setTitle:@"Completed"];
    [self.navigationController.navigationBar setPrefersLargeTitles:true];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    // set refresh control
    userCompletedRefreshControl = [[UIRefreshControl alloc] init];
    [userCompletedRefreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [[self tableView] setRefreshControl:userCompletedRefreshControl];
}

- (void)infoButtonAction {
    NSString *description = @"Completed deliveries contain orders that have been successfully delivered and those that are awaiting verfication of a successful delivery";
    NSString *swipeLeftHelp = @"Swipe Left - Confirm a Delivery";
    NSString *swipeRightHelp = @"Swipe Right - Delete a Delivery";
    NSString *colorCodeGreen = @"Green - Delivery is Confirmed";
    NSString *colorCodeYellow = @"Yellow - Delivery is Awaiting Confirmation";
    NSString *colorCodeRed = @"Red - Delivery is Canceled";
    [_popup showPopup:[NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@\n\n%@\n\n%@", description, swipeLeftHelp, swipeRightHelp, colorCodeGreen, colorCodeYellow, colorCodeRed]];
}

- (IBAction)dismissPopup:(id)sender {
    [_popup dismissPopup];
}

- (void)getCompletedOrders:(NSString *)username {
    [Order getCompletedOrdersForUser:username :^(NSData *data, NSURLResponse *response, NSError *error) {
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
                        if (![status isEqualToString:@"completed"] && ![status isEqualToString:@"completed-awaiting"] && ![status isEqualToString:@"canceled"]) {
                            continue;
                        }
                        Order *order = [[Order alloc] init];
                        [order setOrderId:jsonOrder[@"id"]];
                        [order setUserId:jsonOrder[@"user_id"]];
                        [order setTitle:jsonOrder[@"title"]];
                        [order setDeliveryDate:jsonOrder[@"delivery_date"]];
                        if ([jsonOrder[@"pad_location"] isEqual:[NSNull null]]) {
                            [order setPadLocation:@"N/A"];
                        } else {
                            [order setPadLocation:jsonOrder[@"pad_location"]];
                        }
                        [order setStatus:status];
                        [self->_orders addObject:order];
                    }
                    [[self tableView] reloadData];
                });
            }
        }
    }];
}

// refresh control
- (void)refreshTable {
    _orders = [[NSMutableArray alloc] init];
    [self getCompletedOrders:[User.loggedInUser username]];
    [userCompletedRefreshControl endRefreshing];
    [[self tableView] reloadData];
}

// setup left swipe on cell
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    CompletedCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    if (![[[cell status] text] isEqualToString:@"Complete"] && ![[[cell status] text] isEqualToString:@"Canceled"]) {
        UIContextualAction *action = [self confirmOrder:indexPath];
        [actions addObject:action];
    }
    UISwipeActionsConfiguration *actionsConfig = [UISwipeActionsConfiguration configurationWithActions:actions];
    return actionsConfig;
}

// setup right swipe on cell
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *action = [self deleteOrder:indexPath];
    NSArray *actions = @[action];
    UISwipeActionsConfiguration *actionsConfig = [UISwipeActionsConfiguration configurationWithActions:actions];
    return actionsConfig;
}

// control for confirming an order (left swipe)
- (UIContextualAction *)confirmOrder:(NSIndexPath *)indexPath {
    Order *order = _orders[indexPath.row];
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:normal title:@"Confirm" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [order confirmOrCompleteOrder:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSError *err = nil;
            NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
            
            if (err) {
                NSLog(@"Error parsing JSON: %@", err);
            } else {
                NSLog(@"JSON: %@", jsonDictionary);
                int code = [jsonDictionary[@"code"] intValue];
                if (code != 200) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self->_popup showPopup:jsonDictionary[@"message"]];
                    });
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        CompletedCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
                        [[cell confirmedBar] setBackgroundColor:[UIColor colorNamed:@"validGreen"]];
                        [[cell status] setText:@"Completed"];
                    });
                }
            }
        }];
        completionHandler(true);
    }];
    [action setBackgroundColor: [UIColor colorNamed:@"validGreen"]];
    return action;
}

// control for deleting an order (right swipe)
- (UIContextualAction *)deleteOrder:(NSIndexPath *)indexPath {
    Order *order = _orders[indexPath.row];
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:normal title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [order deleteOrder:^(NSData *data, NSURLResponse *response, NSError *error) {
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
                        [self->_orders removeObjectAtIndex:indexPath.row];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_orders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CompletedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"completedCell" forIndexPath:indexPath];
    Order *order = _orders[indexPath.row];
    
    [[cell orderNumber] setText:[NSString stringWithFormat:@"# %@", order.orderId]];
    [[cell orderTitle] setText:order.title];
    [[cell deliveryDate] setText:order.deliveryDate];
    [[cell location] setText:order.padLocation];
    
    NSString *status = order.status;
    if ([status isEqualToString:@"completed"]) {
        [[cell status] setText:@"Complete"];
        [[cell confirmedBar] setBackgroundColor:[UIColor colorNamed:@"validGreen"]];
    } else if ([status isEqualToString:@"completed-awaiting"]) {
        [[cell status] setText:@"Awaiting Confirmation"];
        [[cell confirmedBar] setBackgroundColor:[UIColor colorNamed:@"pendingYellow"]];
    } else if ([status isEqualToString:@"canceled"]) {
        [[cell status] setText:@"Canceled"];
        [[cell confirmedBar] setBackgroundColor:[UIColor colorNamed:@"invalidRed"]];
    }
    
    return cell;
}

@end
