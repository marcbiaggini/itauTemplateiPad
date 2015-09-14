//
//  LoginAccountPickerTableViewCell.m
//  Itau
//
//  Created by a2works on 25/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginAccountPickerTableViewCell.h"

@interface LoginAccountPickerTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *agencyLabel;
@property (weak, nonatomic) IBOutlet UIView *divider;

@end

@implementation LoginAccountPickerTableViewCell

-(instancetype)initWithAccount:(Account *)account {
    
    self = [self init];
    if (self) {
        self.account = account;
    }
    return self;
}

-(instancetype)init {
    
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
    }
    return self;
}



#pragma mark - Setters

-(void)setAccount:(Account *)account {
    
    _account = account;
    self.accountLabel.text = account.number;
    self.agencyLabel.text = account.agency;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    self.divider.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255 blue:150.0/255.0 alpha:1.0];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    self.divider.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255 blue:150.0/255.0 alpha:1.0];
}


@end
