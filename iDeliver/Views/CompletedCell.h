//
//  CompletedCell.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/16/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompletedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *orderTitle;
@property (weak, nonatomic) IBOutlet UIView *confirmedBar;
@property (weak, nonatomic) IBOutlet UILabel *deliveryDate;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *location;

@end
