//
//  LoginNewAccessView.m
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginNewAccessPopupView.h"

@interface LoginNewAccessPopupView() <LoginOwnerPickerViewCellDelegate, LoginNewAccessAgencyAccountViewCellDelegate> {
    CGFloat _pickerHeight;
    NSString *_keyboardID;
    NSString *_accountID;
    NSArray *_owners;
}

@property (strong, nonatomic) NSArray *profiles;

@property (assign, nonatomic) LoginNewAccessStep currentStep;
@property (strong, nonatomic) RACSignal *buttonSignal;
@property (strong, nonatomic) NSDictionary *selectedOwner;

@end

@implementation LoginNewAccessPopupView

-(instancetype)init {
    
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        if (!self.loginViews) {
            self.loginViews = [[NSMutableArray alloc] init];
        }
        
        self.canDismiss = YES;
        [self prepareUI];
    }
    return self;
}

+(instancetype)startLoginNewAccessViewWithProfiles:(NSArray *)profiles {

    LoginNewAccessPopupView *view = [[LoginNewAccessPopupView alloc] init];
    view.profiles = profiles;
    return view;
}

-(void)dismiss {
    
    [self performSelector:@selector(isFirstResponder)];
    
    if ([self.agencyAccountViewCell.agencyTextField.textField isFirstResponder]) {
        [self.agencyAccountViewCell.agencyTextField.textField resignFirstResponder];
    }
    
    if ([self.agencyAccountViewCell.accountTextField.textField isFirstResponder]) {
        [self.agencyAccountViewCell.accountTextField.textField resignFirstResponder];
    }
    
    [super dismiss];
}




#pragma mark - Setters

-(void)setCurrentStep:(LoginNewAccessStep)currentStep {
    
    _currentStep = currentStep;
    
    switch (currentStep) {
            
        case kLoginNewAccessStepFirst:
            [self prepareForStepFirst];
            break;
            
        case kLoginNewAccessStepSecond:
            [self prepareForStepSecond];
            break;
            
        case kLoginNewAccessStepFinish:
            [self prepareForStepFinish];
            break;
            
        default: break;
    }
}




#pragma mark - Handling steps

-(void)prepareForStepFirst {
    
    [self insertAgencyAccountViewCell];
    [self insertFooter];
    [self racSignalsForFirstStep];
}

-(void)prepareForStepSecond {

    [self insertOwnerPickerViewCell];
    [self insertKeyboardViewCell];
    [self racSignalsForSecondStep];
}

-(void)prepareForStepFinish {
    
    NSString *number = self.agencyAccountViewCell.accountTextField.textField.text;
    NSString *agency = self.agencyAccountViewCell.agencyTextField.textField.text;
    NSString *cpf = self.ownerPickerViewCell.selectedOwner[@"cpf"];

    Account *anAccount = [LoginModel accountWithNumber:number
                                          agencyNumber:agency
                                                   CPF:cpf];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginNewAccessView:willFinishWithAccount:owner:createProfile:)]) {
        [self.delegate loginNewAccessView:self willFinishWithAccount:anAccount owner:self.ownerPickerViewCell.selectedOwner createProfile:self.ownerPickerViewCell.saveProfileSwitch.isOn];
    }
}




#pragma mark - Actions

-(void)buttonPressed {
    
    switch (self.currentStep) {
        case kLoginNewAccessStepFirst:
            
            [self firstStepLogin];
            
            break;
            
        case kLoginNewAccessStepSecond:
            
            [self secondStepLogin];
            
            break;
            
        case kLoginNewAccessStepFinish:
        default: break;
    }
}




#pragma mark - UI

-(void)prepareUI {
    
    self.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor targetPrimaryColor];
    
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = YES;
    self.tableView.scrollEnabled = NO;
    
    if (!_heightConstraint) {
        _heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.height];
        [self addConstraint:_heightConstraint];
    }
    
    self.currentStep = kLoginNewAccessStepFirst;
}




#pragma mark - First Step

