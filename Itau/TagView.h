//
//  TagView.h
//  Itau
//
//  Created by TIVIT_iOS on 21/07/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagView : UIView

@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

-(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;

@end
