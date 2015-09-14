//
//  AppConfig.h
//  Itau
//
//  Created by Pérsio on 30/04/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject

#define LIB_FOLDER [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]
#define TMP_FOLDER [LIB_FOLDER stringByAppendingPathComponent:@"Utilities"]
#define CONFIG_FILE [TMP_FOLDER stringByAppendingPathComponent:@"config.plist"]
#define INSTALLED_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

@end
