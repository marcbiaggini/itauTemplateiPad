//
//  ViewController.m
//  Itau
//
//  Created by Pérsio on 28/04/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginViewController.h"
#import "AppConfigReader.h"
#import "UIImage+Itau.h"
#import "TagView.h"
#import "InfoViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LoginViewController () <UIAlertViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sidebarLeftConstraint;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation LoginViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.setUpWidgets = [[SetupWidgets alloc] init];

    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    
    self.dateTime.adjustsFontSizeToFitWidth = YES;
    self.dateTime.text = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",identifier,@"setTime"]];

    self.local.hidden = YES;
    self.localIcon.hidden = YES;
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    }
    
    [self.setUpWidgets addShadow:self.localIcon];
    
    [self.setUpWidgets addShadow:self.dateTime];
    [self.setUpWidgets addShadow:self.local];
//    [self.setUpWidgets addCornerRadius:self.atendimentoButton];
//    [self.setUpWidgets addShadow:self.atendimentoButton];

    self.bannerList = [[NSMutableArray alloc] init];
    //self.originalPopUpOrientation = self.sidebar.centerYPopUpConstraint;

    [self.logoApp setImage:[UIImage targetedImageNamed:@"Brand"]];
    //[self setBgMotionEffects];
    [self updateBgImageViewToInterfaceOrientation:self.interfaceOrientation];
    [self hideSidebar:NO];
    [self setClock];
    [self setupBannerObserver];
    
    TagView *attButton = [[TagView alloc] initWithTitle:@"atendimento" image:[UIImage targetedImageNamed:@"bt_seta_direita"]];
    [self.attButtonWrapper addSubview:attButton];
    self.attButtonWrapper.clipsToBounds = YES;
    
    [self.setUpWidgets addShadow:self.magButtonWrapper];
    [self.setUpWidgets addCornerRadius:self.attButtonWrapper];
    
    [[attButton.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self performSegueWithIdentifier:@"AttendanceSegue" sender:nil];
    }];
    
    if ([identifier isEqualToString:@"ipad"]) {
        
        TagView *magButton = [[TagView alloc] initWithTitle:@"Revista Personnalité" image:[UIImage targetedImageNamed:@"bt_link"]];
        self.magButtonWrapper.clipsToBounds = YES;
        
        [self.setUpWidgets addShadow:self.magButtonWrapper];
        [self.setUpWidgets addCornerRadius:self.magButtonWrapper];
        
        [self.magButtonWrapper addSubview:magButton];
        
        [[magButton.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            NSURL *magPackageURL = [NSURL URLWithString:@"dps.b6ab7934086840b8b907f848360f1f06://"];
            NSURL *magiTunesURL = [NSURL URLWithString:@"https://itunes.apple.com/br/app/revista-personnalite/id473527835?mt=8"];
            
            if ([[UIApplication sharedApplication] canOpenURL:magPackageURL]) {
                [[UIApplication sharedApplication] openURL:magPackageURL];
            } else {
                [[UIApplication sharedApplication] openURL:magiTunesURL];
            }
        }];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *place = [placemarks lastObject];
        
        if (place != nil) {
            
            [self.locationManager stopUpdatingLocation];
            
            self.local.text = place.locality;
            self.local.accessibilityLabel = [NSString stringWithFormat:@"Localidade atual: %@", place.locality];
            
            self.localIcon.hidden = NO;
            self.local.hidden = NO;
        }
        
    }];
}

- (void)setupBannerObserver {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBanner:)
                                                 name:nil object:nil];
    
    
}

- (void)setBanner:(NSNotification*)aNotification
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",identifier,@"DownloadComplete"]]  isEqual:@"YES"])
    {
        
        self.bannerList = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",identifier,@"Banner"]] mutableCopy];
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(self.bannerList.count!=0&&self.bannerList!=nil)
        {
            if(orientation ==UIInterfaceOrientationPortrait || orientation ==UIInterfaceOrientationPortraitUpsideDown)
            {
                UIImage *bgImage = [UIImage imageWithData: [self.bannerList objectAtIndex:0]];
                [self.bgImageView setImage:bgImage];
                
            }else if(orientation==UIInterfaceOrientationLandscapeLeft || orientation==UIInterfaceOrientationLandscapeRight)
            {       UIImage *bgImage = [UIImage imageWithData: [self.bannerList objectAtIndex:1]];
                [self.bgImageView setImage:bgImage];
                
            }
            [self removeNotificationApp];
            //[self setupPopUpObserver];

            
            
        }
    }else
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(orientation ==UIInterfaceOrientationPortrait || orientation ==UIInterfaceOrientationPortraitUpsideDown)
        {   NSString *imagePath =[NSString stringWithFormat:@"%@-%@",identifier,@"DefaultPortraitBg"];
            UIImage *bgImage = [UIImage imageNamed:imagePath];
            [self.bgImageView setImage:bgImage];
            
            
            
            
            
        }
        if(orientation==UIInterfaceOrientationLandscapeLeft || orientation==UIInterfaceOrientationLandscapeRight)
        {   NSString *imagePath =[NSString stringWithFormat:@"%@-%@",identifier,@"DefaultLandscapeBg"];
            UIImage *bgImage = [UIImage imageNamed:imagePath];
            [self.bgImageView setImage:bgImage];
            
            
            
        }
        
        
    }
}


-(void)removeNotificationApp
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

