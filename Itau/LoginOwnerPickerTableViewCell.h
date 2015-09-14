//
//  LoginOwnerPickerTableViewCell.h
//  Itau
//
//  Created by a2works on 25/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginOwnerPickerTableViewCell : UITableViewCell

@property (weak, nonatomic) NSDictionary *owner;

-(instancetype)initWithOwner:(NSDictionary *)owner;

@end
