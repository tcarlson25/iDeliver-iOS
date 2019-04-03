//
//  AdminPendingCell.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/24/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendButton.h"

@interface AdminPendingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *orderTitle;
@property (weak, nonatomic) IBOutlet UIView *confirmedBar;
@property (weak, nonatomic) IBOutlet UILabel *deliveryDate;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet SendButton *sendButton;

@end
