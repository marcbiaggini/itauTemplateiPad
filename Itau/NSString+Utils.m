//
//  NSString+Utils.m
//  Itau
//
//  Created by TIVIT_iOS on 07/07/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

+(NSString *)trimmedStringWithoutDoubleSpace:(NSString *)string {
    
    NSMutableString *result = [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    
    do {
        result = [[string stringByReplacingOccurrencesOfString:@"  " withString:@" "] mutableCopy];
    } while (((NSRange)[result rangeOfString:@"  "]).length > 0);
    
    return result;
}

@end
