//
//  MapasTelefonesViewController.h
//  testGeocoder
//
//  Created by A2works on 05/05/15.
//  Copyright (c) 2015 A2works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import "BannerGeolocalizado.h"
#import "XMLReader.h"
#import "UIColor+Itau.h"
#import "AFNetworkReachabilityManager.h"



@interface AttendanceViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

-(IBAction)toggleAccordeonView:(UIButton *)sender;










@property (weak, nonatomic) IBOutlet UILabel *SACItau;
@property (weak, nonatomic) IBOutlet UILabel *Ouviduria;
@property (weak, nonatomic) IBOutlet UILabel *itauNoTelefone;
@property (weak, nonatomic) IBOutlet UIButton *btnArrow;
@property (weak, nonatomic) IBOutlet MKMapView *mapItau;

@property (strong, nonatomic) IBOutlet UIView *accordeonView;
@property (assign,nonatomic)  UIInterfaceOrientation orientationDefault;
@property (strong,nonatomic)  NSMutableArray *popoverArrayY;

@property (assign, nonatomic) double moveToPositionY;
@property (assign, nonatomic) double originalPositionY;
@property (assign, nonatomic) double originalPositionPortrait;
@property (assign, nonatomic) double originalPositionLandScape;
@property (nonatomic,strong) BannerGeolocalizado *banner;
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic, strong)CLLocation *currentLocation;
@property (nonatomic, strong)CLPlacemark *topResult;
@property (nonatomic, strong)MKPlacemark *pinMark;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, strong) NetworkConnectionMonitor *networkMonitor;
@property (nonatomic, strong) NSMutableArray *agencyIcon;


-(void)setupMapasView;





@end
