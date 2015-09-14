//
//  SpalshViewController.m
//  Itau
//
//  Created by A2works on 13/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "SpalshViewController.h"
#import "UIImage+Itau.h"

@interface SpalshViewController ()
@property (assign, atomic) BOOL localPermission;

@end

@implementation SpalshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.banner = [[BannerGeolocalizado alloc] init];
    self.localPermission = NO;
    [self.banner CurrentLocationIdentifier:@"banner"];
    [self setupSplash];
    self.timer = [[NSTimer alloc] init];
    self.timeout = 0;
    self.transition = NO;
    self.bannerIsReady = [[NSString alloc] init];
    self.bannerIsDownloaded = [[NSString alloc] init];
    self.bannerList = [[NSMutableArray alloc] init];
    self.bannerListData = [[NSMutableArray alloc] init];
    self.networkMonitor = [[NetworkConnectionMonitor alloc] init];
    self.askingBanner = @"NO";
    [self addTransitionObserver];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countTime:) userInfo:nil repeats:YES];
    [self.timer fire];

}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];

    
    
    
}


-(BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Observer for transition to next view
- (void)addTransitionObserver
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(askBannerIsReady:)
                                                 name:nil object:nil];

    
}

//Setup Splash image for target
-(void)setupSplash
{
    [self.itauSplashImage setImage:[UIImage targetedImageNamed:@"Brand"]];
    [self.itauSplashBackground setImage:[UIImage targetedImageNamed:@"BgLaunchScreen"]];
}


//Looking for Banner
- (void)askBannerIsReady:(NSNotification*)aNotification
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {

        if([self.networkMonitor getWifiStatus]&&self.timeout<10)
        {
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
            
            self.bannerIsReady  = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",identifier,@"bannerIsReady"]];
            
            if([self.bannerIsReady isEqualToString:@"YES"])
            {
                self.bannerIsDownloaded = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",identifier,@"DownloadComplete"]];
                
                
                if ([self.bannerIsDownloaded isEqual:@"YES"]&&self.bannerIsDownloaded!=nil)
                {
                    if(self.transition==NO){
                        
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
                        
                        
                        self.transition = YES;
                        dispatch_async(dispatch_get_main_queue(), ^(void)
                                       {
                                           [self performSegueWithIdentifier:@"SplashtoLogin" sender: self];
                                           
                                       });
                    }
                    
                }
            }
        }else
        {
            if(self.transition==NO){
                [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
                
               
                [self.timer invalidate];
                self.timer = nil;
                self.transition = YES;
                dispatch_async(dispatch_get_main_queue(), ^(void)
                               {            [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
                                   
                                   [self performSegueWithIdentifier:@"SplashtoLogin" sender: self];
                                   
                               });
                
                
                
            }
        }
        
        
        
    }else if (!self.localPermission){
        self.localPermission=YES;
        [self.banner requestAlwaysAuthorization];
    }
    
    
}

//Set timeout to go to next View
-(void)countTime:(NSTimer *)time
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    self.timeout+=1;
    if(self.timeout>2&&self.transition==NO&&status==kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self.timer invalidate];
        self.timer = nil;
        self.transition = YES;
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {            [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
                           
                           [self performSegueWithIdentifier:@"SplashtoLogin" sender: self];
                           
                       });
    }

    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString *version = [[UIDevice currentDevice] systemVersion];
    BOOL isAtLeast7 = [version floatValue] <= 7.1;
    BOOL isAtLeast8 = [version floatValue] >= 8.0;
    if(isAtLeast7){
        if ([segue.identifier isEqualToString:@"SplashtoLogin"])
        {   UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
            LoginViewController *dest = (LoginViewController *)nav.topViewController;
            [dest removeNotificationApp];
            
            
            
        }
    }else if(isAtLeast8)
    {
        if ([segue.identifier isEqualToString:@"SplashtoLogin"])
        {
            [[self navigationController] popToRootViewControllerAnimated:NO];
                [[segue destinationViewController]removeNotificationApp];
          
        }
    }
}


@end
