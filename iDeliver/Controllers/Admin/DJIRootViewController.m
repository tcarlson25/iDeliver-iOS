//
//  DJIRootViewController.m
//  GSDemo
//
//  Created by Austin Gonzalez on 10/17/18.
//  Copyright © 2018 Austin Gonzalez. All rights reserved.
//

#import "DJIRootViewController.h"
#import "DJIMapController.h"
#import <DJISDK/DJISDK.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DemoUtility.h"
#import "DJIGSButtonViewController.h"
#import "DJIWaypointConfigViewController.h"
#define kEnterNaviModeFailedAlertTag 1001

//double getPadLatitude(){
//    double latVal = ThingSpeak.readLongField(myChannelNumber, 1, myWriteAPIKey);
//    return latVal;
//}
//
//double getPadLongitude(){
//    double longVal = ThingSpeak.readLongField(myChannelNumber, 2, myWriteAPIKey);
//    return longVal;
//}

@interface DJIRootViewController() <DJIGSButtonViewControllerDelegate, DJIWaypointConfigViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate, DJIFlightControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, assign)BOOL isEditingPoints;

//View Controllers
@property (nonatomic, strong)DJIGSButtonViewController *gsButtonVC;
@property (nonatomic, strong)DJIWaypointConfigViewController *waypointConfigVC;

//add Map Controller stuff
@property (nonatomic, strong) DJIMapController *mapController;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

//handle user location
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;

//Drone Visual Data
@property (strong, nonatomic) IBOutlet UILabel *modeLabel;
@property (strong, nonatomic) IBOutlet UILabel *gpsLabel;
@property (strong, nonatomic) IBOutlet UILabel *hsLabel;
@property (strong, nonatomic) IBOutlet UILabel *vsLabel;
@property (strong, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (nonatomic, assign) CLLocationCoordinate2D droneLocation;

//UI
@property (weak, nonatomic) IBOutlet UIView *topBarView;

//DJI Waypoint Mission
@property(nonatomic, strong) DJIMutableWaypointMission* waypointMission;

//Index of landing pad
@property(nonatomic) NSUInteger lp_index;
@property(nonatomic) NSUInteger midpoint_index;

@end


@implementation DJIRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerApp];
    _orderToDeliver = [[Order alloc] init];
    [self.navigationController.navigationBar.topItem setTitle:@"Deliver"];
    [self.navigationController.navigationBar setPrefersLargeTitles:true];
    
    [self initUI];
    [self initData];
    [_mapView setDelegate:self];

}

-(void) initUI
{
    [self.view bringSubviewToFront: _topBarView];
    self.modeLabel.text = @"N/A";
    self.gpsLabel.text = @"0";
    self.vsLabel.text = @"0.0 M/S";
    self.hsLabel.text = @"0.0 M/S";
    self.altitudeLabel.text = @"0 M";
    
    self.gsButtonVC = [[DJIGSButtonViewController alloc] initWithNibName:@"DJIGSButtonViewController" bundle:[NSBundle mainBundle]];
    [self.gsButtonVC.view setFrame:CGRectMake(0, self.topBarView.frame.origin.y + self.topBarView.frame.size.height + 100, self.gsButtonVC.view.frame.size.width, self.gsButtonVC.view.frame.size.height + 100)];
    self.gsButtonVC.delegate = self;
    [self.view addSubview:self.gsButtonVC.view];
    
    self.waypointConfigVC = [[DJIWaypointConfigViewController alloc] initWithNibName:@"DJIWaypointConfigViewController" bundle:[NSBundle mainBundle]];
    self.waypointConfigVC.view.alpha = 0;
    
    self.waypointConfigVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    CGFloat configVCOriginX = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.waypointConfigVC.view.frame))/2;
    CGFloat configVCOriginY = CGRectGetHeight(self.topBarView.frame) + CGRectGetMinY(self.topBarView.frame) + 50;
    
    [self.waypointConfigVC.view setFrame:CGRectMake(configVCOriginX, configVCOriginY, CGRectGetWidth(self.waypointConfigVC.view.frame), CGRectGetHeight(self.waypointConfigVC.view.frame))];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) //Check if it's using iPad and center the config view
    {
        self.waypointConfigVC.view.center = self.view.center;
    }
    self.waypointConfigVC.delegate = self;
    [self.view addSubview:self.waypointConfigVC.view];

}

