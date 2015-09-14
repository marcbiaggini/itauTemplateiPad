//
//  LoginProfileItemCell.h
//  Itau
//
//  Created by a2works on 06/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@class ProfileItemCell;

@protocol LoginProfileItemCellDelegate <NSObject>

-(void)loginProfileItemCell:(ProfileItemCell *)itemCell didReceiveLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture;
-(void)loginProfileItemCellDidPressDeleteButton:(ProfileItemCell *)itemCell;
-(void)loginProfileItemCellDidPressAccessProfile:(ProfileItemCell *)itemCell;

@end

@interface ProfileItemCell : UITableViewCell

@property (strong, nonatomic) Profile *profile;

@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteProfileButton;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) id <LoginProfileItemCellDelegate> delegate;

-(IBAction)accessProfile:(UIButton *)sender;
-(IBAction)deleteProfile:(UIButton *)sender;
-(void)startWiggle;
-(void)stopWiggle;

@end
