//
//  LoginModel.m
//  Itau
//
//  Created by a2works on 09/06/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginModel.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@implementation LoginModel

+(NSManagedObjectContext *)context {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    return context;
}




#pragma mark - Profiles

+(Profile *)profileWithName:(NSString *)name CPF:(NSString *)cpf photoData:(NSData *)data usingError:(NSError *__autoreleasing *)error {
    
    NSManagedObjectContext *context = [self context];
    
    NSString *entityName = @"Profile";
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cpf LIKE %@", cpf];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSArray *profiles = [context executeFetchRequest:fetchRequest error:error];
    
    if (profiles.count > 0) {
        for (Profile *profile in profiles) {
            if ([profile.cpf isEqualToString:cpf]) {
                return profile;
            }
        }
    }
    
    Profile *aProfile = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                  inManagedObjectContext:context];
    aProfile.name = name;
    aProfile.cpf = cpf;
    aProfile.photo = data;
    aProfile.createdAt = [NSDate date];
    
    return aProfile;
}

+(BOOL)saveProfile:(Profile *)profile usingError:(NSError *__autoreleasing *)error {
    
    NSManagedObjectContext *context = [profile managedObjectContext];
    
    return [context save:error];
}

+(BOOL)deleteProfile:(Profile *)profile usingError:(NSError *__autoreleasing *)error {

    NSManagedObjectContext *context = [profile managedObjectContext];
    
    NSMutableArray *accounts = [[LoginModel accountsFromProfile:profile] mutableCopy];

    for (Account *account in accounts) {
        [self deleteAccount:account usingError:error];
    }
    
    [context deleteObject:profile];
    
    return [context save:error];
}

+(NSArray *)allProfilesUsingError:(NSError *__autoreleasing *)error {
    
    NSManagedObjectContext *context = [self context];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Profile"];
    
    return [context executeFetchRequest:fetchRequest error:error];
}




#pragma mark - Accounts

+(NSArray *)accountsFromProfile:(Profile *)profile {
    
    if (profile.accounts.count > 0) {
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"lastAccess" ascending:YES comparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
            
            return [obj2 compare:obj1];
        }];
        
        NSArray *sortedArray = [profile.accounts sortedArrayUsingDescriptors:@[desc]];
        
        return sortedArray;
        
    } else {
        
        return [profile.accounts allObjects];
    }
}

+(BOOL)deleteAccount:(Account *)account usingError:(NSError *__autoreleasing *)error {
    
    NSManagedObjectContext *context = [account managedObjectContext];
    [context deleteObject:account];
    
    return [context save:error];
}

+(Account *)accountWithNumber:(NSString *)number agencyNumber:(NSString *)agency CPF:(NSString *)cpf {

    NSManagedObjectContext *context = [self context];
    
    Account *anAccount = [NSEntityDescription insertNewObjectForEntityForName:@"Account"
                                                                  inManagedObjectContext:context];
    
    anAccount.number = number;
    anAccount.agency = agency;
    anAccount.cpf = cpf;
    anAccount.profile = nil;
    anAccount.createdAt =
    anAccount.lastAccess = [NSDate date];
    
    return anAccount;
}

+(BOOL)saveAccount:(Account *)account usingError:(NSError *__autoreleasing *)error {
    
    NSManagedObjectContext *context = [account managedObjectContext];
    
    return [context save:error];
}

+(BOOL)insertAccount:(Account *)account intoProfile:(Profile *)profile {
    
    if (account.cpf != profile.cpf) {
        return NO;
    }
    
    NSSet *accounts = profile.accounts;
    
    for (Account *anAccount in accounts) {
        if ([anAccount.number isEqualToString:account.number] && [anAccount.agency isEqualToString:account.agency]) {

            anAccount.lastAccess = [NSDate date];
            
            NSError *error = nil;
            [self saveAccount:anAccount usingError:&error];
            
            return NO;
        }
    }
    
    [profile addAccountsObject:account];

    return YES;
}

@end
