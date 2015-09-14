//
//  NetworkClient.h
//  iOSSDK
//
//  Created by Alexandre Garrefa on 5/19/15.
//  Copyright (c) 2015 Concrete Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;

typedef void (^IMSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^IMFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);


@interface IMBackendClient : NSObject

+ (instancetype)sharedClient;

+ (instancetype)initializeDefaultClient;

+ (instancetype)initWithRoutes:(NSDictionary *)routes;

+ (instancetype)initWithRoutes:(NSDictionary *)routes routerURL:(NSURL *)router andLightURL:(NSURL *)light;

- (void)requestWithParams:(NSDictionary *)params
                    OPKey:(NSString *)opKey
             successBlock:(IMSuccessBlock)success
             failureBlock:(IMFailureBlock)failure;

@end
