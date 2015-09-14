//
//  Clock.m
//  Itau
//
//  Created by A2works on 16/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "Clock.h"

@implementation Clock

-(void)setClock
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle: NSDateFormatterShortStyle];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(targetMethod:)
                                   userInfo:nil
                                    repeats:YES];
}

-(void)targetMethod:(id)sender
{
    NSString *currentTime = [self.dateFormatter stringFromDate: [NSDate date]];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    [[NSUserDefaults standardUserDefaults] setObject:currentTime forKey:[NSString stringWithFormat:@"%@%@",identifier,@"setTime"]];
    
}
@end
