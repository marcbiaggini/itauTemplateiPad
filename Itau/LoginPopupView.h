//
//  LoginAccessPopupView.h
//  Itau
//
//  Created by TIVIT_iOS on 12/06/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <SDKiOSCore/SDKiOSCore.h>
#import <libextobjc/extobjc.h>
#import "LoginModel.h"
#import "LoginFooterView.h"
#import "LoginErrorTableViewCell.h"
#import "LoginKeyboardTableViewCell.h"
#import "UIColor+Itau.h"
#import "Reachability.h"

@interface LoginPopupView : UIView {
    
    @protected NSLayoutConstraint *_heightConstraint;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) LoginErrorTableViewCell *errorView;
@property (strong, nonatomic) LoginFooterView *footerView;
@property (strong, nonatomic) LoginKeyboardTableViewCell *keyboardViewCell;
@property (assign, nonatomic) BOOL hasErrorView;
@property (assign, nonatomic) CGFloat height;
@property (strong, nonatomic) NSMutableArray *loginViews;
@property (assign, nonatomic) BOOL canDismiss;

-(void)dismiss;
-(void)shake;
-(BOOL)isValidPassword:(NSString *)password;
-(void)showErrorMessage:(NSString *)message;
-(void)dismissErrorMessage;

@end
