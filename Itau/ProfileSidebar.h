//
//  LoginSidebar.h
//  Itau
//
//  Created by a2works on 05/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddProfileView.h"
#import "GaussianBlurFilter.h"
#import "LoginNewAccessPopupView.h"
#import "LoginAccessProfilePopupView.h"


@interface ProfileSidebar : UIView <LoginAddProfileViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UITableView *profilesTableView;
@property (weak, nonatomic) IBOutlet AddProfileView *addButton;

-(void)stopWiggleAllProfileItemCells;

@end
