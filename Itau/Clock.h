//
//  Clock.h
//  Itau
//
//  Created by A2works on 16/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Clock : NSObject

@property (strong,nonatomic) NSDateFormatter *dateFormatter;
-(void)setClock;
@end
