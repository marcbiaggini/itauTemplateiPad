//
//  AXMindReader.h
//  Pods
//
//  Created by Alexandre Garrefa on 6/2/15.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    IMRunningEnvironmentTypeSimulator = 0,
    IMRunningEnvironmentTypeDeveloper,
    IMRunningEnvironmentTypeAdHoc,
    IMRunningEnvironmentTypeAppStore
} IMRunningEnvironmentType;


@interface IMRunningEnvironment : NSObject

+ (IMRunningEnvironmentType)whatsMyTheBuildConfiguration;

+ (BOOL)isDevelopment;
+ (BOOL)isProduction;

@end
