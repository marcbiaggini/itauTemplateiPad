//
//  Profile.h
//  Itau
//
//  Created by TIVIT_iOS on 16/06/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account;

@interface Profile : NSManagedObject

@property (nonatomic, retain) NSString * cpf;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSSet *accounts;

@end

@interface Profile (CoreDataGeneratedAccessors)

- (void)addAccountsObject:(Account *)value;
- (void)removeAccountsObject:(Account *)value;
- (void)addAccounts:(NSSet *)values;
- (void)removeAccounts:(NSSet *)values;

@end
