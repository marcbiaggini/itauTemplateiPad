//
//  LoginAccountPickerTableViewCell.h
//  Itau
//
//  Created by a2works on 25/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"

@interface LoginAccountPickerTableViewCell : UITableViewCell

@property (strong, nonatomic) Account *account;

-(instancetype)initWithAccount:(Account *)account;

@end
