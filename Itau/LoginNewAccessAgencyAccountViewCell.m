//
//  LoginNewAccessStepOneViewCell.m
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginNewAccessAgencyAccountViewCell.h"
#import "NumericKeyboard.h"
#import "UIColor+Itau.h"

@interface LoginNewAccessAgencyAccountViewCell() <NumericKeyboardDelegate>

@property (weak, nonatomic) IBOutlet UIView *agencyTextFieldWrapperView;
@property (weak, nonatomic) IBOutlet UIView *accountTextFieldWrapperView;
@property (strong, nonatomic) NumericKeyboard *numericKeyboard;

@end

@implementation LoginNewAccessAgencyAccountViewCell

-(instancetype)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        [self prepareUI];
    }
    return self;
}

-(void)prepareUI {
    
    self.contentView.backgroundColor = [UIColor targetPrimaryColor];
    
    if (!self.agencyTextField) {
        self.agencyTextField = [TextFieldAndroidStyle textFieldAndroidStyleWithThemeColor:[UIColor whiteColor] type:kTextFieldAndroidStyleTypeAgency];
        [self.agencyTextField setFrame:self.agencyTextFieldWrapperView.bounds];
        [self.agencyTextField setPlaceholderString:@"agência"];
    }
    
    [self.agencyTextFieldWrapperView addSubview:self.agencyTextField];
    
    if (!self.accountTextField) {
        self.accountTextField = [TextFieldAndroidStyle textFieldAndroidStyleWithThemeColor:[UIColor whiteColor] type:kTextFieldAndroidStyleTypeAccount];
        [self.accountTextField setFrame:self.accountTextFieldWrapperView.bounds];
        [self.accountTextField setPlaceholderString:@"conta"];
    }
    
    [self.accountTextFieldWrapperView addSubview:self.accountTextField];
    
    if (!self.numericKeyboard) {
        self.numericKeyboard = [NumericKeyboard defaultNumericKeyboard];
    }
    
    self.numericKeyboard.delegate = self;
    [self.numericKeyboard setTargets:@[self.agencyTextField.textField, self.accountTextField.textField] success:nil];
}




#pragma mark - NumericKeyboarDelegate

-(void)numericKeyboard:(NumericKeyboard *)keyboard doneKeyPressedWithResponder:(UIResponder<UITextInput> *)responder {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginNewAccessAgencyAccountViewCell:didPressDoneButtonWithResponder:)]) {
        [self.delegate loginNewAccessAgencyAccountViewCell:self didPressDoneButtonWithResponder:responder];
    }
    
}

@end
