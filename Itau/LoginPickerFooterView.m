//
//  LoginNewAccessStepTwoFooterView.m
//  Itau
//
//  Created by a2works on 19/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "LoginPickerFooterView.h"
#import "UIImage+Itau.h"

@interface LoginPickerFooterView()

@property (assign, nonatomic) BOOL reverse;

@end

@implementation LoginPickerFooterView

-(instancetype)init {
    
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        
        self.reverse = NO;
        
        [self.button setImage:[UIImage targetedImageNamed:@"ico_droplist"] forState:UIControlStateNormal];
        
        [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self rotate];
        }];
    }
    
    return self;
}


-(void)rotate {

    [UIView animateWithDuration:0.25 animations:^{
        self.button.imageView.transform = self.reverse
        ? CGAffineTransformMakeRotation(0 * M_PI/180)
        : CGAffineTransformMakeRotation(180 * M_PI/180);
    }];
    
    self.reverse = !self.reverse;
}


@end
