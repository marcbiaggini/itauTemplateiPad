//
//  SpalshViewController.h
//  Itau
//
//  Created by A2works on 13/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BannerGeolocalizado.h"
#import "NetworkConnectionMonitor.h"
#import "LoginViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "UIColor+Itau.h"




@interface SpalshViewController : UIViewController
@property (strong, nonatomic) BannerGeolocalizado *banner;
@property (strong, nonatomic) NSString *bannerIsDownloaded;
@property (strong, nonatomic) NSString *bannerIsReady;
@property (nonatomic, strong) NSMutableArray *bannerList;
@property (nonatomic, strong) NSMutableArray *bannerListData;
@property (nonatomic, strong) NetworkConnectionMonitor *networkMonitor;
@property (assign, atomic) int timeout;
@property (assign, atomic) BOOL transition;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *askingBanner;
@property (weak, nonatomic) IBOutlet UIImageView *itauSplashImage;
@property (weak, nonatomic) IBOutlet UIImageView *itauSplashBackground;

-(void)setupSplash;







@end
