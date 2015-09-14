//
//  UIColor+Itau.m
//  Itau
//
//  Created by a2works on 29/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "UIColor+Itau.h"

@implementation UIColor (Itau)

+(UIColor *)targetPrimaryColor {
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    
    UIColor *color = [identifier isEqualToString:@"ipaditau"]
    ? [UIColor colorWithRed:236.0/255.0 green:116.0/255.0 blue:5.0/255.0 alpha:1.0]
    : [UIColor colorWithRed:209.0/255.0 green:170.0/255.0 blue:98.0/255.0 alpha:1.0];
    
    return color;
}

@end
