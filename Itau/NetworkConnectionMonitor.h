//
//  NetworkConnectionMonitor.h
//  Itau
//
//  Created by A2works on 21/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"


@interface NetworkConnectionMonitor : NSObject

typedef void(^StatusNetwork)(BOOL status);

@property(nonatomic,strong) NSString * last_modified;
-(BOOL)networkStatus;
-(void)getWifiStatusAsync:(StatusNetwork)statusNetwork;

-(BOOL)hasInternetConnection:(NSString*)urlAddress;

-(int)getStatusCode:(NSURL*)url;
-(NSString*)getLastModified:(NSURL*)url;
-(BOOL)getWifiStatus;
-(BOOL)getWanStatus;




@end
