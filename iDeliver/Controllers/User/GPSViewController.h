//
//  GPSViewController.h
//  iDeliver
//
//  Created by Krista Capps on 10/31/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#ifndef GPSViewController_h
#define GPSViewController_h
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <DJISDK/DJISDK.h>
#import "Popup.h"

@interface GPSViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UILabel *popupMessage;

@property Popup *popup;
@property UIWindow *mainWindow;

- (IBAction)dismissPopup:(id)sender;
- (void)focusMap;

@end


#endif /* GPSViewController_h */
