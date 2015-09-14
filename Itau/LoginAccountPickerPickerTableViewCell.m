//
//  LoginAccountPickerPickerTableViewCell.m
//  Itau
//
//  Created by a2works on 28/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginAccountPickerPickerTableViewCell.h"

@interface LoginAccountPickerPickerTableViewCell()

@property (strong, nonatomic) Account *selectedAccount;
@property (strong, nonatomic) NSArray *accounts;
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation LoginAccountPickerPickerTableViewCell

-(instancetype)init {
    
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
    }
    return self;
}


-(instancetype)initWithAccounts:(NSArray *)accounts andSelected:(Account *)selectedAccount {
    
    self = [self init];
    if (self) {
        self.accounts = accounts;
        self.selectedAccount = selectedAccount;
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;

        [self.pickerView selectRow:[self.accounts indexOfObject:selectedAccount] inComponent:0 animated:NO];
    }
    return self;
}




#pragma mark - Setters

-(void)setSelectedAccount:(Account *)selectedAccount {
    
    if ([self.delegate respondsToSelector:@selector(loginAccountPickerPickerTableViewCell:hasNewSelectedAccount:)]) {
        [self.delegate loginAccountPickerPickerTableViewCell:self hasNewSelectedAccount:selectedAccount];
    }
    
    _selectedAccount = selectedAccount;
}



#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.accounts.count;
}


#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    Account *account = self.accounts[row];
    
    NSString *title = [NSString stringWithFormat:@"ag %@ cc %@", account.agency, account.number];
    
    return title;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.selectedAccount = self.accounts[row];
}



@end
