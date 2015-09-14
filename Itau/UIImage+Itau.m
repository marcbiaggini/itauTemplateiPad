//
//  UIImage+Itau.m
//  Itau
//
//  Created by TIVIT_iOS on 16/07/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "UIImage+Itau.h"

@implementation UIImage (Itau)

+(UIImage *)targetedImageNamed:(NSString *)name {

    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", identifier, name]];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
