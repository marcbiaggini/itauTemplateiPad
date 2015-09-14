//
//  LoginProfileItemCell.m
//  Itau
//
//  Created by a2works on 06/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "ProfileItemCell.h"
#import "UIImage+Itau.h"
#import <QuartzCore/QuartzCore.h>

@interface ProfileItemCell() {
    CGPoint _centerPoint;
}

@property (assign, nonatomic) BOOL isAffraid;

@end

@implementation ProfileItemCell

- (void)awakeFromNib {
    
    CGAffineTransform scale = CGAffineTransformMakeScale(0.0, 0.0);
    self.deleteProfileButton.transform = scale;
    self.isAffraid = NO;
}

-(void)layoutSubviews {
    
    self.contentView.accessibilityElementsHidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

-(void)setIsAffraid:(BOOL)isAffraid {
    
    _isAffraid = isAffraid;
    CGFloat scale = _isAffraid ? 1.0 : 0.0;
    
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.deleteProfileButton.transform = CGAffineTransformMakeScale(scale, scale);
    } completion:nil];
}

-(void)setProfile:(Profile *)profile {
    
    _profile = profile;
    self.profileNameLabel.text = profile.name;
    self.profileButton.accessibilityLabel = [NSString stringWithFormat:@"Acessar o perfil de: %@", profile.name];
    
    UIImage *avatar;
    
    if (profile.photo) {
        
        avatar = [UIImage imageWithData:profile.photo];
        
    } else {
        
        avatar = [UIImage targetedImageNamed:@"TempAvatar"];
    }
    
    [self.profileButton setImage:avatar forState:UIControlStateNormal];
}

-(void)startWiggle {
    
    if (!self.isAffraid) {
        
        _centerPoint = self.center;
        
        self.isAffraid = YES;
        
        CGFloat angle = 1.85 * M_PI/180;
        
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeRotation(angle);
            self.transform = CGAffineTransformMakeRotation(-angle);
        } completion:nil];
        
        [UIView animateWithDuration:0.085 delay:0.15 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.center = CGPointMake(self.center.x, self.center.y + 1.0);
            self.center = CGPointMake(self.center.x, self.center.y - 1.0);
        } completion:nil];
    }
}

-(void)stopWiggle {
    
    if (self.isAffraid) {
        
        self.isAffraid = NO;
        
        [UIView animateWithDuration:0.1 delay:0.35 options: UIViewAnimationOptionBeginFromCurrentState animations:^{
            [UIView animateWithDuration:0.1 animations:^{
                self.transform = CGAffineTransformMakeRotation(0.0);
                self.center = _centerPoint;
            }];
        } completion:^(BOOL finished) {
            [self.layer removeAllAnimations];
        }];
    }
}

-(void)setProfileButton:(UIButton *)profileButton {

    if (!_profileButton) {
        _profileButton = profileButton;
    }
}

#pragma mark - Overriding

-(void)willMoveToSuperview:(UIView *)newSuperview {
    
    self.isAffraid = NO;
    self.backgroundColor = [UIColor clearColor];
    [self.deleteProfileButton setImage:[UIImage targetedImageNamed:@"DeleteProfileButton"] forState:UIControlStateNormal];
    self.profileButton.layer.cornerRadius = self.profileButton.bounds.size.width/2;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressReceived:)];
    [self.profileButton addGestureRecognizer:longPress];
}

-(void)longPressReceived:(UILongPressGestureRecognizer *)sender {
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginProfileItemCell:didReceiveLongPressGesture:)]) {
        [self.delegate loginProfileItemCell:self didReceiveLongPressGesture:sender];
    }
}

#pragma mark - IBActions

-(IBAction)deleteProfile:(UIButton *)sender {
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginProfileItemCellDidPressDeleteButton:)]) {
        [self.delegate loginProfileItemCellDidPressDeleteButton:self];
    }
    
}

-(IBAction)accessProfile:(UIButton *)sender {

    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginProfileItemCellDidPressAccessProfile:)]) {
        [self.delegate loginProfileItemCellDidPressAccessProfile:self];
    }
}

@end
