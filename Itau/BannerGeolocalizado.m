//
//  BannerGeolocalizado.m
//  testGeocoder
//
//  Created by A2works on 01/05/15.
//  Copyright (c) 2015 A2works. All rights reserved.
//

#import "BannerGeolocalizado.h"

@implementation BannerGeolocalizado

-(BOOL) setVersioniOS
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    
   
    
    BOOL isAtLeast8 = [version floatValue] >= 8.0;
    return isAtLeast8;
    
    
    
}


//------------ Endereço de Local Atual-----
-(void)CurrentLocationIdentifier:(NSString*) call
{
    self.networkMonitor = [[NetworkConnectionMonitor alloc] init];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"bannerIsReady"]];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"DownloadComplete"]];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"askingBanner"]];
    
    self.bannerList = [[NSMutableArray alloc] init];
    self.callFunction = [[NSString alloc]initWithString:call];
    //---- Para trazer a localização atual do usuario via GPS
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if([self setVersioniOS])
    {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [self.locationManager requestWhenInUseAuthorization];
        
        
    }
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    //------
}

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}



#pragma mark - CLLocationManagerDelegate
//Traiz a Localização do Usuario
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations objectAtIndex:0];
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    
    
    if([self.networkMonitor networkStatus])
    {
        if ([self.callFunction isEqual:@"banner"])
        {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             // Verifica se o retorno dos locais não é null
             if (placemarks && placemarks.count > 0)
             {
                 
                                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%g", placemark.location.coordinate.latitude] forKey:@"myLatitude"];
                                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%g", placemark.location.coordinate.longitude] forKey:@"myLongitude"];
                 [self getBanner:placemark];
                 
                 [self.locationManager stopUpdatingLocation];
             }
             
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
             //return;
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
    }else
                {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%g", self.locationManager.location.coordinate.latitude] forKey:@"myLatitude"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%g", self.locationManager.location.coordinate.longitude] forKey:@"myLongitude"];
    }
    }else{
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%g", self.locationManager.location.coordinate.latitude] forKey:@"myLatitude"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%g", self.locationManager.location.coordinate.longitude] forKey:@"myLongitude"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"bannerIsReady"]];
        
    }
}

