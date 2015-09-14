//
//  LoginKeyboardViewCell.h
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldAndroidStyle.h"

@interface LoginKeyboardTableViewCell : UITableViewCell

@property (weak, nonatomic) TextFieldAndroidStyle *passwordTextField;

-(instancetype)initWithIdentifier:(NSString *)identifier;
-(void)updateUsingIdentifier:(NSString *)identifier;

@end
