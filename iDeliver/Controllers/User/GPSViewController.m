//
//  GPSViewController.m
//  iDeliver
//
//  Created by Krista Capps on 10/31/18.
//  Copyright © 2018 Tyler Carlson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "GPSViewController.h"
#import "UserMapController.h"
#import <MapKit/MapKit.h>
#import "User.h"
#import "Pad.h"

@interface GPSViewController() <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UserMapController *mapController;
@property (nonatomic, assign)BOOL isEditingPoints;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, weak) IBOutlet UIButton *focusBtn;
- (IBAction)focusMapAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *padLocation;
- (IBAction)updatePadPressed:(id)sender;
@property MKPointAnnotation *currentAnnotation;

@end

@implementation GPSViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startUpdateLocation];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mainWindow = [UIApplication sharedApplication].keyWindow;
    _popup = [[Popup alloc] initWith:_mainWindow :_popupView :_popupMessage];
   
    self.userLocation = kCLLocationCoordinate2DInvalid;
   
    self.mapController = [[UserMapController alloc] init];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addWaypoints:)];
    [self.mapView addGestureRecognizer:self.tapGesture];
    if (User.loggedInUser.pad.padLocation != (id)[NSNull null] && User.loggedInUser.pad.padLocation != nil) {
        [_padLocation setText:[User.loggedInUser.pad padLocation]];
        [self updatePin];
        [self focusMap];
    } else {
        [_padLocation setText:@"N/A"];
        [_focusBtn setEnabled:false];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (IBAction)dismissPopup:(id)sender {
    [_popup dismissPopup];
}

#pragma mark CLLocation Methods
-(void) startUpdateLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        if (self.locationManager == nil) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = 0.1;
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            [self.locationManager startUpdatingLocation];
        }
    }else
    {
        [self->_popup showPopup:@"Location Service is not available"];
    }
}

- (void)focusMap {
    NSString* myString = [User.loggedInUser.pad padLocation];
    NSArray* myArray = [myString  componentsSeparatedByString:@","];
    NSString* latString = [myArray objectAtIndex:0];
    NSString* longString = [myArray objectAtIndex:1];
    CLLocationCoordinate2D padCoord = CLLocationCoordinate2DMake([latString doubleValue], [longString doubleValue]);
    
    if (CLLocationCoordinate2DIsValid(padCoord)) {
        MKCoordinateRegion region = {0};
        region.center = padCoord;
        region.span.latitudeDelta = 0.003;
        region.span.longitudeDelta = 0.003;
        [self.mapView setRegion:region animated:YES];
    }
}

- (void)updatePin {
    NSString* myString = [User.loggedInUser.pad padLocation];
    NSArray* myArray = [myString  componentsSeparatedByString:@","];
    NSString* latString = [myArray objectAtIndex:0];
    NSString* longString = [myArray objectAtIndex:1];
    CLLocationCoordinate2D padCoord = CLLocationCoordinate2DMake([latString doubleValue], [longString doubleValue]);
    
    if (CLLocationCoordinate2DIsValid(padCoord)) {
        _currentAnnotation = [[MKPointAnnotation alloc] init];
        [_currentAnnotation setCoordinate:padCoord];
        [_currentAnnotation setTitle:@"Pad Location"];
        [self.mapView addAnnotation:_currentAnnotation];
    }
}

- (IBAction)focusMapAction:(id)sender
{
    [self focusMap];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    self.userLocation = location.coordinate;
}

#pragma mark Custom Methods
- (void)addWaypoints:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.mapView];
   
    if(tapGesture.state == UIGestureRecognizerStateEnded){
        if (self.isEditingPoints) {
            [self.mapController addPoint:point withMapView:self.mapView];
        }
    }
}

#pragma mark MKMapViewDelegate Method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin_Annotation"];
        [pinView setPinTintColor:MKPinAnnotationView.purplePinColor];
        return pinView;
       
    }
   
    return nil;
}
- (IBAction)updatePadPressed:(id)sender {
    [Pad updatePadLocation:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSError *err = nil;
        NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
        
        if (err) {
            NSLog(@"Error parsing JSON: %@", err);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self->_popup showPopup:[err localizedDescription]];
            });
        } else {
            NSLog(@"JSON: %@", jsonDictionary);
            NSArray *feeds = jsonDictionary[@"feeds"];
            NSArray *reverseFeeds = [[feeds reverseObjectEnumerator] allObjects];
            NSString *foundLatitude;
            NSString *foundLongitude;
            BOOL foundFeed = FALSE;
            for (NSDictionary *feed in reverseFeeds) {
                NSString *field3 = feed[@"field3"];
                if (field3 == nil || field3 == (id)[NSNull null]) {
                    continue;
                } else if ([field3 isEqualToString:[User.loggedInUser.pad padId]]) {
                    foundLatitude = feed[@"field1"];
                    foundLongitude = feed[@"field2"];
                    foundFeed = TRUE;
                    break;
                }
            }
            if (foundFeed) {
                // update user pad location in db
                [User.loggedInUser.pad updatePadLocationDB:[NSString stringWithFormat:@"%@, %@", foundLatitude, foundLongitude] :^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    NSError *err = nil;
                    NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
                    
                    if (err) {
                        NSLog(@"Error parsing JSON: %@", err);
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self->_popup showPopup:[err localizedDescription]];
                        });
                    } else {
                        NSLog(@"JSON: %@", jsonDictionary);
                        int code = [jsonDictionary[@"code"] intValue];
                        if (code != 200) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self->_popup showPopup:jsonDictionary[@"message"]];
                            });
                        } else {
                            NSString *foundLocation = [NSString stringWithFormat:@"%@, %@", foundLatitude, foundLongitude];
                            if ([foundLocation isEqualToString:User.loggedInUser.pad.padLocation]) {
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self->_popup showPopup:@"Current Pad Location is already the most updated version."];
                                });
                            } else {
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [User.loggedInUser.pad setPadLocation:foundLocation];
                                    [self->_padLocation setText:User.loggedInUser.pad.padLocation];
                                    [self->_focusBtn setEnabled:true];
                                    [self.mapView removeAnnotations:self.mapView.annotations];
                                    [self updatePin];
                                    [self focusMap];
                                });
                            }
                        }
                    }
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_popup showPopup:@"No Location found on file."];
                });
            }
        }
    }];
}

@end
