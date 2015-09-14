//
//  setupButtons.m
//  Itau
//
//  Created by A2works on 12/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "SetupWidgets.h"
#import <UIKit/UIKit.h>


@implementation SetupWidgets

- (void)addCornerRadius:(UIView *)view {
    
    view.layer.cornerRadius = 6.0f;
}


-(void)addShadow:(UIView *)view {
    
    CGSize shadowOffset = CGSizeMake(1.0, 1.0);
    float shadowOpacity = 0.5;
    CGColorRef shadowColor = [UIColor blackColor].CGColor;
    float shadowRadius = 0.6;
    
    view.layer.shadowOffset = shadowOffset;
    view.layer.shadowOpacity = shadowOpacity;
    view.layer.shadowColor = shadowColor;
    view.layer.shadowRadius = shadowRadius;
}


@end
