//
//  LoginSidebar.m
//  Itau
//
//  Created by a2works on 05/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "ProfileSidebar.h"
#import "ProfileItemCell.h"
#import "NSString+Utils.h"
#import "UIImage+Itau.h"
#import "LoginModel.h"


#define PROFILE_CELL_HEIGHT   128
#define PROFILES_TABLE_HEIGHT 148
#define PROFILES_LIMIT          3

@interface ProfileSidebar() <LoginNewAccessViewDelegate, LoginProfileItemCellDelegate, LoginAccessProfileViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIToolbar          *blurView;
@property (strong, nonatomic) GaussianBlurFilter *curtain;

@property (strong, nonatomic) NSMutableSet       *profileCells;
@property (strong, nonatomic) NSMutableArray     *profiles;
@property (strong, nonatomic) ProfileItemCell    *itemCellToDelete;
@property (strong, nonatomic) NSLayoutConstraint *popupCenterYConstraint;
@property (strong, nonatomic) LoginPopupView     *activePopup;

@end

@implementation ProfileSidebar


-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSidebar];
    }
    return self;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    [self.blurView setFrame:self.bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)setAddButton:(AddProfileView *)addButton {
    
    if (!_addButton) {
        _addButton = addButton;
    }
    
    _addButton.delegate = self;
}

-(void)setIconImageView:(UIImageView *)iconImageView {
    
    if (!_iconImageView) {
        _iconImageView = iconImageView;
    }

    _iconImageView.image = [UIImage targetedImageNamed:@"Brand"];
}

-(void)setProfilesTableView:(UITableView *)profilesTableView {
    
    if (!_profilesTableView) {
        _profilesTableView = profilesTableView;
    }
}

-(void)setupSidebar {
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self stopWiggleAllProfileItemCells];
    }];
    
    self.backgroundColor = [UIColor clearColor];
    self.profileCells = [[NSMutableSet alloc] initWithCapacity:3];
    
    if (!self.profiles) {
        
        NSError *error = nil;
        
        self.profiles = [[LoginModel allProfilesUsingError:&error] mutableCopy];
    }
    
    self.iconImageView.image = [UIImage targetedImageNamed:@"Brand"];
    
    if (!self.blurView) {
        
        self.blurView = [[UIToolbar alloc] init];
        [self.blurView setFrame:self.bounds];
        [self.layer insertSublayer:[self.blurView layer] atIndex:0];
    }
    
    [self.profilesTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)startWiggleProfileItemCell:(ProfileItemCell *)profileItemCell {
    
    [profileItemCell startWiggle];
}

- (void)stopWiggleFromProfileItemCell:(ProfileItemCell *)profileItemCell {
    
    [profileItemCell stopWiggle];
}

-(void)startWiggleAllProfileItemCells {
    
    for (ProfileItemCell *profileItem in self.profileCells) {
        [profileItem startWiggle];
    }
}

-(void)stopWiggleAllProfileItemCells {
    
    for (ProfileItemCell *profileItem in self.profileCells) {
        [profileItem stopWiggle];
    }
}

-(void)showCurtain {
    
    if (!self.curtain) {
        self.curtain = [[GaussianBlurFilter alloc] init];
        self.curtain.blurRadius = 6;
        [self.curtain setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.superview insertSubview:self.curtain belowSubview:self.activePopup];
        
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.curtain
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.superview
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:-90.0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.curtain
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.superview
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:90.0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.curtain
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.superview
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1
                                                                    constant:-90.0]];
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.curtain
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.superview
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1
                                                                    constant:90.0]];
        
        [self.superview layoutIfNeeded];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissActivePopup)];
        [tapGestureRecognizer addTarget:self action:@selector(hideCurtain)];

        [self.curtain addGestureRecognizer:tapGestureRecognizer];
    }
    
    if ([self.activePopup isKindOfClass:[LoginNewAccessPopupView class]]) {
        [((LoginNewAccessPopupView *)self.activePopup).agencyAccountViewCell.agencyTextField.textField becomeFirstResponder];
    }
}

