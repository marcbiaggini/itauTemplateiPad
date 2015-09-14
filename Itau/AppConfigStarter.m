//
//  AppConfigStarter.m
//  Itau
//
//  Created by Pérsio on 02/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "AppConfigStarter.h"
#import "JSONStrategy.h"
#import "AppConfigReader.h"

@implementation AppConfigStarter


#pragma mark - Public methods

-(void)prepareAppConfig {
    
    if (![self isThereConfigFile]) {
        [self createTempFolder];
    }
}

-(BOOL)updateAppConfig {
    
    __block BOOL success = YES;
    
    if (![self isUpToDateConfigFile]) {
        
        [JSONStrategy getJSONFromBundle:^(id json) {
            if ([NSJSONSerialization isValidJSONObject:json]) {
                
                NSDictionary *dict = json;
                [dict writeToFile:CONFIG_FILE atomically:YES];
            }
        } error:^(NSError *error) {
            success = NO;
        }];
    }
    
    return success;
}


#pragma mark - Private methods

-(BOOL)isThereConfigFile {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:CONFIG_FILE];
}

-(BOOL)createTempFolder {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL success = YES, isDir;
    
    if (![fm fileExistsAtPath:TMP_FOLDER isDirectory:&isDir]) {
        
        if (![fm createDirectoryAtPath:TMP_FOLDER withIntermediateDirectories:YES attributes:nil error:nil]) {
            success = NO;
        }
    }
    
    return success;
}

-(BOOL)isUpToDateConfigFile {
    
    if ([self isThereConfigFile]) {
        
        AppConfigReader *reader = [[AppConfigReader alloc] initWithConfigFile:CONFIG_FILE];
        
        NSDictionary *environment = [reader getEnvironmentInfo];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        
        NSDate *cacheDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", environment[@"data"], environment[@"hora"]]];
        
        NSTimeInterval cacheTolerance = [environment[@"cache"] floatValue];
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:cacheDate];
        
        return (interval/60 < cacheTolerance);
    }
    
    return NO;
}


@end
