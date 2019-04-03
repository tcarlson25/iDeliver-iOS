//
//  AdminCompletedController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/24/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "AdminCompletedController.h"
#import "CompletedCell.h"
#import "Order.h"
#import "User.h"
#import "Popup.h"

@interface AdminCompletedController ()
@property NSMutableDictionary *userToOrders;
@end

@implementation AdminCompletedController

UIRefreshControl *adminCompletedRefreshControl;

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
    [self getCompletedOrders];
    
    // set some table settings
    [[[[self navigationController] navigationBar] topItem] setTitle:@"Completed"];
    [self.navigationController.navigationBar setPrefersLargeTitles:true];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // set refresh control
    adminCompletedRefreshControl = [[UIRefreshControl alloc] init];
    [adminCompletedRefreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [[self tableView] setRefreshControl:adminCompletedRefreshControl];
    
    [[self tableView] setBackgroundView:nil];
    [[self tableView] setBackgroundColor:[UIColor whiteColor]];
}

- (void)infoButtonAction {
    NSString *description = @"Completed deliveries contain orders that have been successfully delivered and those that are awaiting verfication of a successful delivery. Admins can see all user's deliveries.";
    NSString *swipeRightHelp = @"Swipe Right - Delete a Delivery";
    NSString *colorCodeGreen = @"Green - Delivery is Confirmed";
    NSString *colorCodeYellow = @"Yellow - Delivery is Awaiting Confirmation from User";
    NSString *colorCodeRed = @"Red - Delivery is Canceled";
    [_popup showPopup:[NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@\n\n%@", description, swipeRightHelp, colorCodeGreen, colorCodeYellow, colorCodeRed]];
}

- (IBAction)dismissPopup:(id)sender {
    [_popup dismissPopup];
}

- (void)getCompletedOrders {
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
                        if (![status isEqualToString:@"completed"] && ![status isEqualToString:@"completed-awaiting"] && ![status isEqualToString:@"canceled"]) {
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
    [self getCompletedOrders];
    [adminCompletedRefreshControl endRefreshing];
    [[self tableView] reloadData];
}

// setup right swipe on cell
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *action = [self deleteOrder:indexPath];
    NSArray *actions = @[action];
    UISwipeActionsConfiguration *actionsConfig = [UISwipeActionsConfiguration configurationWithActions:actions];
    return actionsConfig;
}

// control for deleting an order (right swipe)
- (UIContextualAction *)deleteOrder:(NSIndexPath *)indexPath {
    NSArray<NSString *> *allKeys = [_userToOrders allKeys];
    NSString *sectionKey = [allKeys objectAtIndex:indexPath.section];
    NSMutableArray<Order *> *userOrders = [_userToOrders objectForKey:sectionKey];
    Order *order = userOrders[indexPath.row];
    
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
    CompletedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"completedCell" forIndexPath:indexPath];
    
    NSArray<NSString *> *allKeys = [_userToOrders allKeys];
    NSString *sectionKey = [allKeys objectAtIndex:indexPath.section];
    NSArray<Order *> *userOrders = [_userToOrders objectForKey:sectionKey];
    Order *order = userOrders[indexPath.row];
    
    [[cell orderNumber] setText:[NSString stringWithFormat:@"#%@", order.orderId]];
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
