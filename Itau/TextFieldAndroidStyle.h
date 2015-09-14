//
//  TextFieldAndroidStyle.h
//  Itau
//
//  Created by a2works on 13/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const TextFieldAndroidStyleEndOfEditingWithMaskNotification;

typedef enum TextFieldAndroidStyleTypes {
    
    kTextFieldAndroidStyleTypeAgency,
    kTextFieldAndroidStyleTypeAccount,
    kTextFieldAndroidStyleTypePassword,
    kTextFieldAndroidStyleTypeNone
    
} TextFieldAndroidStyleType;


@interface TextFieldAndroidStyle : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) NSString *placeholderString;

+(instancetype)textFieldAndroidStyleWithThemeColor:(UIColor *)color
                                              type:(TextFieldAndroidStyleType)type;
-(void)stampValues;
-(void)reset;

@end
