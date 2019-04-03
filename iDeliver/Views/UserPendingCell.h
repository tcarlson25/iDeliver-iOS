//
//  UserPendingCell.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/22/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackButton.h"

@interface UserPendingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *orderTitle;
@property (weak, nonatomic) IBOutlet UIView *confirmedBar;
@property (weak, nonatomic) IBOutlet UILabel *deliveryDate;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet TrackButton *trackButton;

@end
