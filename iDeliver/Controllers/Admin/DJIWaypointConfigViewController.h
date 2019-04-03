//
//  DJIWaypointConfigViewController.h
//  GSDemo
//
//  Created by Austin Gonzalez on 10/22/18.
//  Copyright © 2018 Austin Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DJIWaypointConfigViewController;
@protocol DJIWaypointConfigViewControllerDelegate <NSObject>
- (void)cancelBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC;
- (void)finishBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC;
@end


@interface DJIWaypointConfigViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *altitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *autoFlightSpeedTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxFlightSpeedTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *actionSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *headingSegmentedControl;
@property (weak, nonatomic) id <DJIWaypointConfigViewControllerDelegate>delegate;
- (IBAction)cancelBtnAction:(id)sender;
- (IBAction)finishBtnAction:(id)sender;

@end