-(void)setURLBanner:(NSString*)type with:(CLPlacemark *)placemarks
{
    // {segmento}: substituir por "Institucional" ou "Personnalite"
    // {countryCode}: substituir pela sigla do Pais
    // {UF}: substituir pela sigla do estado
    // {skin}: substituir por it_ ou pt_
    // {arquivo}: substituir pelo nome do arquivo (ex: vert.png ou vert@2x.png // horiz)
    // Pega a URL do webservice no arquivo de configuracao para Validar se o ja foi cadastrado no Sistema.
    
    [self.bannerList removeAllObjects];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"bannerIsReady"]];
    NSString *segmento = [[NSString alloc] init];
    if([identifier isEqual:@"ipaditau"])
    {
        segmento = @"Institucional";
    }else
    {
        segmento =  @"Personnalite";
    }
    
    
    
    NSString *countryCode = placemarks.ISOcountryCode;
    NSString *uf = [placemarks.addressDictionary objectForKey:@"State"];
    NSString *city = [[NSString alloc]
                      initWithData:
                      [[placemarks.addressDictionary valueForKey:@"City"] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                      encoding:NSASCIIStringEncoding];
    //Remove Special Characters
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    city = [[city componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@"_"];
    
    NSString *subLocality = [placemarks.addressDictionary valueForKey:@"SubLocality"];
    NSString *fileVert = @"v.png";
    NSString *fileHoriz = @"h.png";
    
#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT
    
    
    SWITCH (type) {
        CASE (@"City") {
             NSString *urlBaseVert = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@", @"https://www.itau.com.br/_arquivosestaticos/Tablet/",segmento,@"/",@"Background/",countryCode,@"/",uf,@"/",city,@"/",fileVert];
            
             NSString *urlBaseHoriz = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@", @"https://www.itau.com.br/_arquivosestaticos/Tablet/",segmento,@"/",@"Background/",countryCode,@"/",uf,@"/",city,@"/",fileHoriz];
            
            NSURL *urlVert = [NSURL URLWithString:urlBaseVert];
            NSURL *urlHoriz = [NSURL URLWithString:urlBaseHoriz];
            [self.bannerList addObject:urlVert];
            [self.bannerList addObject:urlHoriz];
            NSData *bannerEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.bannerList ];
            [[NSUserDefaults standardUserDefaults] setObject:bannerEncodedObject forKey:[NSString stringWithFormat:@"%@%@",identifier,@"URLBanner"]];
            if(urlVert!=nil && urlHoriz!=nil )
            {
                [self.bannerList addObject:urlVert];
                [self.bannerList addObject:urlHoriz];
                NSData *bannerEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.bannerList ];
                [[NSUserDefaults standardUserDefaults] setObject:bannerEncodedObject forKey:[NSString stringWithFormat:@"%@%@",identifier,@"URLBanner"]];
            }
            break;
        }
        CASE (@"State") {
            
            NSString *urlBaseVert = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", @"https://www.itau.com.br/_arquivosestaticos/Tablet/",segmento,@"/",@"Background/",countryCode,@"/",uf,@"/",fileVert];
            
            NSString *urlBaseHoriz = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", @"https://www.itau.com.br/_arquivosestaticos/Tablet/",segmento,@"/",@"Background/",countryCode,@"/",uf,@"/",fileHoriz];
            
            NSURL *urlVert = [NSURL URLWithString:urlBaseVert];
            NSURL *urlHoriz = [NSURL URLWithString:urlBaseHoriz];
            if(urlVert!=nil && urlHoriz!=nil )
            {
                [self.bannerList addObject:urlVert];
                [self.bannerList addObject:urlHoriz];
                NSData *bannerEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.bannerList ];
                [[NSUserDefaults standardUserDefaults] setObject:bannerEncodedObject forKey:[NSString stringWithFormat:@"%@%@",identifier,@"URLBanner"]];
            }
            break;
        }
        CASE (@"Country") {
            NSString *urlBaseVert = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", @"https://www.itau.com.br/_arquivosestaticos/Tablet/",segmento,@"/",@"Background/",countryCode,@"/",fileVert];
            
            NSString *urlBaseHoriz = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", @"https://www.itau.com.br/_arquivosestaticos/Tablet/",segmento,@"/",@"Background/",countryCode,@"/",fileHoriz];
            NSURL *urlVert = [NSURL URLWithString:urlBaseVert];
            NSURL *urlHoriz = [NSURL URLWithString:urlBaseHoriz];
            if(urlVert!=nil && urlHoriz!=nil )
            {
                [self.bannerList addObject:urlVert];
                [self.bannerList addObject:urlHoriz];
                NSData *bannerEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.bannerList ];
                [[NSUserDefaults standardUserDefaults] setObject:bannerEncodedObject forKey:[NSString stringWithFormat:@"%@%@",identifier,@"URLBanner"]];
            }
            break;
        }
        DEFAULT {
            NSString *urlBaseVert = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", @"https://www.itau.com.br/_arquivosestaticos/Tablet/",segmento,@"/",@"Background/",countryCode,@"/",uf,@"/",city,@"/",subLocality,@"/",fileVert];
            
            NSString *urlBaseHoriz = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@", @"https://www.itau.com.br/_arquivosestaticos/Tablet/",segmento,@"/",@"Background/",countryCode,@"/",uf,@"/",city,@"/",subLocality,@"/",fileHoriz];
            
            NSURL *urlVert = [[NSURL alloc] initWithString:urlBaseVert];
            NSURL *urlHoriz = [[NSURL alloc] initWithString:urlBaseHoriz];
            if(urlVert!=nil && urlHoriz!=nil )
            {
            [self.bannerList addObject:urlVert];
            [self.bannerList addObject:urlHoriz];
            NSData *bannerEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.bannerList ];
                                  [[NSUserDefaults standardUserDefaults] setObject:bannerEncodedObject forKey:[NSString stringWithFormat:@"%@%@",identifier,@"URLBanner"]];  
            }
            
            break;
          
            
        }
    }
}
-(void)getBanner:(CLPlacemark *)placemarks
{
    
    [self setURLBanner:@"Neighborhood" with:placemarks];
    [self downloadBanner:placemarks];

    
}