-(void)hideCurtain {
    
    if (!self.activePopup || self.activePopup.canDismiss) {
        
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.curtain.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [self.curtain removeFromSuperview];
                             self.curtain = nil;
                         }];
    }
}

-(void)dismissActivePopup {
    
    if (self.activePopup.canDismiss) {
        [self.activePopup dismiss];
        self.activePopup = nil;
    }
}




#pragma mark - LoginAddProfileViewDelegate

-(void)addProfileViewDidTouch:(AddProfileView *)addProfileView {
    
    [self stopWiggleAllProfileItemCells];
    
    if (!self.activePopup) {
        
        self.activePopup = [LoginNewAccessPopupView startLoginNewAccessViewWithProfiles:self.profiles];
    }
    
    self.activePopup.alpha = 0.0;
    ((LoginNewAccessPopupView *)self.activePopup).delegate = self;
    
    [self.activePopup setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.superview insertSubview:self.activePopup atIndex:self.superview.subviews.count];
    
    [self addPopupConstraints];
    
    [self showCurtain];

    [UIView animateWithDuration:0.3 animations:^{
        self.activePopup.alpha = 1.0;
    }];
}




#pragma mark - LoginAccessProfileViewDelegate

-(void)loginAccessProfileView:(LoginAccessProfilePopupView *)loginView willFinishWithAccount:(Account *)account {
    
    NSError *error = nil;
    
    account.lastAccess =  [NSDate date];
    
    [LoginModel saveAccount:account usingError:&error];
    
    if (!error) {
        [self dismissActivePopup];
        [self hideCurtain];
    }
}

-(void)loginAccessProfileView:(LoginAccessProfilePopupView *)loginView didUpdateProfile:(Profile *)profile {
    
    [self.profilesTableView reloadData];
}



#pragma mark - LoginNewAccessViewDelegate

-(void)loginNewAccessView:(LoginNewAccessPopupView *)newAccessView willFinishWithAccount:(Account *)account owner:(NSDictionary *)owner createProfile:(BOOL)createProfile {
    
    NSError *error = nil;
    
    NSString *name = [NSString trimmedStringWithoutDoubleSpace:owner[@"nome_titular"]];
    NSArray *nameComponents = [name componentsSeparatedByString:@" "];
    name = [[nameComponents firstObject] capitalizedString];
    
    Profile *aProfile = [LoginModel profileWithName:name
                                                CPF:owner[@"cpf"]
                                          photoData:nil
                                         usingError:&error];
    
    [LoginModel insertAccount:account intoProfile:aProfile];
    
    [LoginModel saveProfile:aProfile usingError:&error];
    
    if (!error) {
        
        BOOL flag = NO;
        
        for (Profile *profile in self.profiles) {
            if (aProfile.cpf == profile.cpf) {
                flag = YES;
            }
            if (flag) {
                break;
            }
        }
        
        if ([self canAddProfile]) {
            if (createProfile && !flag) {
                NSIndexPath *index = [NSIndexPath indexPathForRow:self.profiles.count inSection:0];
                [self.profiles insertObject:aProfile atIndex:index.row];
                [self.profilesTableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [self updateTableConstraints];
            }
        } else {
            NSLog(@"Não pode adicionar mais que três perfis");
        }

        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self layoutSubviews];
            [self.profilesTableView reloadData];
            [self updateAddButtonTitle];
        }];
            
    }
    
    [self dismissActivePopup];
    [self hideCurtain];
}




#pragma mark - LoginProfileItemCellDelegate

-(void)loginProfileItemCell:(ProfileItemCell *)itemCell didReceiveLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture {
    
    [self startWiggleAllProfileItemCells];
}

-(void)loginProfileItemCellDidPressDeleteButton:(ProfileItemCell *)itemCell {
    
    self.itemCellToDelete = itemCell;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmação"
                                                    message:@"Tem certeza que deseja excluir o perfil selecionado? Esta ação não poderá ser desfeita."
                                                   delegate:self
                                          cancelButtonTitle:@"Desistir"
                                          otherButtonTitles:@"Excluir", nil];
    
    [alert show];
}

