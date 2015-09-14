//
//  LoginAddProfileView.m
//  Itau
//
//  Created by a2works on 06/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "AddProfileView.h"
#import "UIImage+Itau.h"

@implementation AddProfileView

#pragma mark - IBActions

-(void)accessAccount:(UIButton *)sender {
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(addProfileViewDidTouch:)]) {
        [self.delegate addProfileViewDidTouch:self];
    }
}

-(void)setButton:(UIButton *)button {
    
    _button = button;

    [_button setImage:[UIImage targetedImageNamed:@"AddButton"] forState:UIControlStateNormal];
}

@end
