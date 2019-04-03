//
//  AdminSettingsTableViewController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/15/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "AdminSettingsTableViewController.h"
#import "AppDelegate.h"
#import "User.h"

@interface AdminSettingsTableViewController ()

@end

@implementation AdminSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[[self navigationController] navigationBar] topItem] setTitle:@"Settings"];
    [self.navigationController.navigationBar setPrefersLargeTitles:true];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 0 && row == 0) {
        [User setLoggedInUser:nil];
        UIViewController *loginScreen = [[self storyboard] instantiateViewControllerWithIdentifier:@"initialNav"];
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        [[appDelegate window] setRootViewController:loginScreen];
    }
}

@end
