//
//  InfoViewController.m
//  Itau
//
//  Created by TIVIT_iOS on 21/07/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    NSString *sysName = [[UIDevice currentDevice] localizedModel];
    NSString *sysInfo = [NSString stringWithFormat:@"%@ (iOS %@)", sysName, sysVersion];
    
    self.sysInfoLabel.text = sysInfo;
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    self.appInfoLabel.text = [NSString stringWithFormat:@"versão %@", appVersion];
}

@end
