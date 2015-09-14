//
//  LoginModel.h
//  Itau
//
//  Created by a2works on 09/06/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Profile.h"
#import "Account.h"

@interface LoginModel : NSObject

#pragma mark - Profiles

+(Profile *)profileWithName:(NSString *)name CPF:(NSString *)cpf photoData:(NSData *)data usingError:(NSError **)error;
+(BOOL)saveProfile:(Profile *)profile usingError:(NSError **)error;
+(BOOL)deleteProfile:(Profile *)profile usingError:(NSError **)error;
+(NSArray *)allProfilesUsingError:(NSError **)error;

#pragma mark - Accounts

+(Account *)accountWithNumber:(NSString *)number agencyNumber:(NSString *)agency CPF:(NSString *)cpf;
+(BOOL)saveAccount:(Account *)account usingError:(NSError **)error;
+(BOOL)insertAccount:(Account *)account intoProfile:(Profile *)profile;
+(BOOL)deleteAccount:(Account *)account usingError:(NSError **)error;
+(NSArray *)accountsFromProfile:(Profile *)profile;

@end