//remove keyboard once done entering parameters
- (void) hideKeyboardAfterDone{
    [self.view endEditing:YES];
}

- (void)focusMap
{
    if (CLLocationCoordinate2DIsValid(self.droneLocation)) {
        MKCoordinateRegion region = {0};
        region.center = self.droneLocation;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        [self.mapView setRegion:region animated:YES];
    }
}

- (void)registerApp
{
    //Please enter your App key in the info.plist file to register the app.
    [DJISDKManager registerAppWithDelegate:self];
}

-(void)initData
{
    self.userLocation = kCLLocationCoordinate2DInvalid;
    self.droneLocation = kCLLocationCoordinate2DInvalid;
    
    self.mapController = [[DJIMapController alloc] init];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addWaypoints:)];
    [self.mapView addGestureRecognizer:self.tapGesture];
}

#pragma mark DJISDKManagerDelegate Methods
- (void)appRegisteredWithError:(NSError *)error
{
    if (error){
        NSString *registerResult = [NSString stringWithFormat:@"Registration Error:%@", error.description];
        ShowMessage(@"Registration Result", registerResult, nil, @"OK");
    }
    else{
        [DJISDKManager startConnectionToProduct];
    }
}
- (void)productConnected:(DJIBaseProduct *)product
{
    if (product){
        DJIFlightController* flightController = [DemoUtility fetchFlightController];
        if (flightController) {
            flightController.delegate = self;
        }
    }else{
        ShowMessage(@"Product disconnected", nil, nil, @"OK");
    }
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
        pinView.pinTintColor = [MKPinAnnotationView purplePinColor];
        return pinView;
        
    }else if ([annotation isKindOfClass:[DJIAircraftAnnotation class]])
    {
        DJIAircraftAnnotationView* annoView = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Aircraft_Annotation"];
        ((DJIAircraftAnnotation*)annotation).annotationView = annoView;
        return annoView;
    }
    
    return nil;
}

#pragma mark DJIFlightControllerDelegate
- (void)flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state
{
    self.droneLocation = state.aircraftLocation.coordinate;
    
    self.modeLabel.text = state.flightModeString;
    self.gpsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)state.satelliteCount];
    self.vsLabel.text = [NSString stringWithFormat:@"%0.1f M/S",state.velocityZ];
    self.hsLabel.text = [NSString stringWithFormat:@"%0.1f M/S",(sqrtf(state.velocityX*state.velocityX + state.velocityY*state.velocityY))];
    self.altitudeLabel.text = [NSString stringWithFormat:@"%0.1f M",state.altitude];
    
    [self.mapController updateAircraftLocation:self.droneLocation withMapView:self.mapView];
    double radianYaw = RADIAN(state.attitude.yaw);
    [self.mapController updateAircraftHeading:radianYaw];
}

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

- (BOOL)prefersStatusBarHidden {
    return NO;
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
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Service is not available" message:@"GSDemo uses your location to help plan DJI drone flights." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                             {
                                 //BUTTON OK CLICK EVENT
                             }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}



#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    self.userLocation = location.coordinate;
}


#pragma mark - DJIGSButtonViewController Delegate Methods

