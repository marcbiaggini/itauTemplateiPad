//
//  LoginAddProfileView.h
//  Itau
//
//  Created by a2works on 06/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddProfileView;

@protocol LoginAddProfileViewDelegate <NSObject>

-(void)addProfileViewDidTouch:(AddProfileView *)addProfileView;

@end

@interface AddProfileView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) id<LoginAddProfileViewDelegate> delegate;

-(IBAction)accessAccount:(UIButton *)sender;

@end
