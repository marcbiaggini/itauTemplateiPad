//
//  LoginNewAccessView.h
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginPopupView.h"
#import "LoginNewAccessAgencyAccountViewCell.h"
#import "LoginNewAccessOwnerPickerViewCell.h"

typedef enum LoginNewAccessStepTypes {
    
    kLoginNewAccessStepFirst,
    kLoginNewAccessStepSecond,
    kLoginNewAccessStepFinish
    
} LoginNewAccessStep;

@class LoginNewAccessPopupView;

@protocol LoginNewAccessViewDelegate <NSObject>

-(void)loginNewAccessView:(LoginNewAccessPopupView *)newAccessView
    willFinishWithAccount:(Account *)account owner:(NSDictionary *)owner createProfile:(BOOL)createProfile;

@end

@interface LoginNewAccessPopupView : LoginPopupView <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) id<LoginNewAccessViewDelegate> delegate;

@property (strong, nonatomic) LoginNewAccessAgencyAccountViewCell *agencyAccountViewCell;
@property (strong, nonatomic) LoginNewAccessOwnerPickerViewCell *ownerPickerViewCell;

+(instancetype)startLoginNewAccessViewWithProfiles:(NSArray *)profiles;

@end
