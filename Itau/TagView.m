//
//  TagView.m
//  Itau
//
//  Created by TIVIT_iOS on 21/07/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "TagView.h"
#import "UIImage+Itau.h"
#import <QuartzCore/QuartzCore.h>

@interface TagView()

@property (strong, nonatomic) UIToolbar *blurView;

@end

@implementation TagView

-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        [self prepareUI];
    }
    
    return self;
}

-(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image {
    
    self = [self init];
    
    if (self) {
        
        [self.button setTitle:title forState:UIControlStateNormal];
        [self.button setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        self.imageView.image = image;
    }
    
    return self;
}

-(void)prepareUI {
    
    self.clipsToBounds = YES;
    
    if (!self.blurView) {
        
        self.blurView = [[UIToolbar alloc] initWithFrame:self.bounds];
        
        [self insertSubview:self.blurView atIndex:0];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blurView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [self layoutIfNeeded];
    }

}

@end
