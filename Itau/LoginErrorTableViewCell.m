//
//  LoginHeaderView.m
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginErrorTableViewCell.h"

@interface LoginErrorTableViewCell()

@property (weak, nonatomic) NSString *message;

@end

@implementation LoginErrorTableViewCell


-(instancetype)init {
    
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

-(void)layoutSubviews {
    
}

-(instancetype)initWithMessage:(NSString *)message {
    
    self = [self init];
    if (self) {
        self.message = message;
    }
    
    return self;
}

-(void)setMessage:(NSString *)message {
    
    _message = message;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Arial" size:14.0], NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.textView.attributedText = attrText;
    
    CGSize sizeThatShouldFitTheContent = [self.textView sizeThatFits:self.textView.frame.size];
    
    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, sizeThatShouldFitTheContent.height + 14.0);
}

@end
