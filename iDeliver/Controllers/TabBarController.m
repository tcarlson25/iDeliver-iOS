//
//  TabBarController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/29/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDelegate:self];
}

- (BOOL)  tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController {
    
    NSUInteger controllerIndex = [self.viewControllers indexOfObject:viewController];
    
    if (controllerIndex == tabBarController.selectedIndex) {
        return NO;
    }
    
    UIView *fromView = tabBarController.selectedViewController.view;
    UIView *toView = [tabBarController.viewControllers[controllerIndex] view];
    
    if (fromView != toView) {
        [UIView transitionFromView:fromView toView:toView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
    }
    
    return YES;
}

@end
