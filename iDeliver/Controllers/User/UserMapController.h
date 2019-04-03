//
//  UserMapController.h
//  iDeliver
//
//  Created by Krista Capps on 10/24/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#ifndef UserMapController_h
#define UserMapController_h
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface UserMapController : NSObject
@property (strong, nonatomic) NSMutableArray *editPoints;
/**
 *  Add Waypoints in Map View
 */
- (void)addPoint:(CGPoint)point withMapView:(MKMapView *)mapView;
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
@end

#endif /* UserMapController_h */
