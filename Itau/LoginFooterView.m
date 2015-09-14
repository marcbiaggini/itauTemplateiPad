//
//  LoginFooterView.m
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LoginFooterView.h"
#import "UIColor+Itau.h"

@interface LoginFooterView()

@end

@implementation LoginFooterView

-(instancetype)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        [self prepareUI];
    }
    return self;
}

-(void)prepareUI {
    self.button.layer.cornerRadius = 4.0;
    self.backgroundColor = [UIColor targetPrimaryColor];
    [self.button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
}

@end
