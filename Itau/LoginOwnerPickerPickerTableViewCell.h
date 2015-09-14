//
//  LoginOwnerPickerPickerViewCell.h
//  Itau
//
//  Created by a2works on 20/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginOwnerPickerPickerTableViewCell;

@protocol LoginOwnerPickerPickerTableViewCellDelegate <NSObject>

-(void)loginOwnerPickerPickerTableViewCell:(LoginOwnerPickerPickerTableViewCell *)cell hasNewSelectedOwner:(NSDictionary *)owner;

@end

@interface LoginOwnerPickerPickerTableViewCell : UITableViewCell <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) id<LoginOwnerPickerPickerTableViewCellDelegate> delegate;

-(instancetype)initWithOwners:(NSArray *)owners andSelected:(NSDictionary *)selectedOwner;

@end
