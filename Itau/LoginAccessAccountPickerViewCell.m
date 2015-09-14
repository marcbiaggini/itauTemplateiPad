//
//  LoginAccessAccountWelcomeViewCell.m
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//


#define TABLE_LIMIT 3

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "LoginAccessAccountPickerViewCell.h"
#import "LoginPickerFooterView.h"
#import "LoginAccountPickerTableViewCell.h"
#import "LoginAccountPickerPickerTableViewCell.h"
#import "LoginModel.h"
#import "UIColor+Itau.h"
#import "UIImage+Itau.h"


typedef enum LoginAccessAccountPickerModeTypes {
    
    kLoginAccessAccountPickerModeLabel,
    kLoginAccessAccountPickerModeTableView,
    kLoginAccessAccountPickerModePickerView
    
} LoginAccessAccountPickerMode;


typedef enum LoginAccessAccountPickerStateTypes {
    
    kLoginAccessAccountPickerStateClosed,
    kLoginAccessAccountPickerStateOpened,
    kLoginAccessAccountPickerStateStamped
    
} LoginAccessAccountPickerState;





@interface LoginAccessAccountPickerViewCell() <UITableViewDataSource, UITableViewDelegate, LoginAccountPickerPickerTableViewCellDelegate>

@property (assign, nonatomic) LoginAccessAccountPickerMode  currentMode;
@property (assign, nonatomic) LoginAccessAccountPickerState currentState;


//Layout
@property (strong, nonatomic) NSMutableArray     *views;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;


//Views
@property (strong, nonatomic) LoginPickerFooterView           *footerView;
@property (strong, nonatomic) LoginAccountPickerTableViewCell *topCell;


//Data
@property (strong, nonatomic) NSMutableArray *accounts;
@property (strong, nonatomic) NSMutableArray *accountsToSelect;


//Outlets
@property (weak, nonatomic) IBOutlet UILabel *accountMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *agLabel;
@property (weak, nonatomic) IBOutlet UILabel *ccLabel;

@end




@implementation LoginAccessAccountPickerViewCell

-(instancetype)initWithProfile:(Profile *)profile {
    self = [self init];
    if (self) {
        [self prepareUI];
        self.profile = profile;
    }
    return self;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        if (!self.views) {
            self.views = [[NSMutableArray alloc] init];
        }
    }
    return self;
}




#pragma mark - Setters

-(void)setSelectedAccount:(Account *)selectedAccount {

    if (self.accountsToSelect) {
        
        if ([self.accountsToSelect containsObject:selectedAccount]) {
            [self.accountsToSelect removeObject:selectedAccount];
        }
        
        if (self.selectedAccount) {
            [self.accountsToSelect addObject:self.selectedAccount];
        }
        
        self.topCell.account = selectedAccount;
    }
    
    self.topCell.account = selectedAccount;
    
    _selectedAccount = selectedAccount;
}

-(void)setProfile:(Profile *)profile {
    
    _profile = profile;
    
    UIImage *avatar;
    
    if (profile.photo) {
        avatar = [UIImage imageWithData:profile.photo];
    } else {

        avatar = [UIImage targetedImageNamed:@"TempAvatar"];
    }
    
    self.profileImageView.image = avatar;
    
    NSString *defaultMessage = @"Bem-vindo(a),\n";
    NSRange range = NSMakeRange(defaultMessage.length, profile.name.length);
    
    NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", defaultMessage, profile.name]];
    
    [attrMessage addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:20.0] range:range];
    
    self.welcomeLabel.attributedText = attrMessage;
    
    self.accounts = [[LoginModel accountsFromProfile:profile] mutableCopy];
}

-(void)setAccounts:(NSMutableArray *)accounts {
    
    _accounts = accounts;
    
    int i = 0;
    
    for (Account *account in accounts) {
        
        if (i == 0) {
            self.selectedAccount = account;
        } else {
            if (!self.accountsToSelect) {
                self.accountsToSelect = [[NSMutableArray alloc] init];
            }
            [self.accountsToSelect addObject:account];
        }
        
        i++;
    }

    [self updateTableView];
}

-(void)setCurrentMode:(LoginAccessAccountPickerMode)currentMode {
    
    _currentMode = currentMode;
    
    switch (currentMode) {
        case kLoginAccessAccountPickerModeLabel:
            [self prepareForModeLabel];
            break;
        case kLoginAccessAccountPickerModeTableView:
            [self prepareForModeTableView];
            break;
        case kLoginAccessAccountPickerModePickerView:
            [self prepareForModePickerView];
            break;
        default: break;
    }
}

-(void)setCurrentState:(LoginAccessAccountPickerState)currentState {
    
    _currentState = currentState;
    
    switch (currentState) {
        case kLoginAccessAccountPickerStateClosed:
            [self prepareForStateClosed];
            break;
        case kLoginAccessAccountPickerStateOpened:
            [self prepareForStateOpened];
            break;
        case kLoginAccessAccountPickerStateStamped:
            //Do something
            break;
        default: break;
    }
}




#pragma mark - Handling modes

-(void)prepareForModeLabel {
    
    self.currentState = kLoginAccessAccountPickerStateStamped;
    self.accountMessageLabel.text = @"agência e conta";
    self.agencyLabel.text = self.selectedAccount.agency;
    self.accountLabel.text = self.selectedAccount.number;
    self.agencyLabel.hidden = NO;
    self.accountLabel.hidden = NO;
    self.agLabel.hidden = NO;
    self.ccLabel.hidden = NO;
}

-(void)prepareForModeTableView {
    
    [self startTableView];
    self.accountMessageLabel.text = @"selecione uma conta";
    self.currentState = kLoginAccessAccountPickerStateClosed;
    self.accountsTableView.hidden = NO;
}

