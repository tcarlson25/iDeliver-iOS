//
//  DJIMapController.h
//  GSDemo
//
//  Created by Austin Gonzalez on 10/17/18.
//  Copyright © 2018 Austin Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DJIAircraftAnnotation.h"
@interface DJIMapController : NSObject
@property (strong, nonatomic) NSMutableArray *editPoints;
@property (nonatomic, strong) DJIAircraftAnnotation* aircraftAnnotation;
/**
 *  Add Waypoints in Map View
 */
- (void)addPoint:(CGPoint)point withMapView:(MKMapView *)mapView;

/**
 * Add Landing Pad Location in Map View
*/
- (NSUInteger)addLandingPadLat:(double)latitude withLong:(double)longitude withMapView:(MKMapView *)mapView;
/**
 *  Clean All Waypoints in Map View
 */
- (void)cleanAllPointsWithMapView:(MKMapView *)mapView;
/**
 *  Current Edit Points
 *
 *  @return Return an NSArray contains multiple CCLocation objects
 */
- (NSArray *)wayPoints;

/**
 *  Update Aircraft's location in Map View
 */
-(void)updateAircraftLocation:(CLLocationCoordinate2D)location withMapView:(MKMapView *)mapView;
/**
 *  Update Aircraft's heading in Map View
 */
-(void)updateAircraftHeading:(float)heading;
@end
