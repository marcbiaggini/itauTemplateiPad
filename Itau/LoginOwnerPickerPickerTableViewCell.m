//
//  LoginOwnerPickerPickerViewCell.m
//  Itau
//
//  Created by a2works on 20/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginOwnerPickerPickerTableViewCell.h"
#import "NSString+Utils.h"

@interface LoginOwnerPickerPickerTableViewCell()

@property (strong, nonatomic) NSArray *owners;
@property (strong, nonatomic) NSDictionary *selectedOwner;

@end

@implementation LoginOwnerPickerPickerTableViewCell

-(instancetype)init {
    
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

-(instancetype)initWithOwners:(NSArray *)owners andSelected:(NSDictionary *)selectedOwner {
    self = [self init];
    if (self) {
        self.owners = owners;
        self.selectedOwner = selectedOwner;
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        
        [self.pickerView selectRow:[self.owners indexOfObject:selectedOwner] inComponent:0 animated:NO];
    }
    return self;
}




#pragma mark - Setters

-(void)setSelectedOwner:(NSDictionary *)selectedOwner {
    
    if ([self.delegate respondsToSelector:@selector(loginOwnerPickerPickerTableViewCell:hasNewSelectedOwner:)]) {
        [self.delegate loginOwnerPickerPickerTableViewCell:self hasNewSelectedOwner:selectedOwner];
    }
    
    _selectedOwner = selectedOwner;
}




#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.owners.count;
}




#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSDictionary *owner = self.owners[row];
    
    return [NSString trimmedStringWithoutDoubleSpace:owner[@"nome_titular"]];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.selectedOwner = self.owners[row];
}

@end
