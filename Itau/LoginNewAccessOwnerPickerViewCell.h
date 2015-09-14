//
//  LoginNewAccessStepTwoViewCell.h
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchControl.h"

@class LoginNewAccessOwnerPickerViewCell;

@protocol LoginOwnerPickerViewCellDelegate <NSObject>

-(BOOL)loginOwnerPickerShouldAllowSavingProfile:(LoginNewAccessOwnerPickerViewCell *)pickerCell;
-(void)loginOwnerPicker:(LoginNewAccessOwnerPickerViewCell *)pickerCell hasNewHeight:(CGFloat)newHeight;

@end

@interface LoginNewAccessOwnerPickerViewCell : UITableViewCell

@property (retain, nonatomic) id<LoginOwnerPickerViewCellDelegate> delegate;
@property (strong, nonatomic) NSDictionary *selectedOwner;

@property (strong, nonatomic) SwitchControl *saveProfileSwitch;

-(instancetype)initWithOwners:(NSArray *)owners;

@end
