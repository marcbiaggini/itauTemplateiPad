//
//  NumericKeyboard.m
//  Itau
//
//  Created by a2works on 11/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "NumericKeyboard.h"
#import "UIImage+Itau.h"

@interface NumericKeyboard ()

@property (nonatomic, weak) IBOutlet UIButton *prevButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

@property (nonatomic, weak) IBOutlet UIView *numberKeysWrapper;
@property (nonatomic, weak) IBOutlet UIView *functionKeysWrapper;

@property (nonatomic, weak) UIResponder <UITextInput> *activeTarget;
@property (nonatomic, assign) NSInteger activeTargetIndex;
@property (nonatomic, strong) NSMutableArray *targets;

@end

@implementation NumericKeyboard

-(instancetype)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];

        self.targets = [[NSMutableArray alloc] init];
        
        [self addObservers];
        [self prepareUI];
    }
    
    return self;
}

-(void)prepareUI {

    self.nextButton.enabled = NO;
    self.prevButton.enabled = NO;
    
    [self.nextButton setImage:[UIImage targetedImageNamed:@"bt_seta_direita"] forState:UIControlStateNormal];
    
    self.nextButton.accessibilityLabel = @"Ir para o próximo campo";
    [self.prevButton setImage:[UIImage targetedImageNamed:@"bt_seta_esquerda"] forState:UIControlStateNormal];
    self.prevButton.accessibilityLabel = @"Voltar para o campo anterior";
    [self.deleteButton setImage:[UIImage targetedImageNamed:@"ico_backspace"] forState:UIControlStateNormal];
    self.deleteButton.accessibilityLabel = @"Deletar";
    
    for (id object in self.numberKeysWrapper.subviews) {
        
        if ([object isKindOfClass:[UIButton class]]) {
            
            UIButton *button = object;
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        }
    }
    
    for (id object in self.functionKeysWrapper.subviews) {
        
        if ([object isKindOfClass:[UIButton class]]) {
            
            UIButton *button = object;
            [button setBackgroundImage:[UIImage imageWithColor:[UIColor darkGrayColor]] forState:UIControlStateHighlighted];
        }
    }
}

+(NumericKeyboard *)defaultNumericKeyboard {
    
    NumericKeyboard *nk = [[NumericKeyboard alloc] init];
    return nk;
}


-(void)setTargets:(NSArray *)targets success:(void (^)(BOOL))success {

    BOOL flag = YES;
    
    if (!self.targets) {
        self.targets = [[NSMutableArray alloc] init];
    }
    
    for (id object in targets) {
        if ([object isKindOfClass:[UIResponder class]]) {
            if ([object conformsToProtocol:@protocol(UITextInput)]) {
                if ([object isKindOfClass:[UITextField class]]) {
                    ((UITextField *)object).inputView = self;
                    [self.targets addObject:(UITextField *)object];
                } else if ([object isKindOfClass:[UITextView class]]) {
                    ((UITextView *)object).inputView = self;
                    [self.targets addObject:(UITextView *)object];
                } else {
                    flag = NO;
                    continue;
                }
                
            } else {
                flag = NO;
                continue;
            }
        } else {
            flag = NO;
            continue;
        }
    }
    
    [self updateNextPrevButtonsState];
    
    if (success) {
        success(flag);
    }
}


- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidBegin:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidBegin:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
}

-(void)setActiveTargetIndex:(NSInteger)activeTargetIndex {
    
    _activeTargetIndex = activeTargetIndex;
    [self updateNextPrevButtonsState];
}

-(void)updateNextPrevButtonsState {
    
    if (self.targets && self.targets.count > 0) {
        self.nextButton.enabled = self.activeTargetIndex < self.targets.count -1;
        self.prevButton.enabled = self.activeTargetIndex > 0;
    } else {
        self.nextButton.enabled = NO;
        self.prevButton.enabled = NO;
    }
}

#pragma mark - Handling editing

-(void)editingDidBegin:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[UIResponder class]]) {
        if ([notification.object conformsToProtocol:@protocol(UITextInput)]) {
            self.activeTarget = notification.object;
            self.activeTargetIndex = [self.targets indexOfObject:self.activeTarget];
            return;
        }
    }
    
    self.activeTarget = nil;
}

-(void)editingDidEnd:(NSNotification *)notification {
    
    self.activeTarget = nil;
}

#pragma mark - Text replacement routines

// Check delegate methods to see if we should change the characters in range
- (BOOL)textInput:(id <UITextInput>)textInput shouldChangeCharactersInRange:(NSRange)range withString:(NSString *)string {
    if (textInput) {
        if ([textInput isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)textInput;
            if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                if ([textField.delegate textField:textField
                    shouldChangeCharactersInRange:range
                                replacementString:string]) {
                    return YES;
                }
            } else {
                // Delegate does not respond, so default to YES
                return YES;
            }
        } else if ([textInput isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)textInput;
            if ([textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                if ([textView.delegate textView:textView
                        shouldChangeTextInRange:range
                                replacementText:string]) {
                    return YES;
                }
            } else {
                // Delegate does not respond, so default to YES
                return YES;
            }
        }
    }
    return NO;
}

