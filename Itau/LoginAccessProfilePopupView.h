//
//  LoginAccessAccountView.h
//  Itau
//
//  Created by a2works on 27/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginPopupView.h"
#import "LoginAccessAccountPickerViewCell.h"

@class LoginAccessProfilePopupView;

@protocol LoginAccessProfileViewDelegate <NSObject>

-(void)loginAccessProfileView:(LoginAccessProfilePopupView *)loginView willFinishWithAccount:(Account *)account;
-(void)loginAccessProfileView:(LoginAccessProfilePopupView *)loginView didUpdateProfile:(Profile *)profile;

@end

@interface LoginAccessProfilePopupView : LoginPopupView <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Profile *profile;
@property (strong, nonatomic) LoginAccessAccountPickerViewCell *accountPicker;

@property (strong, nonatomic) id<LoginAccessProfileViewDelegate> delegate;

-(instancetype)initWithProfile:(Profile *)profile;

@end
