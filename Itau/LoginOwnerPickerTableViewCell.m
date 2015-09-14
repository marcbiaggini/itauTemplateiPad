//
//  LoginOwnerPickerTableViewCell.m
//  Itau
//
//  Created by a2works on 25/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginOwnerPickerTableViewCell.h"
#import "NSString+Utils.h"

@interface LoginOwnerPickerTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *divider;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation LoginOwnerPickerTableViewCell

-(instancetype)initWithOwner:(NSDictionary *)owner {
    self = [self init];
    if (self) {
        self.owner = owner;
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

-(void)setOwner:(NSDictionary *)owner {
    
    _owner = owner;
    self.label.text = [NSString trimmedStringWithoutDoubleSpace:owner[@"nome_titular"]];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    self.divider.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255 blue:150.0/255.0 alpha:1.0];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    self.divider.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255 blue:150.0/255.0 alpha:1.0];
}

@end