// Replace the text of the textInput in textRange with string if the delegate approves
- (void)textInput:(id <UITextInput>)textInput replaceTextAtTextRange:(UITextRange *)textRange withString:(NSString *)string {
    if (textInput) {
        if (textRange) {
            // Calculate the NSRange for the textInput text in the UITextRange textRange:
            NSInteger startPos                    = [textInput offsetFromPosition:textInput.beginningOfDocument
                                                                 toPosition:textRange.start];
            NSInteger length                      = [textInput offsetFromPosition:textRange.start
                                                                 toPosition:textRange.end];
            NSRange selectedRange                 = NSMakeRange(startPos, length);
            
            if ([self textInput:textInput shouldChangeCharactersInRange:selectedRange withString:string]) {
                // Make the replacement:
                [textInput replaceRange:textRange withText:string];
            }
        }
    }
}


#pragma mark - IBActions

- (IBAction)numberPressed:(UIButton *)sender {
    
    if (self.activeTarget) {
        
        [[UIDevice currentDevice] playInputClick];
        
        NSString *numberPressed = sender.titleLabel.text;
        if (numberPressed.length > 0) {
            UITextRange *selectedTextRange = self.activeTarget.selectedTextRange;
            if (selectedTextRange) {
                [self textInput:self.activeTarget replaceTextAtTextRange:selectedTextRange withString:numberPressed];
            }
        }
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(numericKeyboard:numberKeyPressedWithNumber:)]) {
                [self.delegate numericKeyboard:self numberKeyPressedWithNumber:@([sender.titleLabel.text integerValue])];
            }
        }
    }
}

- (IBAction)nextTargetButtonPressed:(UIButton *)sender {
    
    if (self.activeTargetIndex < self.targets.count -1) {
        
        [[UIDevice currentDevice] playInputClick];

        NSInteger nextIndex = self.activeTargetIndex +1;
        id object = self.targets[nextIndex];

        if ([object isKindOfClass:[UIResponder class]]) {
            UIResponder *target = object;
            
            if ([target conformsToProtocol:@protocol(UITextInput)]) {
                self.activeTargetIndex = nextIndex;
                [target becomeFirstResponder];
            }
        }
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(numericKeyboardNextKeyPressed:)]) {
                [self.delegate numericKeyboardNextKeyPressed:self];
            }
        }
    }
}

- (IBAction)prevTargetButtonPressed:(UIButton *)sender {

    if (self.activeTargetIndex > 0) {
        
        [[UIDevice currentDevice] playInputClick];

        NSInteger prevIndex = self.activeTargetIndex -1;
        id object = self.targets[prevIndex];
        
        if ([object isKindOfClass:[UIResponder class]]) {
            UIResponder *target = object;
            
            if ([target conformsToProtocol:@protocol(UITextInput)]) {
                self.activeTargetIndex = prevIndex;
                [target becomeFirstResponder];
            }
        }
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(numericKeyboardPrevKeyPressed:)]) {
                [self.delegate numericKeyboardPrevKeyPressed:self];
            }
        }
    }
}

- (IBAction)deletePressed:(UIButton *)sender {
    
    if (self.activeTarget) {

        [[UIDevice currentDevice] playInputClick];

        UITextRange *selectedTextRange = self.activeTarget.selectedTextRange;
        if (selectedTextRange) {
            UITextPosition *startPosition = [self.activeTarget positionFromPosition:selectedTextRange.start offset:-1];
            if (!startPosition) {
                return;
            }
            UITextPosition *endPosition = selectedTextRange.end;
            if (!endPosition) {
                return;
            }
            UITextRange *rangeToDelete = [self.activeTarget textRangeFromPosition:startPosition toPosition:endPosition];
            [self textInput:self.activeTarget replaceTextAtTextRange:rangeToDelete withString:@""];
        }
    }
}

- (IBAction)donePressed:(UIButton *)sender {
    
    [[UIDevice currentDevice] playInputClick];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(numericKeyboard:doneKeyPressedWithResponder:)]) {
            [self.delegate numericKeyboard:self doneKeyPressedWithResponder:self.activeTarget];
        }
    }
}

- (IBAction)hidePressed:(UIButton *)sender {

    [[UIDevice currentDevice] playInputClick];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(numericKeyboardHideKeyPressed:)]) {
            [self.delegate numericKeyboardHideKeyPressed:self];
        }
    }
    [self.activeTarget resignFirstResponder];
}

#pragma mark - UIInputViewAudioFeedback

-(BOOL)enableInputClicksWhenVisible {
    
    return YES;
}

@end
