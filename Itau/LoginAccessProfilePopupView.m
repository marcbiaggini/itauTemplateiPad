//
//  LoginAccessAccountView.m
//  Itau
//
//  Created by a2works on 27/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginAccessProfilePopupView.h"
#import "LoginProfileImagePickerView.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginAccessProfilePopupView() <LoginAccessAccountPickerViewCellDelegate, LoginProfileImagePickerViewDelegate> {
    CGFloat _pickerHeight;
}

@end


@implementation LoginAccessProfilePopupView

-(instancetype)initWithProfile:(Profile *)profile {
    
    self = [self init];
    if (self) {
        self.profile = profile;
        self.canDismiss = YES;
        [self prepareUI];
    }
    return self;
}

-(instancetype)init {
    
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        if (!self.loginViews) {
            self.loginViews = [[NSMutableArray alloc] init];
        }
    }
    return self;
}




#pragma mark - Actions

-(void)buttonPressed {
    
    [self.footerView.activityIndicator startAnimating];
    [self.footerView.button setEnabled:NO];
    
    Account *selectedAccount = self.accountPicker.selectedAccount;
    
    NSString *_accountID = [NSString stringWithFormat:@"%@00%@", selectedAccount.agency, [selectedAccount.number stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    
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
                                                 if ([self.delegate respondsToSelector:@selector(loginAccessProfileView:willFinishWithAccount:)]) {
                                                     [self.delegate loginAccessProfileView:self willFinishWithAccount:self.accountPicker.selectedAccount];
                                                 }
                                             }
                                             
                                             [self.footerView.activityIndicator stopAnimating];
                                             
                                         } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             
                                             @strongify(self)
                                             [self showErrorMessage:@"Sem conexão com a internet."];
                                             [self.footerView.activityIndicator stopAnimating];
                                         }];
}



#pragma mark - UI

-(void)insertFooter {
    
    if (!self.footerView) {
        self.footerView = [[LoginFooterView alloc] init];
        self.tableView.tableFooterView = self.footerView;
        self.height += self.footerView.bounds.size.height;
    }
    
    [[self.footerView.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self buttonPressed];
    }];
    
    [self.footerView.button setTitle:@"acessar" forState:UIControlStateDisabled];
    [self.footerView.button setTitle:@"acessar" forState:UIControlStateNormal];
}

-(void)insertAccountPicker {
    
    if (!self.accountPicker) {
        
        self.accountPicker = [[LoginAccessAccountPickerViewCell alloc] initWithProfile:self.profile];
        self.accountPicker.delegate = self;
        
        _pickerHeight = self.accountPicker.bounds.size.height;
        self.height += self.accountPicker.bounds.size.height;
        
        [self.loginViews addObject:self.accountPicker];
    }

    [RACObserve(self.accountPicker, selectedAccount) subscribeNext:^(id x) {
        [self updateKeyboard];
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImagePicker:)];
    
    [self.accountPicker.profileImageView addGestureRecognizer:tapGesture];
}

-(void)showImagePicker:(UIGestureRecognizer *)sender {
    
    self.canDismiss = NO;
    
    LoginProfileImagePickerView *pickerView = [[LoginProfileImagePickerView alloc] init];
    pickerView.delegate = self;
    pickerView.backgroundColor = [UIColor whiteColor];
    [pickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    pickerView.layer.cornerRadius = 10.0;
    
    [self.superview insertSubview:pickerView aboveSubview:self];
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:pickerView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:10.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:pickerView
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0
                                                                constant:10.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:pickerView
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1.0
                                                                constant:-10.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:pickerView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:-10.0]];
    
    [self.superview layoutIfNeeded];
}

