//
//  UserPendingController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/22/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "UserPendingController.h"
#import "UserPendingCell.h"
#import "Order.h"
#import "User.h"
#import "Popup.h"
#import "UserTrackController.h"

@interface UserPendingController ()
@property NSMutableArray<Order *> *orders;
@end

@implementation UserPendingController

UIRefreshControl *userPendingRefreshControl;

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
    [self getPendingOrders: [User.loggedInUser username]];
    
    // set some table settings
    [[[[self navigationController] navigationBar] topItem] setTitle:@"Pending"];
    [self.navigationController.navigationBar setPrefersLargeTitles:true];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // set refresh control
    userPendingRefreshControl = [[UIRefreshControl alloc] init];
    [userPendingRefreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [[self tableView] setRefreshControl:userPendingRefreshControl];
}

- (void)infoButtonAction {
    NSString *description = @"Pending deliveries contain orders that are awaiting admin approval, awaiting to be shipped, and in route. Tracking a shipment is only available when in route";
    NSString *swipeRightHelp = @"Swipe Right - Cancel a Delivery";
    NSString *colorCodeGreen = @"Green - Delivery is in route";
    NSString *colorCodeYellow = @"Yellow - Delivery is awaiting approval/shipment";
    [_popup showPopup:[NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@", description, swipeRightHelp, colorCodeGreen, colorCodeYellow]];
}

- (IBAction)dismissPopup:(id)sender {
    [_popup dismissPopup];
}

- (void)getPendingOrders:(NSString *)username {
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
                        if (![status isEqualToString:@"pending-approval"] && ![status isEqualToString:@"pending-shipment"] && ![status isEqualToString:@"pending-inroute"]) {
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
    [self getPendingOrders:[User.loggedInUser username]];
    [userPendingRefreshControl endRefreshing];
    [[self tableView] reloadData];
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
    Order *order = _orders[indexPath.row];
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
    UserPendingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userPendingCell" forIndexPath:indexPath];
    Order *order = _orders[indexPath.row];
    
    // setup track button
    [[cell trackButton] setOrder:order];
    [[cell trackButton] addTarget:self action:@selector(setupTrackButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [[cell orderNumber] setText:[NSString stringWithFormat:@"# %@", order.orderId]];
    [[cell orderTitle] setText:order.title];
    [[cell deliveryDate] setText:order.deliveryDate];
    [[cell location] setText:order.padLocation];
    
    NSString *status = order.status;
    [[cell confirmedBar] setBackgroundColor:[UIColor colorNamed:@"pendingYellow"]];
    if ([status isEqualToString:@"pending-approval"]) {
        [[cell status] setText:@"Awaiting Approval"];
        [[cell trackButton] setEnabled:false];
    } else if ([status isEqualToString:@"pending-shipment"]) {
        [[cell status] setText:@"Awaiting Shipment"];
        [[cell trackButton] setEnabled:false];
    } else if ([status isEqualToString:@"pending-inroute"]) {
        [[cell status] setText:@"In Route"];
        [[cell trackButton] setEnabled:true];
    }
    
    return cell;
}

- (void)setupTrackButton:(TrackButton *)sender {
    [self performSegueWithIdentifier:@"userTrackSegue" sender: sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"userTrackSegue"]) {
        UserTrackController *userTrackController = [segue destinationViewController];
        [userTrackController setOrderToTrack:[sender order]];
    }
}

@end
