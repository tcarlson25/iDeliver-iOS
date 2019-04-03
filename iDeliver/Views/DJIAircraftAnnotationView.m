//
//  DJIAircraftAnnotationView.m
//  GSDemo
//
//  Created by Austin Gonzalez on 10/19/18.
//  Copyright © 2018 Austin Gonzalez. All rights reserved.
//

#import "DJIAircraftAnnotationView.h"

@implementation DJIAircraftAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.enabled = NO;
        self.draggable = NO;
        self.image = [UIImage imageNamed:@"aircraft"];
    }
    
    return self;
}
-(void) updateHeading:(float)heading
{
    self.transform = CGAffineTransformIdentity;
    self.transform = CGAffineTransformMakeRotation(heading);
}

@end
