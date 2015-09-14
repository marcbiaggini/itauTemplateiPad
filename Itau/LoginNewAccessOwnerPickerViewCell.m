//
//  LoginNewAccessStepTwoViewCell.m
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//


#define TABLE_LIMIT 3

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "LoginNewAccessOwnerPickerViewCell.h"
#import "LoginPickerFooterView.h"
#import "LoginOwnerPickerPickerTableViewCell.h"
#import "LoginOwnerPickerTableViewCell.h"
#import "UIColor+Itau.h"
#import "NSString+Utils.h"
#import "UIImage+Itau.h"


typedef enum LoginNewAccessOwnerPickerModeTypes {
    
    kLoginNewAccessOwnerPickerModeLabel,
    kLoginNewAccessOwnerPickerModeTableView,
    kLoginNewAccessOwnerPickerModePickerView
    
} LoginNewAccessOwnerPickerMode;


typedef enum LoginNewAccessOwnerPickerStateTypes {
    
    kLoginNewAccessOwnerPickerStateClosed,
    kLoginNewAccessOwnerPickerStateOpened,
    kLoginNewAccessOwnerPickerStateStamped
    
} LoginNewAccessOwnerPickerState;




@interface LoginNewAccessOwnerPickerViewCell() <UITableViewDataSource, UITableViewDelegate, LoginOwnerPickerPickerTableViewCellDelegate>

@property (assign, nonatomic) LoginNewAccessOwnerPickerMode  currentMode;
@property (assign, nonatomic) LoginNewAccessOwnerPickerState currentState;

@property (strong, nonatomic) NSArray                       *owners;
@property (strong, nonatomic) NSMutableArray                *ownersToSelect;
@property (strong, nonatomic) NSLayoutConstraint            *heightConstraint;

@property (strong, nonatomic) LoginOwnerPickerTableViewCell *topCell;
@property (strong, nonatomic) NSMutableArray                *views;
@property (strong, nonatomic) LoginPickerFooterView         *footerView;

@property (strong, nonatomic) IBOutlet UIView               *switchWrapperView;

@property (weak, nonatomic) IBOutlet UILabel                *ownerLabel;
@property (weak, nonatomic) IBOutlet UITableView            *ownersTableView;

@end




@implementation LoginNewAccessOwnerPickerViewCell

-(instancetype)initWithOwners:(NSArray *)owners {
    self = [self init];
    if (self) {
        self.owners = owners;
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
        [self prepareUI];
    }
    return self;
}




#pragma mark - Setters

-(void)setOwners:(NSArray *)owners {
    
    _owners = owners;
    
    if (owners.count > 1) {
        
        for (int i = 0; i < owners.count; i++) {
            
            NSDictionary *owner = owners[i];
            
            if (i == 0) {
                self.selectedOwner = owner;
            } else {
                if (!self.ownersToSelect) {
                    self.ownersToSelect = [[NSMutableArray alloc] init];
                }
                [self.ownersToSelect addObject:owner];
            }
        }

        self.currentMode =
        (owners.count <= TABLE_LIMIT)
        ? kLoginNewAccessOwnerPickerModeTableView
        : kLoginNewAccessOwnerPickerModePickerView;
    } else {
        self.selectedOwner = owners[0];
        self.currentMode = kLoginNewAccessOwnerPickerModeLabel;
    }
}

-(void)setSelectedOwner:(NSDictionary *)selectedOwner {
    
    if (self.ownersToSelect) {
        
        if ([self.ownersToSelect containsObject:selectedOwner]) {
            [self.ownersToSelect removeObject:selectedOwner];
        }
        
        if (self.selectedOwner) {
            [self.ownersToSelect addObject:self.selectedOwner];
        }

        self.topCell.owner = selectedOwner;
    }
    
    _selectedOwner = selectedOwner;
}

