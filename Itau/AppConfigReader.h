//
//  AppConfigReader.h
//  Itau
//
//  Created by Pérsio on 02/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "AppConfig.h"

@interface AppConfigReader : AppConfig

@property (nonatomic, strong) NSString *configFile;

- (instancetype)initWithConfigFile:(NSString *)configFile;
- (NSDictionary *)getEnvironmentInfo;
- (NSDictionary *)getAppConfigInfo;
- (NSDictionary *)getConfigInfoFromPlatform:(NSString *)platform;
- (NSArray *)getVersionsFromPlatform:(NSString *)platform;
- (NSDictionary *)getActionFromType:(NSString *)type;
- (NSDictionary *)getActionFromVersion;
- (NSURL *)urlFromAction:(NSDictionary *)action;

@end