-(void)loginProfileItemCellDidPressAccessProfile:(ProfileItemCell *)itemCell {
    
    [self stopWiggleAllProfileItemCells];
    
    if (!self.activePopup) {
        
        self.activePopup = [[LoginAccessProfilePopupView alloc] initWithProfile:itemCell.profile];
    }
    
    ((LoginAccessProfilePopupView *)self.activePopup).delegate = self;
    [[((LoginAccessProfilePopupView *)self.activePopup).accountPicker.addAccountButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self dismissActivePopup];
        [self addProfileViewDidTouch:nil];
    }];
    
    self.activePopup.alpha = 0.0;
    
    [self.activePopup setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.superview insertSubview:self.activePopup aboveSubview:self];
    
    [self addPopupConstraints];
    
    [self showCurtain];

    [UIView animateWithDuration:0.3 animations:^{
        self.activePopup.alpha = 1.0;
    }];
}

-(void)addPopupConstraints {
    
    [self.activePopup addConstraint:[NSLayoutConstraint constraintWithItem:self.activePopup
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1
                                                                  constant:320]];
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.activePopup
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0]];
    
    self.popupCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.activePopup
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];
    
    [self.superview addConstraint:self.popupCenterYConstraint];
}




#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [self stopWiggleAllProfileItemCells];

    if (buttonIndex != 0) {
        
        NSError *error = nil;
        
        Profile *profile = self.itemCellToDelete.profile;
        
        [LoginModel deleteProfile:profile usingError:&error];
        
        if (!error) {
            
            [self.profiles removeObjectAtIndex:self.itemCellToDelete.indexPath.row];
            
            [self.profilesTableView deleteRowsAtIndexPaths:@[self.itemCellToDelete.indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [self updateTableConstraints];

            [UIView animateWithDuration:0.3 animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self layoutSubviews];
                [self.profilesTableView reloadData];
                [self updateAddButtonTitle];
            }];
        }
    }
}




#pragma mark - UITableViewDelegate

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}




#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [self updateAddButtonTitle];
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.profiles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ProfileCell";
    
    ProfileItemCell *profileCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (profileCell == nil) {
        profileCell = [[ProfileItemCell alloc] init];
    }
    
    profileCell.profile = self.profiles[indexPath.row];
    profileCell.delegate = self;
    profileCell.indexPath = indexPath;
    
    [self.profileCells addObject:profileCell];
    [self updateAddButtonTitle];
    [self updateTableConstraints];
    
    return profileCell;
}




#pragma mark - Helpers

-(void)updateTableConstraints {
    
    NSLayoutConstraint *constraint = self.profilesTableView.constraints[0];
    constraint.constant = self.profiles.count * PROFILE_CELL_HEIGHT + PROFILES_TABLE_HEIGHT;
}

-(BOOL)canAddProfile {
    
    return self.profiles.count < PROFILES_LIMIT;
}

-(void)updateAddButtonTitle {
    
    NSString *title = self.profiles.count > 0 ? @"acessar\noutra conta" : @"acessar\nminha conta";
    
    self.profilesTableView.tableFooterView.accessibilityElementsHidden = YES;
    self.profilesTableView.tableHeaderView.accessibilityElementsHidden = YES;
    self.profilesTableView.accessibilityLabel = @"Menu principal";
    self.addButton.titleLabel.accessibilityElementsHidden = YES;
    self.addButton.button.accessibilityElementsHidden = NO;

    self.addButton.titleLabel.text =
    self.addButton.button.accessibilityLabel = title;
}




#pragma mark - NSNotification selectors

-(void)keyboardWillShow:(NSNotification *)notification {
    
    self.popupCenterYConstraint.constant = -60.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.superview layoutIfNeeded];
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    self.popupCenterYConstraint.constant = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.superview layoutIfNeeded];
    }];
}

@end
