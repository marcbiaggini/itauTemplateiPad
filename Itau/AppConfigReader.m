//
//  AppConfigReader.m
//  Itau
//
//  Created by Pérsio on 02/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "AppConfigReader.h"

@interface AppConfigReader ()

@property (strong, nonatomic) NSDictionary *file;

@end

@implementation AppConfigReader

-(instancetype)initWithConfigFile:(NSString *)configFile {
    
    self = [super init];
    
    if (self != nil) {
        self.configFile = configFile;
    }
    
    return self;
}

-(void)setConfigFile:(NSString *)configFile {
    
    _configFile = configFile;
    self.file = [NSDictionary dictionaryWithContentsOfFile:_configFile];
}

-(NSDictionary *)getEnvironmentInfo {
    
    return self.file[@"ambiente"];
}

-(NSDictionary *)getAppConfigInfo {
    
    return self.file[@"app_config"];
}

-(NSURL *)urlFromAction:(NSDictionary *)action {
    
    NSDictionary *platform = [self getConfigInfoFromPlatform:@"ipad"];
    NSURL *storeURL = [NSURL URLWithString:platform[@"url_loja"]];
    
    return storeURL;
}

-(NSDictionary *)getActionFromVersion {
    
    NSDictionary *object;
    NSDictionary *iPadPlatform = [self getConfigInfoFromPlatform:@"ipad"];
    
    int installedVersion = [self stringVersionToInt:INSTALLED_VERSION];
    int currentVersion = [self stringVersionToInt:iPadPlatform[@"build_number_atual"]];
    
    if (installedVersion == currentVersion) {
        
        object = nil;
        
    } else {
        
        NSArray *versions = [self getVersionsFromPlatform:@"ipad"];
        object = [self actionFromVersions:versions];
    }
    
    return object;
    
}

-(NSDictionary *)getConfigInfoFromPlatform:(NSString *)platform {
    
    NSDictionary *object;
    
    NSDictionary *appConfig = [self getAppConfigInfo];
    
    NSArray *platforms = appConfig[@"plataforma"];
    
    for (NSDictionary *aPlatform in platforms) {
        
        if ([aPlatform[@"nome"] isEqualToString:platform]) {
            object = aPlatform;
        }
    }
    
    return object;
}

-(NSArray *)getVersionsFromPlatform:(NSString *)platform {

    NSDictionary *aPlatform = [self getConfigInfoFromPlatform:platform];
    return aPlatform[@"versoes"];
}

-(NSDictionary *)getActionFromType:(NSString *)type {
    
    NSDictionary *object;
    
    NSArray *actions = self.file[@"app_config"][@"acoes"];
    
    for (NSDictionary *action in actions) {
        if ([action[@"tipo"] isEqualToString:type]) {
            object = action;
        }
    }
    
    return object;
}


#pragma mark - Private methods

-(int)stringVersionToInt:(NSString *)version {
    
    return [[version stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
}

-(NSDictionary *)actionFromVersions:(NSArray *)versions {
    
    NSDictionary *object;
    
    int installedVersion = [self stringVersionToInt:INSTALLED_VERSION];
    
    for (NSDictionary *version in versions) {
        
        int minVersion = [self stringVersionToInt:version[@"min"]];
        int maxVersion = [self stringVersionToInt:version[@"max"]];
        
        if (installedVersion >= minVersion && installedVersion <= maxVersion) {
            
            object = [self getActionFromType:version[@"acao"]];
        }
    }
    
    return object;
}



@end
