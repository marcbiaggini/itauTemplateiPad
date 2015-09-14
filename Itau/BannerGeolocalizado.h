//
//  BannerGeolocalizado.h
//  testGeocoder
//
//  Created by A2works on 01/05/15.
//  Copyright (c) 2015 A2works. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import "NetworkConnectionMonitor.h"



@interface BannerGeolocalizado : NSObject<MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic, strong)CLLocation *currentLocation;
@property (nonatomic, strong)NSString  *callFunction;
@property (nonatomic, strong)NSMutableArray *bannerList;
@property (nonatomic, strong)UIViewController *viewController;
@property (nonatomic, strong) NetworkConnectionMonitor *networkMonitor;
@property (nonatomic, strong) NSMutableArray *bannerListData;






-(BOOL) setVersioniOS;
-(void)CurrentLocationIdentifier:(NSString *) call;
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)requestAlwaysAuthorization;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)getBanner:(CLPlacemark *)placemarks;
-(void)downloadBanner:(CLPlacemark *)placemarks;





@end
