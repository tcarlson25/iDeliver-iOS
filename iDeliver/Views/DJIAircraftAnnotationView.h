//
//  DJIAircraftAnnotationView.h
//  GSDemo
//
//  Created by Austin Gonzalez on 10/19/18.
//  Copyright © 2018 Austin Gonzalez. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIAircraftAnnotationView : MKAnnotationView
-(void) updateHeading:(float)heading;
@end
