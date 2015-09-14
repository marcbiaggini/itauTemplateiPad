//
//  LoginKeyboardViewCell.m
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LoginKeyboardTableViewCell.h"
#import "UIColor+Itau.h"

typedef enum LoginKeyboardButtonTypes {
    kLoginKeyboardButtonTopLeft = 0,
    kLoginKeyboardButtonTopMiddle = 1,
    kLoginKeyboardButtonTopRight = 2,
    kLoginKeyboardButtonBottomLeft = 3,
    kLoginKeyboardButtonBottomMiddle = 4,
    kLoginKeyboardButtonDelete = 5
} LoginKeyboardButton;

@interface LoginKeyboardTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *topLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *topMiddleButton;
@property (weak, nonatomic) IBOutlet UIButton *topRightButton;

@property (weak, nonatomic) IBOutlet UIButton *bottomLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomMiddleButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIView *passwordTextFieldWrapperView;
@property (weak, nonatomic) IBOutlet UIView *keyboardWrapperView;

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSMutableDictionary *codes;

@end

@implementation LoginKeyboardTableViewCell

-(instancetype)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        self.codes = [[NSMutableDictionary alloc] initWithCapacity:5];
        [self prepareUI];
    }
    return self;
}

-(instancetype)initWithIdentifier:(NSString *)identifier {
    self = [self init];
    if (self) {
        
        self.identifier = identifier;
    }
    return self;
}

-(void)prepareUI {
    
    self.contentView.backgroundColor = [UIColor targetPrimaryColor];
    
    for (id object in self.keyboardWrapperView.subviews) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *button = object;
            button.layer.cornerRadius = 4.0;
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            [button setEnabled:NO];
        }
    }
    
    if (!self.passwordTextField) {
        self.passwordTextField = [TextFieldAndroidStyle textFieldAndroidStyleWithThemeColor:[UIColor whiteColor] type:kTextFieldAndroidStyleTypePassword];
        [self.passwordTextField setPlaceholderString:@"senha eletrônica"];
        [self.passwordTextField.textField setSecureTextEntry:YES];
        [self.passwordTextField.textField setUserInteractionEnabled:NO];
        [self.passwordTextField setFrame:self.passwordTextFieldWrapperView.bounds];
        
        [self.passwordTextFieldWrapperView addSubview:self.passwordTextField];

        UIImageView *lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_lock"]];
        self.passwordTextField.textField.leftView = lock;
        self.passwordTextField.textField.leftViewMode = UITextFieldViewModeAlways;
    }
}

-(IBAction)buttonPressed:(UIButton *)sender {
    
    if (self.identifier) {
        
        switch (sender.tag) {
            case kLoginKeyboardButtonDelete:
                if (self.passwordTextField.textField.text.length > 0) {
                    NSRange lastCharRange = NSMakeRange(self.passwordTextField.textField.text.length - 1, 1);
                    self.passwordTextField.textField.text = [self.passwordTextField.textField.text stringByReplacingCharactersInRange:lastCharRange withString:@""];
                } break;
            default:
                if (self.passwordTextField.textField.text.length < 9) {
                    self.passwordTextField.textField.text = [self.passwordTextField.textField.text stringByAppendingString:self.codes[sender.titleLabel.text]];
                } break;
        }
    }
}

-(void)updateUsingIdentifier:(NSString *)identifier {
    
    self.identifier = identifier;
}

-(void)setIdentifier:(NSString *)identifier {
    
    _identifier = identifier;
    
    NSString *substring = [identifier substringFromIndex:7];
    
    NSString *temp;
    
    NSArray *buttons = self.keyboardWrapperView.subviews;
    
    for (int x = 0; x < buttons.count-1; x++) {
        
        temp = [substring substringWithRange:NSMakeRange(0, 3)];
        substring = [substring substringFromIndex:3];
        NSString *letter = [temp substringWithRange:NSMakeRange(0, 1)];
        NSString *num = [temp substringWithRange:NSMakeRange(1, 2)];
        NSString *title = [[NSString alloc] initWithFormat:@"%@%@%@", [num substringToIndex:1], @" ou ", [num substringFromIndex:1]];
        [self.codes setObject:letter forKey:title];
        
        UIButton *button = (UIButton *)[self.keyboardWrapperView viewWithTag:x];
        [button setTitle:title forState:UIControlStateNormal];
        [button setEnabled:YES];
    }
    
    [self.deleteButton setEnabled:YES];
}

@end