-(void)setCurrentMode:(LoginNewAccessOwnerPickerMode)currentMode {
    
    _currentMode = currentMode;

    switch (currentMode) {
        case kLoginNewAccessOwnerPickerModeLabel:
            [self prepareForModeLabel];
            break;
        case kLoginNewAccessOwnerPickerModeTableView:
            [self prepareForModeTableView];
            break;
        case kLoginNewAccessOwnerPickerModePickerView:
            [self prepareForModePickerView];
            break;
        default: break;
    }
}

-(void)setCurrentState:(LoginNewAccessOwnerPickerState)currentState {
    
    _currentState = currentState;
    
    switch (currentState) {
        case kLoginNewAccessOwnerPickerStateClosed:
            [self prepareForStateClosed];
            break;
        case kLoginNewAccessOwnerPickerStateOpened:
            [self prepareForStateOpened];
            break;
        case kLoginNewAccessOwnerPickerStateStamped:
            //Do something
            break;
        default: break;
    }
}

-(void)setDelegate:(id<LoginOwnerPickerViewCellDelegate>)delegate {
    
    _delegate = delegate;
    
    if ([delegate respondsToSelector:@selector(loginOwnerPickerShouldAllowSavingProfile:)]) {
        
        BOOL isOn = [self.delegate loginOwnerPickerShouldAllowSavingProfile:self];
        
        [self.saveProfileSwitch setOn:isOn animated:YES];
        [self.saveProfileSwitch setEnabled:isOn];
        
    }
}




#pragma mark - Handling states

-(void)prepareForStateOpened {
    
    if (self.currentState == kLoginNewAccessOwnerPickerStateOpened) {
    
        switch (self.currentMode) {
                
            case kLoginNewAccessOwnerPickerModeTableView: {
                
                CGFloat height;
                NSUInteger index = 0;
                
                NSMutableArray *indexes = [[NSMutableArray alloc] init];

                for (NSDictionary *owner in self.ownersToSelect) {
                    
                    index++;

                    LoginOwnerPickerTableViewCell *cell = [[LoginOwnerPickerTableViewCell alloc] init];
                    cell.owner = owner;
                    
                    [self.views insertObject:cell atIndex:index];
                    
                    [indexes addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                    
                    height += cell.bounds.size.height;
                }
                
                self.heightConstraint.constant += height;
                
                //Increase view height
                if (self.delegate && [self.delegate respondsToSelector:@selector(loginOwnerPicker:hasNewHeight:)]) {
                    [self.delegate loginOwnerPicker:self hasNewHeight:self.heightConstraint.constant];
                }

                [self.ownersTableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];

            } break;
                
            case kLoginNewAccessOwnerPickerModePickerView: {
                
                LoginOwnerPickerPickerTableViewCell *pickerCell = [[LoginOwnerPickerPickerTableViewCell alloc] initWithOwners:self.owners andSelected:self.selectedOwner];
                pickerCell.delegate = self;
                
                [self.views addObject:pickerCell];
                
                [self.ownersTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                self.heightConstraint.constant += pickerCell.bounds.size.height;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(loginOwnerPicker:hasNewHeight:)]) {
                    [self.delegate loginOwnerPicker:self hasNewHeight:self.heightConstraint.constant];
                }
                
                [self.ownersTableView reloadData];
                
            } break;
                
            default: break;
        }
    }
}

