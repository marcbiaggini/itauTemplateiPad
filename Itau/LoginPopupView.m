//
//  LoginAccessPopupView.m
//  Itau
//
//  Created by TIVIT_iOS on 12/06/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginPopupView.h"

@implementation LoginPopupView

-(void)dismiss {
    
    if (self.canDismiss) {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.hasErrorView = NO;
            [self removeFromSuperview];
        }];
    }
}

-(BOOL)isValidPassword:(NSString *)password {
    
    return password.length > 5;
}

- (void)shake {
    
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.07];
    [shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.center.x - 5,self.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:CGPointMake(self.center.x + 5, self.center.y)]];
    [self.layer addAnimation:shake forKey:@"position"];
}

-(void)showErrorMessage:(NSString *)message {
    
    if (!self.errorView) {
        
        self.errorView = [[LoginErrorTableViewCell alloc] initWithMessage:message];
        self.height += self.errorView.bounds.size.height;
        [self.loginViews insertObject:self.errorView atIndex:0];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.loginViews indexOfObject:self.errorView] inSection:0];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        self.hasErrorView = YES;
    }
}

-(void)dismissErrorMessage {
    
    if (self.errorView) {
        
        self.height -= self.errorView.bounds.size.height;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.loginViews indexOfObject:self.errorView] inSection:0];
        
        [self.loginViews removeObject:self.errorView];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        self.hasErrorView = NO;
        
        self.errorView = nil;
    }
}

#pragma mark - Setters

-(void)setHeight:(CGFloat)height {
    
    _height = height;
    _heightConstraint.constant = height;
    [UIView animateWithDuration:0.3 animations:^{
        [self.superview layoutIfNeeded];
    }];
}


@end
