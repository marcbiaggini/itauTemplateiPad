//
//  JSONStrategy.m
//  Itau
//
//  Created by Pérsio on 30/04/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "JSONStrategy.h"

@implementation JSONStrategy

+(void)getJSONFromBundle:(void (^)(id))success error:(void (^)(NSError *))error {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"json"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *fileError;
    
    if ([fm fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path options:kNilOptions error:&fileError];
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&fileError];
        if ([NSJSONSerialization isValidJSONObject:json]) {
            success(json);
        } else {
            error(fileError);
        }
    } else {
        error(fileError);
    }
}

+(void)getJSONFromAPI:(void (^)(id))success error:(void (^)(NSError *))error {
    
}

@end
