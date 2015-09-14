//
//  LoginAccessAccountWelcomeViewCell.h
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"


@class LoginAccessAccountPickerViewCell;

@protocol LoginAccessAccountPickerViewCellDelegate <NSObject>

-(void)loginAccountPicker:(LoginAccessAccountPickerViewCell *)accountPicker hasNewHeight:(CGFloat)newHeight;

@end



@interface LoginAccessAccountPickerViewCell : UITableViewCell

@property (strong, nonatomic) id<LoginAccessAccountPickerViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel     *agencyLabel;
@property (weak, nonatomic) IBOutlet UILabel     *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel     *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIButton    *addAccountButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITableView *accountsTableView;

@property (strong, nonatomic) Account *selectedAccount;
@property (strong, nonatomic) Profile *profile;

-(instancetype)initWithProfile:(Profile *)profile;

@end
