//
//  UserSettingsTableViewController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/15/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "UserSettingsTableViewController.h"
#import "AppDelegate.h"
#import "User.h"

@interface UserSettingsTableViewController ()

@end

@implementation UserSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[[self navigationController] navigationBar] topItem] setTitle:@"Settings"];
    [self.navigationController.navigationBar setPrefersLargeTitles:true];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 0 && row == 0) {
        if (User.loggedInUser.pad.padId == nil || User.loggedInUser.pad.padId == (id)[NSNull null]) {
            [self performSegueWithIdentifier:@"userSettings-noPL-segue" sender: self];
        } else {
            [self performSegueWithIdentifier:@"userSettings-PL-segue" sender: self];
        }
    } else if (section == 1 && row == 0) {
        [User setLoggedInUser:nil];
        UIViewController *loginScreen = [[self storyboard] instantiateViewControllerWithIdentifier:@"initialNav"];
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        [[appDelegate window] setRootViewController:loginScreen];
    }
}


@end
