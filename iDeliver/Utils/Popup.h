//
//  Popup.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/18/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Popup : NSObject

@property UIView *popupView;
@property UILabel *popupMessage;
@property UIVisualEffectView *visualEffectView;
@property UIButton *dismissButton;
@property UIVisualEffect *visualEffect;
@property UIWindow *window;

- (id)initWith :(UIWindow *)mainWindowParam :(UIView *)popupView :(UILabel *)popupMessage;
- (void)dismissPopup;
- (void)showPopup:(NSString *)message;

@end
