//
//  DJIAircraftAnnotation.h
//  GSDemo
//
//  Created by Austin Gonzalez on 10/19/18.
//  Copyright © 2018 Austin Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DJIAircraftAnnotationView.h"

@interface DJIAircraftAnnotation : NSObject<MKAnnotation>
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, weak) DJIAircraftAnnotationView* annotationView;
-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate;
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
-(void) updateHeading:(float)heading;
@end
