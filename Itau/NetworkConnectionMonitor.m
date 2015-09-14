//
//  NetworkConnectionMonitor.m
//  Itau
//
//  Created by A2works on 21/05/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "NetworkConnectionMonitor.h"

@implementation NetworkConnectionMonitor

-(void)getWifiStatusAsync:(StatusNetwork)statusNetwork
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    Reachability *internetReachableFoo;
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    if(status == NotReachable)
    {
        statusNetwork(NO);
        //No internet
//        return NO;
    }
    else if (status == ReachableViaWiFi)
    {
        
        //WiFi
        internetReachableFoo = [Reachability reachabilityWithHostName:@"https://www.itau.com.br"];
        
        if(![self hasInternetConnection:@"https://www.itau.com.br"])
        {
            //No internet
            statusNetwork(NO);
//            return NO;
            
        }
        
    }
    statusNetwork(YES);
//    return YES;
    
}
-(BOOL)getWifiStatus
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    Reachability *internetReachableFoo;
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    if(status == NotReachable)
    {
        //No internet
        return NO;
    }
    else if (status == ReachableViaWiFi)
    {
        
        //WiFi
        internetReachableFoo = [Reachability reachabilityWithHostName:@"https://www.itau.com.br"];
        
        if(![self hasInternetConnection:@"https://www.itau.com.br"])
        {
            //No internet
            return NO;
            
        }
        
    }
    return YES;

}
-(BOOL)getWanStatus
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    Reachability *internetReachableFoo;
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    if(status == NotReachable)
    {
        //No internet
        return NO;
    }
    else if (status == ReachableViaWWAN)
    {
        
        //WiFi
        internetReachableFoo = [Reachability reachabilityWithHostName:@"https://www.google.com.br"];
        
        if(![self hasInternetConnection:@"https://www.google.com.br"])
        {
            //No internet
            return NO;
            
        }
        
    }
    return YES;
    
}
-(BOOL)networkStatus
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    Reachability *internetReachableFoo;
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
        return NO;
    }
    else if (status == ReachableViaWiFi||(status == ReachableViaWWAN))
    {
        
        //WiFi
        internetReachableFoo = [Reachability reachabilityWithHostName:@"https://www.amazon.com"];
        
        if(![self hasInternetConnection:@"https://www.amazon.com"])
        {
            //No internet
            return NO;
            
        }
        
    }
    
    return YES;
    
}

//Verify Conectivity
-(BOOL)hasInternetConnection:(NSString*)urlAddress
{   bool success = false;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [urlAddress UTF8String]);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    bool isAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    
    if (isAvailable) {
        return YES;
    }else{
        return NO;
    }
}

-(int)getStatusCode:(NSURL*)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                            timeoutInterval:5.0];
    
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse *requestResponse;
    int statusCode = 0;
    self.last_modified = [[NSString alloc] init];
    
    while(statusCode==0)
    {[NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
        
        statusCode = [requestResponse statusCode];
        self.last_modified = [NSString stringWithFormat:@"%@",
                         [[requestResponse allHeaderFields] objectForKey:@"Last-Modified"]];
    }
    return statusCode;
}

-(NSString*)getLastModified:(NSURL*)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                            timeoutInterval:5.0];
    
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse *requestResponse;
    int statusCode = 0;
    self.last_modified = [[NSString alloc] init];
    
    while(statusCode==0)
    {[NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
        
        statusCode = [requestResponse statusCode];
        self.last_modified = [NSString stringWithFormat:@"%@",
                              [[requestResponse allHeaderFields] objectForKey:@"Last-Modified"]];
    }
    return self.last_modified;
}
@end
