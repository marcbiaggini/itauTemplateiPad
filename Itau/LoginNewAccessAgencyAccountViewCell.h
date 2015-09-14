//
//  LoginNewAccessStepOneViewCell.h
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldAndroidStyle.h"

@class LoginNewAccessAgencyAccountViewCell;

@protocol LoginNewAccessAgencyAccountViewCellDelegate <NSObject>

-(void)loginNewAccessAgencyAccountViewCell:(LoginNewAccessAgencyAccountViewCell *)newAccessView didPressDoneButtonWithResponder:(UIResponder<UITextInput> *)responder;

@end

@interface LoginNewAccessAgencyAccountViewCell : UITableViewCell

@property (strong, nonatomic) TextFieldAndroidStyle *agencyTextField;
@property (strong, nonatomic) TextFieldAndroidStyle *accountTextField;
@property (strong, nonatomic) id<LoginNewAccessAgencyAccountViewCellDelegate> delegate;

@end