-(void)insertAgencyAccountViewCell {
    
    if (!self.agencyAccountViewCell) {
        self.agencyAccountViewCell = [[LoginNewAccessAgencyAccountViewCell alloc] init];
        self.agencyAccountViewCell.delegate = self;
        self.height += self.agencyAccountViewCell.bounds.size.height;
        [self.loginViews addObject:self.agencyAccountViewCell];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.loginViews.count -1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

-(void)insertFooter {
    
    if (!self.footerView) {
        self.footerView = [[LoginFooterView alloc] init];
        self.tableView.tableFooterView = self.footerView;
        self.height += self.footerView.bounds.size.height;
    }
    
    [[self.footerView.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self buttonPressed];
    }];

    [self.footerView.button setTitle:@"continuar" forState:UIControlStateDisabled];
    [self.footerView.button setTitle:@"continuar" forState:UIControlStateNormal];
}

-(void)firstStepLogin {
    
    
    Reachability *connection = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [connection currentReachabilityStatus];
    
    if (status != NotReachable) {
        
        if ([self hasErrorView]) {
            [self dismissErrorMessage];
        }
        
        self.footerView.button.enabled = NO;
        self.agencyAccountViewCell.agencyTextField.textField.enabled = NO;
        self.agencyAccountViewCell.accountTextField.textField.enabled = NO;
        
        NSString *agency = self.agencyAccountViewCell.agencyTextField.textField.text;
        NSString *account = [self.agencyAccountViewCell.accountTextField.textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        _accountID = [NSString stringWithFormat:@"%@00%@", agency, account];
        
        NSDictionary *params = @{
                                 
                                 //required
                                 @"method": @"GET",
                                 @"path":   @{@"id_conta": _accountID},
                                 @"header": @{},
                                 @"body":   @{}
                                 };
        
        [self.footerView.activityIndicator startAnimating];
        
        @weakify(self)
        [[IMBackendClient sharedClient] requestWithParams:params
                                                    OPKey:@"keyb"
                                             successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 
                                                 @strongify(self)
                                                 NSHTTPURLResponse *response = operation.response;
                                                 if (response.statusCode != 200) {
                                                     [self showErrorMessage:(NSString *)[(NSDictionary *)responseObject objectForKey:@"mensagem"]];
                                                 } else {
                                                     _owners = [(NSDictionary *)responseObject objectForKey:@"titulares"];
                                                     _keyboardID = [(NSDictionary *)responseObject objectForKey:@"id_teclado"];
                                                     [self.agencyAccountViewCell.agencyTextField stampValues];
                                                     [self.agencyAccountViewCell.accountTextField stampValues];
                                                     self.currentStep = kLoginNewAccessStepSecond;
                                                 }
                                                 
                                                 [self.footerView.activityIndicator stopAnimating];
                                                 
                                             } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 
                                                 @strongify(self)
                                                 [self showErrorMessage:@"Agência e/ou conta incorretos"];
                                                 self.agencyAccountViewCell.agencyTextField.textField.enabled = YES;
                                                 self.agencyAccountViewCell.accountTextField.textField.enabled = YES;
                                                 
                                                 [self.footerView.activityIndicator stopAnimating];
                                             }];
        
    } else {
        
        [self showErrorMessage:@"Sem conexão com a internet."];
    }
}




#pragma mark - Second Step

