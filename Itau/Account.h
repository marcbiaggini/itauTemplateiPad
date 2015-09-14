//
//  Account.h
//  Itau
//
//  Created by TIVIT_iOS on 16/06/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Profile;

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString * agency;
@property (nonatomic, retain) NSString * cpf;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * lastAccess;
@property (nonatomic, retain) Profile *profile;

@end