-(void)setUpBackground:(NSString *)identifier
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",identifier,@"DownloadComplete"]]  isEqual:@"YES"])
    {
        
        self.bannerList = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",identifier,@"Banner"]] mutableCopy];
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(self.bannerList.count!=0&&self.bannerList!=nil)
        {
            if(orientation ==UIInterfaceOrientationPortrait || orientation ==UIInterfaceOrientationPortraitUpsideDown)
            {
                UIImage *bgImage = [UIImage imageWithData: [self.bannerList objectAtIndex:1]];
                [self.bgImageView setImage:bgImage];

            }else if(orientation==UIInterfaceOrientationLandscapeLeft || orientation==UIInterfaceOrientationLandscapeRight)
            {       UIImage *bgImage = [UIImage imageWithData: [self.bannerList objectAtIndex:0]];
                [self.bgImageView setImage:bgImage];
            }
        }
    }else
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(orientation ==UIInterfaceOrientationPortrait || orientation ==UIInterfaceOrientationPortraitUpsideDown)
        {   NSString *imagePath =[NSString stringWithFormat:@"%@-%@",identifier,@"DefaultLandscapeBg"];
            UIImage *bgImage = [UIImage imageNamed:imagePath];
            [self.bgImageView setImage:bgImage];
            
            
            
            
            
        }
        if(orientation==UIInterfaceOrientationLandscapeLeft || orientation==UIInterfaceOrientationLandscapeRight)
        {   NSString *imagePath =[NSString stringWithFormat:@"%@-%@",identifier,@"DefaultPortraitBg"];
            UIImage *bgImage = [UIImage imageNamed:imagePath];
            [self.bgImageView setImage:bgImage];
            
            
            
        }
        
        
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    AppConfigReader *reader = [[AppConfigReader alloc] initWithConfigFile:CONFIG_FILE];
    NSDictionary *action = [reader getActionFromVersion];
    
    if (action != nil) {
        
        NSString *message = action[@"msg"];
        UIAlertView *alert;
        
        if ([action[@"bloqueio"] isEqualToString:@"S"]) {
            
            alert = [[UIAlertView alloc] initWithTitle:@"Atenção" message:message delegate:self cancelButtonTitle:@"Atualizar" otherButtonTitles: nil];
        } else {
            
            alert = [[UIAlertView alloc] initWithTitle:@"Atenção" message:message delegate:self cancelButtonTitle:@"Atualizar" otherButtonTitles:@"Depois", nil];
        }
        
        [alert show];
    }
    
    [self showSidebar:YES];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.sidebarPersio stopWiggleAllProfileItemCells];
    [UIView transitionWithView:self.bgImageView
                      duration:0.6
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self setupBannerObserver];
                        
                    } completion:nil];
}


-(BOOL)prefersStatusBarHidden {
    
    return YES;
}


#pragma mark - Private Methods

-(void)hideSidebar:(BOOL)animated {
    
    self.sidebarLeftConstraint.constant = self.sidebarPersio.bounds.size.width * -1;
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
    } else {
        [self.view layoutIfNeeded];
    }
}

-(void)showSidebar:(BOOL)animated {
    
    self.sidebarLeftConstraint.constant = 0.0;
    
    if (animated) {
        [UIView animateWithDuration:0.01 animations:^{
            [self.view layoutIfNeeded];
        }];
    } else {
        [self.view layoutIfNeeded];
    }
}

//-(void)setBgMotionEffects {
//    
//    UIInterpolatingMotionEffect *verticalParallax = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//    verticalParallax.maximumRelativeValue = @(-30);
//    verticalParallax.minimumRelativeValue = @(30);
//    
//    UIInterpolatingMotionEffect *horizontalParallax = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//    horizontalParallax.maximumRelativeValue = @(-30);
//    horizontalParallax.minimumRelativeValue = @(30);
//    
//    [self.bgImageView addMotionEffect:verticalParallax];
//    [self.bgImageView addMotionEffect:horizontalParallax];
//}

-(void)updateBgImageViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? [NSString stringWithFormat:@"%@-%@", identifier, @"DefaultPortraitBg"] : [NSString stringWithFormat:@"%@-%@", identifier, @"DefaultLandscapeBg"];
    
    self.bgImageView.image = [UIImage imageNamed:imageName];
}


#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        AppConfigReader *reader = [[AppConfigReader alloc] initWithConfigFile:CONFIG_FILE];
        NSDictionary *actionDict = [reader getActionFromVersion];
        
        NSURL *url = [reader urlFromAction:actionDict];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}


#pragma mark - IBActions


-(void)setClock {
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle: NSDateFormatterShortStyle];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(setUpTime:)
                                   userInfo:nil
                                    repeats:YES];
}

-(IBAction)showPopover:(UIButton *)sender {
    
    InfoViewController *infoVC = [[InfoViewController alloc] init];
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:infoVC];
    
    [popover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
}

-(void)setUpTime:(id)sender {
    
    NSString *currentTime = [self.dateFormatter stringFromDate: [NSDate date]];
    self.dateTime.text = currentTime;
    self.dateTime.adjustsFontSizeToFitWidth = YES;
    
    NSArray *dateComponents = [currentTime componentsSeparatedByString:@":"];
    NSString *description = [NSString stringWithFormat:@"Horário atual: %@ horas e %@ minutos", dateComponents.firstObject, dateComponents.lastObject];
    self.dateTime.accessibilityLabel = description;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self removeNotificationApp];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
   
        
        [UIView transitionWithView:self.bgImageView
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self setUpBackground:identifier];
                            
                        } completion:^(BOOL finished){
                            
                            
                            
                        }];
}


@end