- (void)clearBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self.mapController cleanAllPointsWithMapView:self.mapView];
}
- (void)focusMapBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self focusMap];
}
- (void)configBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC {
    WeakRef(weakSelf);
    
    NSArray* wayPoints = self.mapController.wayPoints;
    if (wayPoints == nil || wayPoints.count < 2) { //DJIWaypointMissionMinimumWaypointCount is 2.
        ShowMessage(@"No or not enough waypoints for mission", @"", nil, @"OK");
        return;
    }
    
    //add logic to check if there's a minimum of 6 satellites
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 1.0;
    }];
    
    if (self.waypointMission){
        [self.waypointMission removeAllWaypoints];
    }
    else{
        self.waypointMission = [[DJIMutableWaypointMission alloc] init];
    }
    
    for (int i = 0; i < wayPoints.count; i++) {
        CLLocation* location = [wayPoints objectAtIndex:i];
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            DJIWaypoint* waypoint = [[DJIWaypoint alloc] initWithCoordinate:location.coordinate];
            [self.waypointMission addWaypoint:waypoint];
        }
    }
}
- (void)startBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC{
    [[self missionOperator] startMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            ShowMessage(@"Start Mission Failed", error.description, nil, @"OK");
        } else {
            // update order in db
            [self->_orderToDeliver shipOrder:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSString *requestResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSError *err = nil;
                NSData *jsonData = [requestResponse dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
                
                if (err) {
                    NSLog(@"Error parsing JSON: %@", err);
                } else {
                    NSLog(@"JSON: %@", jsonDictionary);
                    int code = [jsonDictionary[@"code"] intValue];
                    if (code != 200) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            ShowMessage(@"", jsonDictionary[@"message"], nil, @"OK");
                        });
                    } else {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            // logic for a successful start goes in here
                            ShowMessage(@"", @"Mission Started", nil, @"OK");
                        });
                    }
                }
            }];
        }
    }];
}
- (void)stopBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC{
    [[self missionOperator] stopMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            NSString* failedMessage = [NSString stringWithFormat:@"Stop Mission Failed: %@", error.description];
            ShowMessage(@"", failedMessage, nil, @"OK");
        }else
        {
            ShowMessage(@"", @"Stop Mission Finished", nil, @"OK");
        }
    }];
}


- (void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if (mode == DJIGSViewMode_EditMode) {
        [self focusMap];
    }
}
- (void)addBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if (self.isEditingPoints) {
        self.isEditingPoints = NO;
        [button setTitle:@"Add" forState:UIControlStateNormal];
    }else
    {
        self.isEditingPoints = YES;
        [button setTitle:@"Finished" forState:UIControlStateNormal];
    }
}

- (void)addPadBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC {
    if (self.isEditingPoints){
        NSString *padLocation = _orderToDeliver.padLocation;
        NSArray *coordinates = [padLocation componentsSeparatedByString:@","];
        double pad_latitude = [[coordinates objectAtIndex:0] doubleValue];
        double pad_longitude = [[coordinates objectAtIndex:1] doubleValue];
        
        //Call function which returns a lat, long coordinate
        _lp_index = [self.mapController addLandingPadLat:pad_latitude withLong:pad_longitude withMapView:self.mapView];
        _midpoint_index = _lp_index - 1;
    }
}


#pragma mark - DJIWaypointConfigViewControllerDelegate Methods
- (void)cancelBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC
{
    WeakRef(weakSelf);
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
    [self hideKeyboardAfterDone];
}

-(DJIWaypointMissionOperator *)missionOperator {
    return [DJISDKManager missionControl].waypointMissionOperator;
}

- (void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)finishBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC
{
    WeakRef(weakSelf);
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
    
    for (int i = 0; i < self.waypointMission.waypointCount; i++) {
        DJIWaypoint* waypoint = [self.waypointMission waypointAtIndex:i];
        waypoint.altitude = [self.waypointConfigVC.altitudeTextField.text floatValue];
        
    }
    
    self.waypointMission.maxFlightSpeed = [self.waypointConfigVC.maxFlightSpeedTextField.text floatValue];
    self.waypointMission.autoFlightSpeed = [self.waypointConfigVC.autoFlightSpeedTextField.text floatValue];
    self.waypointMission.headingMode = (DJIWaypointMissionHeadingMode)self.waypointConfigVC.headingSegmentedControl.selectedSegmentIndex;
    [self.waypointMission setFinishedAction:(DJIWaypointMissionFinishedAction)self.waypointConfigVC.actionSegmentedControl.selectedSegmentIndex];
    [[self missionOperator] loadMission:self.waypointMission];
    
    WeakRef(target);
    
    [[self missionOperator] addListenerToFinished:self withQueue:dispatch_get_main_queue() andBlock:^(NSError * _Nullable error) {
        
        WeakReturn(target);
        
        if (error) {
            [target showAlertViewWithTitle:@"Mission Execution Failed" withMessage:[NSString stringWithFormat:@"%@", error.description]];
        }
        else {
            [target showAlertViewWithTitle:@"Mission Execution Finished" withMessage:nil];
        }
    }];
    [[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            NSString* uploadError = [NSString stringWithFormat:@"Upload Mission failed:%@", error.description];
            ShowMessage(@"", uploadError, nil, @"OK");
        }else {
            ShowMessage(@"", @"Upload Mission Finished", nil, @"OK");
        }
    }];
    [self hideKeyboardAfterDone];
}

@end