-(void)insertOwnerPickerViewCell {
    
    if (!self.ownerPickerViewCell) {
        
        self.ownerPickerViewCell = [[LoginNewAccessOwnerPickerViewCell alloc] initWithOwners:_owners];
        self.ownerPickerViewCell.delegate = self;

        _pickerHeight = self.ownerPickerViewCell.bounds.size.height;
        self.height += _pickerHeight;
        
        [self.loginViews addObject:self.ownerPickerViewCell];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.loginViews.count -1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

-(void)insertKeyboardViewCell {
    
    if (!self.keyboardViewCell) {
        self.keyboardViewCell = [[LoginKeyboardTableViewCell alloc] initWithIdentifier:_keyboardID];
        self.height += self.keyboardViewCell.bounds.size.height;
        [self.loginViews addObject:self.keyboardViewCell];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.loginViews.count -1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

-(void)secondStepLogin {
    
    Reachability *connection = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [connection currentReachabilityStatus];
    
    if (status != NotReachable) {
        
        if ([self hasErrorView]) {
            [self dismissErrorMessage];
        }
        
        [self.footerView.activityIndicator startAnimating];
        
        NSDictionary *params = @{
                                 //required
                                 @"method": @"POST",
                                 @"path":   @{@"id_conta": _accountID},
                                 @"header": @{},
                                 @"body":   @{@"senha_eletronica": self.keyboardViewCell.passwordTextField.textField.text,
                                              @"titularidade": @"string",
                                              @"tipo_teclado": @"string",
                                              @"id_conexao": @"123456789012345678901234567890123456"
                                              }
                                 };
        
        @weakify(self)
        [[IMBackendClient sharedClient] requestWithParams:params
                                                    OPKey:@"auth"
                                             successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 
                                                 @strongify(self)
                                                 NSHTTPURLResponse *response = operation.response;
                                                 if (response.statusCode != 200) {
                                                     [self showErrorMessage:(NSString *)[(NSDictionary *)responseObject objectForKey:@"mensagem"]];
                                                 } else {
                                                     self.currentStep = kLoginNewAccessStepFinish;
                                                 }
                                                 
                                                 [self.footerView.activityIndicator stopAnimating];
                                                 
                                             } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 
                                                 @strongify(self)
                                                 [self.footerView.activityIndicator stopAnimating];
                                                 [self showErrorMessage:@"Senha inválida"];
                                             }];
        
    } else {
        
        [self showErrorMessage:@"Sem conexão com a internet."];
    }
}




#pragma mark - RAC Signals

-(void)racSignalsForFirstStep {

    RACSignal *agencySignal = [RACObserve(self.agencyAccountViewCell.agencyTextField.textField, text) map:^id(NSString *agency) {
        return @([self isValidAgency:agency]);
    }];
    
    [agencySignal subscribeNext:^(NSNumber *agencyValid) {
        if ([agencyValid boolValue]) {
            [self.agencyAccountViewCell.accountTextField.textField becomeFirstResponder];
        }
    }];
    
    RACSignal *accountSignal = [RACObserve(self.agencyAccountViewCell.accountTextField.textField, text) map:^id(NSString *account) {
        NSString *agency = self.agencyAccountViewCell.agencyTextField.textField.text;
        return @([self isValidAccount:account] && [self isValidDacUsingAgency:agency account:account]);
    }];
    
    self.buttonSignal = [RACSignal combineLatest:@[agencySignal, accountSignal] reduce:^id(NSNumber *validAgency, NSNumber *validAccount){
        
        if (self.hasErrorView) {
            [self dismissErrorMessage];
        }
        
        BOOL flag = [validAgency boolValue] && [validAccount boolValue];
        
        return @(flag);
    }];
    
    [self.buttonSignal subscribeNext:^(NSNumber *buttonEnabled) {
        self.footerView.button.enabled = [buttonEnabled boolValue];
    }];
}

-(void)racSignalsForSecondStep {
    
    RACSignal *passwordSignal = [RACObserve(self.keyboardViewCell.passwordTextField.textField, text) map:^id(NSString *password) {
        return @([super isValidPassword:password]);
    }];
    
    self.buttonSignal = [RACSignal combineLatest:@[passwordSignal] reduce:^id(NSNumber *validPassword){
        
        if (![validPassword boolValue]) {
            [self.footerView.button setTitle:@"acessar" forState:UIControlStateDisabled];
            [self.footerView.button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        } else {
            [self.footerView.button setTitle:@"acessar" forState:UIControlStateNormal];
        }
        
        return validPassword;
    }];
    
    [self.buttonSignal subscribeNext:^(NSNumber *buttonEnabled) {
        self.footerView.button.enabled = [buttonEnabled boolValue];
    }];
}




#pragma mark - LoginNewAccessAgencyAccountViewCellDelegate

-(void)loginNewAccessAgencyAccountViewCell:(LoginNewAccessAgencyAccountViewCell *)newAccessView didPressDoneButtonWithResponder:(UIResponder<UITextInput> *)responder {
    
    [responder resignFirstResponder];
    
    if (self.footerView.button.enabled) {
        [self buttonPressed];
    }
}




#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.loginViews.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.loginViews[indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = self.loginViews[indexPath.row];
    CGFloat height = ((UIView *)object).bounds.size.height;
    if ([object isKindOfClass:[LoginNewAccessOwnerPickerViewCell class]]) {
        height = _pickerHeight;
    }
    
    return height;
}




#pragma mark - LoginOwnerPickerViewCellDelegate

-(void)loginOwnerPicker:(LoginNewAccessOwnerPickerViewCell *)pickerCell hasNewHeight:(CGFloat)newHeight {
    
    _pickerHeight = newHeight;
    
    CGFloat actualHeight = self.ownerPickerViewCell.bounds.size.height;
    CGFloat diff = newHeight - actualHeight;
    
    if (diff > 0) self.height += diff;
    else          self.height -= diff * -1;
    
    self.ownerPickerViewCell = pickerCell;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(BOOL)loginOwnerPickerShouldAllowSavingProfile:(LoginNewAccessOwnerPickerViewCell *)pickerCell {
    
    return self.profiles.count < 3;
}




#pragma mark - Validating

-(BOOL)isValidDacUsingAgency:(NSString *)agencyNumber account:(NSString *)accountNumber {
    
    NSArray *accountArray = [accountNumber componentsSeparatedByString:@"-"];
    
    NSString *account = accountArray[0];
    NSString *prevDAC = accountArray[1];
    
    NSString *string = [NSString stringWithFormat:@"%@%@", agencyNumber, account];

    int i = 2, sum = 0, res = 0;
    
    for (int k = 0; k < string.length; k++) {
        NSString *value = [string substringWithRange:NSMakeRange(k, 1)];
        res = [value intValue] * i;
        sum += res > 9 ? (res - 9) : res;
        i = i == 2 ? 1 : 2;
    }
    
    NSNumber *dac = @((10 - (sum % 10)) %10);
    
    return [prevDAC isEqualToString:[dac stringValue]];
}

-(BOOL)isValidAgency:(NSString *)agency {
    
    return agency.length == 4;
}

-(BOOL)isValidAccount:(NSString *)account {
    
    return account.length == 7;
}


@end