-(void)insertKeyboardViewCell {
    
    if (!self.keyboardViewCell) {
        self.keyboardViewCell = [[LoginKeyboardTableViewCell alloc] init];
        self.height += self.keyboardViewCell.bounds.size.height;
        [self.loginViews addObject:self.keyboardViewCell];
    }
    
    [[RACObserve(self.keyboardViewCell.passwordTextField.textField, text) map:^id(NSString *password) {
        return @([super isValidPassword:password]);
    }] subscribeNext:^(NSNumber *passwordValid) {
        self.footerView.button.enabled = [passwordValid boolValue];
        if (![passwordValid boolValue]) {
            [self.footerView.button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        } else {
            [self.footerView.button setEnabled:YES];
        }
    }];
}

-(void)prepareUI {
    
    self.backgroundColor = [UIColor targetPrimaryColor];
    
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = YES;
    self.tableView.scrollEnabled = NO;
    
    if (!_heightConstraint) {
        _heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.height];
        [self addConstraint:_heightConstraint];
    }
    
    [self insertFooter];
    [self insertAccountPicker];
    [self insertKeyboardViewCell];
}

-(void)updateKeyboard {
    
    [self.footerView.button setEnabled:NO];
    
    NSString *agency = self.accountPicker.selectedAccount.agency;
    NSString *account = [self.accountPicker.selectedAccount.number stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *idConta = [NSString stringWithFormat:@"%@00%@", agency, account];
    
    NSDictionary *params = @{
                             //required
                             @"method": @"GET",
                             @"path":   @{@"id_conta": idConta},
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
                                                 [self.keyboardViewCell updateUsingIdentifier:[(NSDictionary *)responseObject objectForKey:@"id_teclado"]];
                                             }
                                             
                                             [self.footerView.activityIndicator stopAnimating];
                                             
                                         } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             
                                             @strongify(self)
                                             [self showErrorMessage:@"Sem conexão com a internet."];
                                             [self.footerView.activityIndicator stopAnimating];
                                         }];
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
    if ([object isKindOfClass:[LoginAccessAccountPickerViewCell class]]) {
        height = _pickerHeight;
    }
    
    return height;
}




#pragma mark - LoginAccessAccountPickerViewCellDelegate

-(void)loginAccountPicker:(LoginAccessAccountPickerViewCell *)accountPicker hasNewHeight:(CGFloat)newHeight {
    
    _pickerHeight = newHeight;
    
    CGFloat actualHeight = self.accountPicker.bounds.size.height;
    CGFloat diff = newHeight - actualHeight;
    
    if (diff > 0) self.height += diff;
    else          self.height -= diff * -1;
    
    self.accountPicker = accountPicker;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}



#pragma mark - LoginProfileImagePickerDelegate

-(void)loginImagePicker:(LoginProfileImagePickerView *)picker willFinishWithImageData:(NSData *)imageData {
    
    NSError *error = nil;
    self.profile.photo = imageData;
    
    [LoginModel saveProfile:self.profile usingError:&error];
    
    if (!error) {
        
        self.accountPicker.profile = self.profile;
        
        if ([self.delegate respondsToSelector:@selector(loginAccessProfileView:didUpdateProfile:)]) {
            [self.delegate loginAccessProfileView:self didUpdateProfile:self.profile];
        }
        
    } else {
        
        [self showErrorMessage:@"Erro atualizando foto do perfil"];
    }
    
    self.canDismiss = YES;
}

-(void)loginImagePickerWillFinishAskingDeleteImage:(LoginProfileImagePickerView *)picker {
    
    if (self.profile.photo) {
        
        NSError *error = nil;
        self.profile.photo = nil;
        
        [LoginModel saveProfile:self.profile usingError:&error];
        
        if (!error) {
            
            self.accountPicker.profile = self.profile;

            if ([self.delegate respondsToSelector:@selector(loginAccessProfileView:didUpdateProfile:)]) {
                [self.delegate loginAccessProfileView:self didUpdateProfile:self.profile];
            }
        }
    }
    
    self.canDismiss = YES;
}

-(void)loginImagePickerDidCancel:(LoginProfileImagePickerView *)picker {

    self.canDismiss = YES;
}


@end
