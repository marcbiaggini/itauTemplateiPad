//
//  NumericKeyboard.h
//  Itau
//
//  Created by a2works on 11/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NumericKeyboard;

@protocol NumericKeyboardDelegate <NSObject>

@optional
-(void)numericKeyboardNextKeyPressed:(NumericKeyboard *)keyboard;
-(void)numericKeyboardPrevKeyPressed:(NumericKeyboard *)keyboard;
-(void)numericKeyboardHideKeyPressed:(NumericKeyboard *)keyboard;
-(void)numericKeyboard:(NumericKeyboard *)keyboard doneKeyPressedWithResponder:(UIResponder<UITextInput> *)responder;
-(void)numericKeyboard:(NumericKeyboard *)keyboard numberKeyPressedWithNumber:(NSNumber *)number;

@end

@interface NumericKeyboard : UIView <UIInputViewAudioFeedback>

@property (weak, nonatomic) id <NumericKeyboardDelegate> delegate;

+(NumericKeyboard *)defaultNumericKeyboard;
-(void)setTargets:(NSArray *)targets success:(void (^)(BOOL success))success;

@end
