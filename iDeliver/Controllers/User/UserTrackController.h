//
//  UserTrackController.h
//  iDeliver
//
//  Created by Tyler Carlson on 10/25/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>
#import "Order.h"

@interface UserTrackController : UIViewController

@property Order *orderToTrack;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end