-(void)prepareForStateClosed {
    
    //Decrease view height
    if (self.currentState == kLoginNewAccessOwnerPickerStateClosed) {
        
        if (self.views.count > 1) {
            
            [self.ownersTableView beginUpdates];
            
            for (NSInteger index = self.views.count-1; index > 0; index--) {
                
                [self.ownersTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                id object = self.views[index];
                self.heightConstraint.constant -= ((UIView *)object).bounds.size.height;
                
                [self.views removeObject:object];
            }
            
            [self.ownersTableView endUpdates];

            if (self.delegate && [self.delegate respondsToSelector:@selector(loginOwnerPicker:hasNewHeight:)]) {
                [self.delegate loginOwnerPicker:self hasNewHeight:self.heightConstraint.constant];
            }
        }
    }
}

-(void)prepareForStateStamped {
    //Update view height
}




#pragma mark - Handling modes

-(void)prepareForModeLabel {
    
    self.currentState = kLoginNewAccessOwnerPickerStateStamped;
    
    self.ownerLabel.text = [NSString trimmedStringWithoutDoubleSpace:self.selectedOwner[@"nome_titular"]];
    self.ownerLabel.hidden = NO;
}

-(void)prepareForModeTableView {
    
    [self startTableView];
    self.currentState = kLoginNewAccessOwnerPickerStateClosed;
    self.ownersTableView.hidden = NO;
}

-(void)prepareForModePickerView {
    
    [self startTableView];
    self.currentState = kLoginNewAccessOwnerPickerStateClosed;
    self.ownersTableView.hidden = NO;
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
        LoginOwnerPickerTableViewCell *cell = (LoginOwnerPickerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        self.selectedOwner = cell.owner;
    }
    
    [self showHideDataToSelect];
    [self.footerView rotate];
}




#pragma mark - LoginOwnerPickerPickerTableViewCellDelegate

-(void)loginOwnerPickerPickerTableViewCell:(LoginOwnerPickerPickerTableViewCell *)cell hasNewSelectedOwner:(NSDictionary *)owner {

    self.selectedOwner = owner;
}




#pragma mark - Helpers

-(void)prepareUI {
    
    self.ownerLabel.hidden = YES;
    self.contentView.backgroundColor = [UIColor targetPrimaryColor];

    //Table view
    self.ownersTableView.layer.cornerRadius = 4.0;
    self.ownersTableView.clipsToBounds = YES;
    self.ownersTableView.hidden = YES;
    
    if (!self.heightConstraint) {
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.bounds.size.height];
    }
    
    [self addConstraint:self.heightConstraint];
    
    self.saveProfileSwitch = [[SwitchControl alloc] initWithFrame:self.switchWrapperView.bounds];
    [self.saveProfileSwitch setOnColor:[UIColor clearColor]];
    [self.saveProfileSwitch setInactiveColor:[UIColor clearColor]];
    self.saveProfileSwitch.isRounded = NO;
    [self.saveProfileSwitch setOffImage:[UIImage targetedImageNamed:@"bt_switch_off"]];
    [self.saveProfileSwitch setOnImage:[UIImage targetedImageNamed:@"bt_switch_on"]];
    [self.saveProfileSwitch setBorderColor:[UIColor clearColor]];
    [self.saveProfileSwitch setKnobColor:[UIColor whiteColor]];
    [self.switchWrapperView addSubview:self.saveProfileSwitch];
}

-(void)startTableView {
    
    self.ownersTableView.dataSource = self;
    self.ownersTableView.delegate = self;
    
    if (!self.footerView) {
        self.footerView = [[LoginPickerFooterView alloc] init];
        [[self.footerView.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self showHideDataToSelect];
        }];
    }
    
    self.ownersTableView.tableFooterView = self.footerView;
    
    if (!self.topCell) {
        self.topCell = [[LoginOwnerPickerTableViewCell alloc] init];
    }
    
    self.topCell.owner = self.selectedOwner;
    
    [self.views insertObject:self.topCell atIndex:0];
}

-(void)showHideDataToSelect {
    
    if (self.currentMode == kLoginNewAccessOwnerPickerModeTableView ||
        self.currentMode == kLoginNewAccessOwnerPickerModePickerView) {
        
        if (self.currentState == kLoginNewAccessOwnerPickerStateClosed) {
            self.currentState = kLoginNewAccessOwnerPickerStateOpened;
        } else if (self.currentState == kLoginNewAccessOwnerPickerStateOpened) {
            self.currentState = kLoginNewAccessOwnerPickerStateClosed;
        }
    }
}

@end
