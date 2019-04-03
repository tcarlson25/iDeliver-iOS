//
//  UserTrackController.m
//  iDeliver
//
//  Created by Tyler Carlson on 10/25/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import "UserTrackController.h"
#import "DJIAircraftAnnotationView.h"
#import "DJIAircraftAnnotation.h"

@interface UserTrackController ()

@property DJIAircraftAnnotation *currentAnnotation;

@end

@implementation UserTrackController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_mapView setDelegate:self];
    [_mapView setMapType:MKMapTypeStandard];
    
    // setup refresh button
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonAction)];
    [self.navigationItem setRightBarButtonItem:refreshButton animated:YES];

    // TODO: update coordinates dynamically from db later
    double latitude = 30.622370;
    double longitude = -96.325851;
    [self updateDroneLoc:latitude :longitude];
}

- (void)refreshButtonAction {
    double latitude = 30.632370;
    double longitude = -96.335851;
    [self updateDroneLoc:latitude :longitude];
}

- (void)updateDroneLoc:(double)latitude :(double) longitude {
    CLLocationCoordinate2D droneCord = CLLocationCoordinate2DMake(latitude, longitude);
    if (CLLocationCoordinate2DIsValid(droneCord)) {
        MKCoordinateRegion region = {0};
        region.center = droneCord;
        region.span.latitudeDelta = 0.005;
        region.span.longitudeDelta = 0.005;
        
        [self.mapView setRegion:region animated:YES];
        
        _currentAnnotation = [[DJIAircraftAnnotation alloc] init];
        [_currentAnnotation setCoordinate:droneCord];
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotation:_currentAnnotation];
    }
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // Don't do anything if it's the user's location point
    if([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    
    DJIAircraftAnnotationView* pin = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"droneCurrentLoc"];
    return pin;
}

@end
