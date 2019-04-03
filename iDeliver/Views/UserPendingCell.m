//
//  UserPendingCell.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/22/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "UserPendingCell.h"

@implementation UserPendingCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [self cardSetup];
}

-(void)cardSetup {
    NSInteger cornerRadius = 5;
    [self.cardView setAlpha:1];
    self.cardView.layer.masksToBounds = false;
    self.cardView.layer.cornerRadius = cornerRadius;
    self.cardView.layer.shadowOffset = CGSizeMake(0, 1.25);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:[self cardView].bounds cornerRadius:cornerRadius];
    self.cardView.layer.shadowPath = path.CGPath;
    self.cardView.layer.shadowOpacity = 0.3;
    self.cardView.layer.shadowColor = UIColor.blackColor.CGColor;
    [[self cardView] setBackgroundColor:UIColor.whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