-(void)prepareForModePickerView {
    
    [self startTableView];
    self.accountMessageLabel.text = @"selecione uma conta";
    self.currentState = kLoginAccessAccountPickerStateClosed;
    self.accountsTableView.hidden = NO;
}




#pragma mark - Handling states

-(void)prepareForStateOpened {
    
    if (self.currentState == kLoginAccessAccountPickerStateOpened) {
        
        switch (self.currentMode) {
                
            case kLoginAccessAccountPickerModeTableView: {
                
                CGFloat height;
                NSUInteger index = 0;
                
                NSMutableArray *indexes = [[NSMutableArray alloc] init];
                
                for (Account *account in self.accountsToSelect) {
                    
                    index++;
                    
                    LoginAccountPickerTableViewCell *cell = [[LoginAccountPickerTableViewCell alloc] initWithAccount:account];
                    
                    [self.views insertObject:cell atIndex:index];
                    
                    [indexes addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                    
                    height += cell.bounds.size.height;
                }
                
                self.heightConstraint.constant += height;
                
                //Increase view height
                if (self.delegate && [self.delegate respondsToSelector:@selector(loginAccountPicker:hasNewHeight:)]) {
                    [self.delegate loginAccountPicker:self hasNewHeight:self.heightConstraint.constant];
                }
                
                [self.accountsTableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
                
            } break;
                
            case kLoginAccessAccountPickerModePickerView: {
                
                LoginAccountPickerPickerTableViewCell *pickerCell = [[LoginAccountPickerPickerTableViewCell alloc] initWithAccounts:self.accounts andSelected:self.selectedAccount];
                
                pickerCell.delegate = self;
                
                [self.views addObject:pickerCell];
                
                [self.accountsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                self.heightConstraint.constant += pickerCell.bounds.size.height;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(loginAccountPicker:hasNewHeight:)]) {
                    [self.delegate loginAccountPicker:self hasNewHeight:self.heightConstraint.constant];
                }
                
                [self.accountsTableView reloadData];
                
            } break;
                
            default: break;
        }
        
    }
}

-(void)prepareForStateClosed {
    
    //Decrease view height
    if (self.currentState == kLoginAccessAccountPickerStateClosed) {
        
        if (self.views.count > 1) {
            
            [self.accountsTableView beginUpdates];
            
            for (NSInteger index = self.views.count-1; index > 0; index--) {
                
                [self.accountsTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                id object = self.views[index];
                
                self.heightConstraint.constant -= ((UIView *)object).bounds.size.height;
                
                [self.views removeObject:self.views[index]];
            }
            
            [self.accountsTableView endUpdates];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(loginAccountPicker:hasNewHeight:)]) {
                [self.delegate loginAccountPicker:self hasNewHeight:self.heightConstraint.constant];
            }
        }
    }
}

-(void)prepareForStateStamped {
    //Update view height
}




#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.views.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.views[indexPath.row];
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    return indexPath;
}






#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ((UIView *)self.views[indexPath.row]).bounds.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != 0) {
        LoginAccountPickerTableViewCell *cell = (LoginAccountPickerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        self.selectedAccount = cell.account;
    }
    
    [self showHideDataToSelect];
    [self.footerView rotate];
}




#pragma mark - LoginAccountPickerPickerTableViewCellDelegate

-(void)loginAccountPickerPickerTableViewCell:(LoginAccountPickerPickerTableViewCell *)cell hasNewSelectedAccount:(Account *)account {
    
    self.selectedAccount = account;
}




#pragma mark - Helpers

-(void)prepareUI {
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width/2;
    
    self.contentView.backgroundColor = [UIColor targetPrimaryColor];
    
    self.agencyLabel.hidden = YES;
    self.accountLabel.hidden = YES;
    self.agLabel.hidden = YES;
    self.ccLabel.hidden = YES;

    self.accountsTableView.hidden = YES;
    self.accountsTableView.layer.cornerRadius = 4.0;
    self.accountsTableView.clipsToBounds = YES;
    
    if (!self.heightConstraint) {
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.bounds.size.height];
    }
    
    [self addConstraint:self.heightConstraint];
    
}

-(void)updateTableView {
    
    NSArray *accounts = [LoginModel accountsFromProfile:self.profile];
    if (accounts.count > 1) {
        self.currentMode =
        (accounts.count <= TABLE_LIMIT)
        ? kLoginAccessAccountPickerModeTableView
        : kLoginAccessAccountPickerModePickerView;
    } else {
        self.currentMode = kLoginAccessAccountPickerModeLabel;
    }

}

-(void)startTableView {
    
    self.accountsTableView.dataSource = self;
    self.accountsTableView.delegate = self;
    
    if (!self.footerView) {
        self.footerView = [[LoginPickerFooterView alloc] init];
        [[self.footerView.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self showHideDataToSelect];
        }];
    }
    
    self.accountsTableView.tableFooterView = self.footerView;
    
    if (!self.topCell) {
        self.topCell = [[LoginAccountPickerTableViewCell alloc] init];
    }
    
    self.topCell.account = self.selectedAccount;
    
    [self.views insertObject:self.topCell atIndex:0];
}

-(void)showHideDataToSelect {
    
    if (self.currentMode == kLoginAccessAccountPickerModeTableView ||
        self.currentMode == kLoginAccessAccountPickerModePickerView) {
        
        if (self.currentState == kLoginAccessAccountPickerStateClosed) {
            self.currentState = kLoginAccessAccountPickerStateOpened;
        } else if (self.currentState == kLoginAccessAccountPickerStateOpened) {
            self.currentState = kLoginAccessAccountPickerStateClosed;
        }
    }
}





@end
