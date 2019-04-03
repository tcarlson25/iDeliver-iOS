//
//  Popup.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/18/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "Popup.h"

@implementation Popup

- (id)initWith:(UIWindow *)mainWindowParam :(UIView *)popupView :(UILabel *)popupMessage
{
    self = [super init];
    if (self) {
        _popupView = popupView;
        _popupMessage = popupMessage;
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [_popupView setBackgroundColor:[UIColor colorNamed:@"popupTint"]];
        _window = mainWindowParam;
        [_popupMessage sizeToFit];
        _visualEffect = _visualEffectView.effect;
        [_popupView.layer setCornerRadius:8];
        
        // add visual effect view to sublayout
        [_visualEffectView setFrame:[_window bounds]];
        [_visualEffectView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [_visualEffectView setEffect: nil];
        [_window addSubview:_visualEffectView];
        [_visualEffectView setHidden:true];
    }
    return self;
}

- (void)dismissPopup {
    [UIView animateWithDuration:0.3 animations:^{
        [self->_popupView setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
        [self->_popupView setAlpha:0];
        [self->_visualEffectView setEffect:nil];
    } completion:^(BOOL finished) {
        [self->_popupView removeFromSuperview];
        [self->_visualEffectView setHidden:true];
    }];
}

- (void)showPopup:(NSString *)message {
    [_dismissButton addTarget:self action:@selector(dismissPopup) forControlEvents:UIControlEventTouchUpInside];
    [_visualEffectView setHidden:false];
    [_popupMessage setText:message];
    [_popupView setCenter:CGPointMake([_window frame].size.width/2, [_window frame].size.height/2)];
    [_popupView setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
    [_popupView setAlpha:0];
    [_window addSubview:_popupView];
    [UIView animateWithDuration:0.4 animations:^{
        [self->_visualEffectView setEffect:self->_visualEffect];
        [self->_popupView setAlpha:1];
        [self->_popupView setTransform:CGAffineTransformIdentity];
    }];
}

@end