-(void)downloadBanner:(CLPlacemark *)placemarks
{
    self.bannerListData = [[NSMutableArray alloc] init];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [[bundleIdentifier componentsSeparatedByString:@"."] lastObject];
    [self.networkMonitor getWifiStatusAsync:^(BOOL status) {
            if (status) {
                if([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",identifier,@"URLBanner"]]!=nil)
                {
                    self.bannerList = [ [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",identifier,@"URLBanner"]]]mutableCopy];
                    if([self.bannerList objectAtIndex:0]!=nil&&[self.bannerList objectAtIndex:1]!=nil)
                    {
                        
                        // download the image asynchronously
                        
                        [self downloadBannerWithURL:[self.bannerList objectAtIndex:0] with:[self.bannerList objectAtIndex:1]
                         
                         
                         
                         
                                    completionBlock:^(BOOL succeeded, NSMutableArray *bannerArray) {
                                        if (succeeded) {
                                           
                                            
                                            // cache the image for use later
                                            [[NSUserDefaults standardUserDefaults] setObject:self.bannerListData forKey:[NSString stringWithFormat:@"%@%@",identifier,@"Banner"]];
                                            
                                            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"DownloadComplete"]];
                                            
                                            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"askingBanner"]];
                                            
                                            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"bannerIsReady"]];
                                             NSLog(@"Novo banner Disponibilizado :) Bairro");
                                            
                                            
                                        }else{
                                            
                                            [self setURLBanner:@"City" with:placemarks];
                                            
                                            [self downloadBannerWithURL:[self.bannerList objectAtIndex:0] with:[self.bannerList objectAtIndex:1]
                                             
                                             
                                             
                                             
                                                        completionBlock:^(BOOL succeeded, NSMutableArray *bannerArray) {
                                                            if (succeeded) {
                                                                NSLog(@"Novo banner Disponibilizado :) Cidade");
                                                                
                                                                // cache the image for use later
                                                                [[NSUserDefaults standardUserDefaults] setObject:self.bannerListData forKey:[NSString stringWithFormat:@"%@%@",identifier,@"Banner"]];
                                                                
                                                                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"DownloadComplete"]];
                                                                
                                                                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"askingBanner"]];
                                                                
                                                                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"bannerIsReady"]];
                                                                
                                                                
                                                            }else{
                                                                
                                                                [self setURLBanner:@"State" with:placemarks];
                                                                
                                                                [self downloadBannerWithURL:[self.bannerList objectAtIndex:0] with:[self.bannerList objectAtIndex:1]
                                                                 
                                                                 
                                                                 
                                                                 
                                                                            completionBlock:^(BOOL succeeded, NSMutableArray *bannerArray) {
                                                                                if (succeeded) {
                                                                                    NSLog(@"Novo banner Disponibilizado :) Estado");
                                                                                    
                                                                                    // cache the image for use later
                                                                                    [[NSUserDefaults standardUserDefaults] setObject:self.bannerListData forKey:[NSString stringWithFormat:@"%@%@",identifier,@"Banner"]];
                                                                                    
                                                                                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"DownloadComplete"]];
                                                                                    
                                                                                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"askingBanner"]];
                                                                                    
                                                                                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"bannerIsReady"]];
                                                                                    
                                                                                    
                                                                                }else{
                                                                                    
                                                                                    [self setURLBanner:@"Country" with:placemarks];
                                                                                    
                                                                                    [self downloadBannerWithURL:[self.bannerList objectAtIndex:0] with:[self.bannerList objectAtIndex:1]
                                                                                     
                                                                                     
                                                                                     
                                                                                     
                                                                                                completionBlock:^(BOOL succeeded, NSMutableArray *bannerArray) {
                                                                                                    if (succeeded) {
                                                                                                        NSLog(@"Novo banner Disponibilizado :) Pais");
                                                                                                        
                                                                                                        // cache the image for use later
                                                                                                        [[NSUserDefaults standardUserDefaults] setObject:self.bannerListData forKey:[NSString stringWithFormat:@"%@%@",identifier,@"Banner"]];
                                                                                                        
                                                                                                        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"DownloadComplete"]];
                                                                                                        
                                                                                                        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"askingBanner"]];
                                                                                                        
                                                                                                        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"bannerIsReady"]];
                                                                                                        
                                                                                                        
                                                                                                    }
                                                                                                    
                                                                                                }];
                                                                                    
                                                                                }
                                                                                
                                                                            }];
                                                            }
                                                            
                                                        }];
                                            
                                        }
                                        
                                    }];
                        
                        
                    }
                }
            }else{
                
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"DownloadComplete"]];
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"bannerIsReady"]];
                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:[NSString stringWithFormat:@"%@%@",identifier,@"askingBanner"]];
            }
        }];
        
        
    
}

- (void)downloadBannerWithURL:(NSURL *)urlvert with:(NSURL *)urlhor completionBlock:(void (^)(BOOL succeeded, NSMutableArray *bannerArray))completionBlock
{
            NSMutableURLRequest *requestVert = [NSMutableURLRequest requestWithURL:urlvert];
        [NSURLConnection sendAsynchronousRequest:requestVert
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *responseVert, NSData *dataVert, NSError *error)
                                {
                                    NSHTTPURLResponse* httpResponseVert = (NSHTTPURLResponse*)responseVert;
                                   if ( !error && [httpResponseVert statusCode]!=404)
                                   {
                                       
                                       
                                       [self.bannerListData addObject:dataVert];

                                       
                                       NSMutableURLRequest *requestHor = [NSMutableURLRequest requestWithURL:urlhor];
                                       [NSURLConnection sendAsynchronousRequest:requestHor
                                                                          queue:[NSOperationQueue mainQueue]
                                                              completionHandler:^(NSURLResponse *responseHor, NSData *dataHor, NSError *error)
                                        {
                                            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)responseHor;
                                            
                                            if ( !error && [httpResponse statusCode]!=404)
                                            {
                                                
                                                [self.bannerListData addObject:dataHor];
                                                
                                                
                                                
                                                completionBlock(YES,self.bannerListData);
                                            } else{
                                                completionBlock(NO,nil);
                                            }
                                        }];

                                       
                                   } else{
                                       completionBlock(NO,nil);
                                   }
                               }];
    
   
    
    
    
}



@end
