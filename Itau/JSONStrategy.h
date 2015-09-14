//
//  JSONStrategy.h
//  Itau
//
//  Created by Pérsio on 30/04/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONStrategy : NSObject

+(void)getJSONFromAPI:(void (^)(id json))success error:(void (^)(NSError *error))error;
+(void)getJSONFromBundle:(void (^)(id json))success error:(void (^)(NSError *error))error;

@end
