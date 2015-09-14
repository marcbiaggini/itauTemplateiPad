//
//  AppDelegate.h
//  Itau
//
//  Created by Pérsio on 28/04/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BannerGeolocalizado.h"
#import "Reachability.h"
#import <AFNetworking/AFNetworking.h>
#import "Clock.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (strong, nonatomic) BannerGeolocalizado *banner;
@property (strong, nonatomic) NSString *bannerIsReady;
@property (nonatomic, strong) NSMutableArray *bannerList;
@property (nonatomic, strong) NSMutableArray *bannerListData;
@property (strong,nonatomic) Clock *clock;
@property (nonatomic, strong) NetworkConnectionMonitor *networkMonitor;
@property (nonatomic, strong) NSString *askingBanner;
@property (assign, atomic) int timeout;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

