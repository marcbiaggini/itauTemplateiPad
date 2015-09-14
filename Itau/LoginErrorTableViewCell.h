//
//  LoginHeaderView.h
//  Itau
//
//  Created by a2works on 18/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginErrorTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *errorIcon;
@property (weak, nonatomic) IBOutlet UITextView *textView;

-(instancetype)initWithMessage:(NSString *)message;

@end
