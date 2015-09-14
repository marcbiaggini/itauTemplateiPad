//
//  TextFieldAndroidStyle.m
//  Itau
//
//  Created by a2works on 13/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TextFieldAndroidStyle.h"
#import "UIColor+Tools.h"

NSString * const TextFieldAndroidStyleEndOfEditingWithMaskNotification = @"TextFieldAndroidStyleEndOfEditingWithMaskNotification";


typedef enum TextFieldAndroidStyleStateTypes {
    
    kTextFieldAndroidStyleStateReady,
    kTextFieldAndroidStyleStateEditing,
    kTextFieldAndroidStyleStateStamp
    
} TextFieldAndroidStyleState;


@interface TextFieldAndroidStyle() {
    NSString *_pattern;
    NSUInteger _maxLength;
    NSUInteger _limitLenght;
    NSString *_currentText;
}

@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIView *baselineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeholderTopLayoutConstraint;

@property (assign, nonatomic) TextFieldAndroidStyleState currentState;
@property (assign, nonatomic) TextFieldAndroidStyleType type;
@property (weak, nonatomic) UIColor *themeColor;

@end

@implementation TextFieldAndroidStyle

-(instancetype)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        [self setStandards];
    }
    return self;
}

+(instancetype)textFieldAndroidStyleWithThemeColor:(UIColor *)color type:(TextFieldAndroidStyleType)type {
    TextFieldAndroidStyle *textField = [[TextFieldAndroidStyle alloc] init];
    if (textField) {
        textField.themeColor = color;
        textField.type = type;
    }
    return textField;
}




#pragma mark - Setters

-(void)setType:(TextFieldAndroidStyleType)type {
    
    _type = type;
    
    switch (type) {
        case kTextFieldAndroidStyleTypeNone:
            _pattern = nil;
            break;
        case kTextFieldAndroidStyleTypeAgency:
            _pattern = @"####";
            break;
        case kTextFieldAndroidStyleTypeAccount:
            _pattern = @"#####-#";
            break;
        case kTextFieldAndroidStyleTypePassword:
            _pattern = @"########";
            [self.textField setSecureTextEntry:YES];
            break;
        default:
            break;
    }
}

-(void)setPlaceholderString:(NSString *)placeholderString {
    
    _placeholderString = placeholderString;
    
    self.placeholderLabel.text = placeholderString;
    
    [self setPlaceholderDefaults];
}

-(void)setThemeColor:(UIColor *)themeColor {
    _themeColor =
    self.placeholderLabel.textColor =
    self.textField.textColor =
    self.textField.tintColor =
    self.baselineView.backgroundColor = themeColor;
}




#pragma mark - Handling animations

-(void)showPlaceholder {
    
    if (self.currentState != kTextFieldAndroidStyleStateEditing) {
        self.currentState = kTextFieldAndroidStyleStateEditing;
        
        self.placeholderTopLayoutConstraint.constant -= self.placeholderLabel.bounds.size.height;
        
        [UIView animateWithDuration:0.75
                              delay:0.0
             usingSpringWithDamping:0.85
              initialSpringVelocity:6.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self layoutIfNeeded];
                             self.placeholderLabel.alpha = 1.0;
                         }
                         completion:nil];
    }
}

-(void)reset {
    [self hidePlaceholder];
}

-(void)stampValues {
    self.textField.enabled = NO;

    if (self.currentState != kTextFieldAndroidStyleStateStamp) {
        self.currentState = kTextFieldAndroidStyleStateStamp;
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.textField.text attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:18.0]}];
        self.textField.attributedText = attributedString;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.baselineView.alpha = 0.0;
        }];
    }
}

-(void)hidePlaceholder {
    if (self.currentState != kTextFieldAndroidStyleStateReady) {

        self.placeholderTopLayoutConstraint.constant += self.placeholderLabel.bounds.size.height;

        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             [self layoutIfNeeded];
                             self.placeholderLabel.alpha = 0.0;
                         }
                         completion:nil];
        
        [self setStandards];
    }
}




#pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (!_pattern) return YES; // No pattern provided, allow anything
    
    NSString *changedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (range.length == 1 && // Only do for single deletes
       string.length < range.length &&
       [[textField.text substringWithRange:range] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
        // Something was deleted.  Delete past the previous number
        NSInteger location = changedString.length-1;
        if (location > 0) {
            for(; location > 0; location--)
            {
                if(isdigit([changedString characterAtIndex:location]))
                {
                    break;
                }
            }
            changedString = [changedString substringToIndex:location];
        }
    }
    
    textField.text = [self maskedString:changedString usingPattern:_pattern];
    
    return NO;
}




#pragma mark - Private methods

-(void)setPlaceholderDefaults {
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholderString attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:18.0], NSForegroundColorAttributeName: [self.themeColor colorByChangingAlphaTo:0.4]}];
}

-(void)setStandards {
    
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.enabled = YES;
    self.textField.delegate = self;
    self.placeholderTopLayoutConstraint.constant = 0;
    self.placeholderLabel.alpha = 0;
    self.baselineView.alpha = 1.0;
    
    if (self.placeholderString) {
        
        self.textField.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:18.0]}];
        [self setPlaceholderDefaults];
    }
    
    if (!self.themeColor) {
        self.themeColor = [UIColor whiteColor];
    }

    self.currentState = kTextFieldAndroidStyleStateReady;
    
    [[RACSignal merge:@[self.textField.rac_textSignal, RACObserve(self.textField, text)]] subscribeNext:^(NSString *text) {
                if (text.length > 0) {
                    [self showPlaceholder];
                } else {
                    [self hidePlaceholder];
                }
    }];
}

-(NSString *)maskedString:(NSString *)string usingPattern:(NSString *)pattern {
    
    NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
    char outputString[([pattern length])];
    BOOL done = NO;
    
    while (onFilter < [pattern length] && !done) {
        char filterChar = [pattern characterAtIndex:onFilter];
        char originalChar = onOriginal >= string.length ? '\0' : [string characterAtIndex:onOriginal];
        switch (filterChar) {
            case '#':
                if(originalChar=='\0') {
                    // We have no more input numbers for the filter.  We're done.
                    done = YES;
                    break;
                }
                if(isdigit(originalChar)) {
                    outputString[onOutput] = originalChar;
                    onOriginal++;
                    onFilter++;
                    onOutput++;
                }
                else {
                    onOriginal++;
                }
                break;
            default:
                // Any other character will automatically be inserted for the user as they type (spaces, - etc..) or deleted as they delete if there are more numbers to come.
                outputString[onOutput] = filterChar;
                onOutput++;
                onFilter++;
                if(originalChar == filterChar)
                    onOriginal++;
                break;
        }
    }
    outputString[onOutput] = '\0'; // Cap the output string
    return [NSString stringWithUTF8String:outputString];
}

@end
