//
//  LoginAccountPickerPickerTableViewCell.h
//  Itau
//
//  Created by a2works on 28/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"

@class LoginAccountPickerPickerTableViewCell;

@protocol LoginAccountPickerPickerTableViewCellDelegate <NSObject>

-(void)loginAccountPickerPickerTableViewCell:(LoginAccountPickerPickerTableViewCell *)cell hasNewSelectedAccount:(Account *)account;

@end

@interface LoginAccountPickerPickerTableViewCell : UITableViewCell <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) id<LoginAccountPickerPickerTableViewCellDelegate> delegate;

-(instancetype)initWithAccounts:(NSArray *)accounts andSelected:(Account *)selectedAccount;

@end
