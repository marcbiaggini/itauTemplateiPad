//
//  ViewController.h
//  Itau
//
//  Created by Pérsio on 28/04/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileSidebar.h"
#import "BannerGeolocalizado.h"
#import "NetworkConnectionMonitor.h"
#import "SetupWidgets.h"
#import "Clock.h"


@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *logoApp;
@property (weak, nonatomic) IBOutlet UILabel *local;
@property (weak, nonatomic) IBOutlet UIImageView *localIcon;

@property (weak, nonatomic) IBOutlet UILabel *dateTime;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong,nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet ProfileSidebar *sidebarPersio;
@property (strong, nonatomic) SetupWidgets *setUpWidgets;
@property (nonatomic, strong) NSMutableArray *bannerList;
@property (nonatomic, strong) NetworkConnectionMonitor *networkMonitor;
@property (strong, nonatomic) NSLayoutConstraint *originalPopUpOrientation;
@property (assign, nonatomic) BOOL isModified;

@property (weak, nonatomic) IBOutlet UIView *attButtonWrapper;
@property (weak, nonatomic) IBOutlet UIView *magButtonWrapper;

-(void)removeNotificationApp;

@end

