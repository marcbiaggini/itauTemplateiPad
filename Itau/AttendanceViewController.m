//
//  MapasTelefonesViewController.m
//  testGeocoder
//
//  Created by A2works on 05/05/15.
//  Copyright (c) 2015 A2works. All rights reserved.
//

#import "AttendanceViewController.h"
#import "UIImage+Itau.h"

@interface AttendanceViewController ()

@property (assign, nonatomic) BOOL isToggled;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accordeonTopConstraint;

@end

@implementation AttendanceViewController

@synthesize popoverController;

static NSString* const GMAP_ANNOTATION_SELECTED = @"gMapAnnontationSelected";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationBar.tintColor = [UIColor targetPrimaryColor];
    
    UIImage *backButtonImage = [UIImage targetedImageNamed:@"maps_back"];
    
    [self.backBarButton setImage:backButtonImage];
    
    self.isToggled = NO;
    
    
    [self setupMapasView];
    self.mapItau.delegate = self;
    self.mapItau.showsUserLocation = YES;
    self.orientationDefault = [[UIApplication sharedApplication] statusBarOrientation];
    self.agencyIcon = [[NSMutableArray alloc] init];
    self.banner = [[BannerGeolocalizado alloc] init];
    self.networkMonitor = [[NetworkConnectionMonitor alloc] init];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if([AFNetworkReachabilityManager sharedManager].reachable){
        NSString *lat =[[NSUserDefaults standardUserDefaults] objectForKey:@"myLatitude"];
        NSString *lon = [[NSUserDefaults standardUserDefaults] objectForKey:@"myLongitude"];
        if(lat!=nil && lon!=nil){
            
            [self setMap:[[NSUserDefaults standardUserDefaults] objectForKey:@"myLatitude"] withLongitude:[[NSUserDefaults standardUserDefaults] objectForKey:@"myLongitude"]];
        }else
        {
            [self.banner CurrentLocationIdentifier:@"mapas"];
        }
        
        
    }else
    {
        // Exibe mensagem de erro
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenção"
                                                        message:@"Por favor, verifique sua conexão de rede e tente novamente"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        // Exibe o alerta
        [alert show];
    }
    
    self.mapItau.isAccessibilityElement = YES;
    self.mapItau.accessibilityLabel = @"Mapa de agências perto de você";
    
    self.accordeonView.isAccessibilityElement = YES;
    self.accordeonView.accessibilityViewIsModal = YES;
    self.accordeonView.accessibilityLabel = @"Janela de telefones Itaú";
    
}

#pragma mark - IBActions

-(IBAction)toggleAccordeonView:(UIButton *)sender {
    
    self.isToggled = !self.isToggled;
}

-(IBAction)back:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setters

-(void)setIsToggled:(BOOL)isToggled {
    
    self.accordeonTopConstraint.constant = isToggled ? -50 : self.accordeonView.bounds.size.height * -1;
    
    self.btnArrow.accessibilityLabel = isToggled
    ? @"Expandir a janela de telefones"
    : @"Minimizar janela de telefones";
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.btnArrow.transform = isToggled
        ? CGAffineTransformMakeRotation(0 * M_PI/180)
        : CGAffineTransformMakeRotation(180 * M_PI/180);
        
        [self.view layoutIfNeeded];
    }];
    
    
    _isToggled = isToggled;
}









-(void)setupMapasView
{
    
    self.itauNoTelefone.textColor = [UIColor targetPrimaryColor];
    self.SACItau.textColor = [UIColor targetPrimaryColor];
    self.Ouviduria.textColor = [UIColor targetPrimaryColor];
    [self.btnArrow setImage:[UIImage targetedImageNamed:@"bt_seta_baixo"] forState:UIControlStateNormal];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    NSArray *selectedAnnotations = self.mapItau.selectedAnnotations;
    for(id annotation in selectedAnnotations) {
        [self.mapItau deselectAnnotation:annotation animated:YES];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    
    
    if(self.mapItau.selectedAnnotations.count>0)
    {
        if ([self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:NO];
            
            MKPointAnnotation *annotationAgencia = (MKPointAnnotation*)[self.mapItau.selectedAnnotations objectAtIndex:0];
            
            CGPoint p = [self.mapItau convertCoordinate:annotationAgencia.coordinate toPointToView:self.mapItau];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.popoverController presentPopoverFromRect:CGRectMake(p.x, p.y, 1, 1)
                                                        inView:self.mapItau
                                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                                      animated:YES];
            });
        }
        
        
        
    }
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)getAgencias {
    
    NSString * ws=[NSString stringWithFormat:@"%@",@"http://itau.mobi/ServicoRedeAtendimentoWeb/rede_atendimento?"];
    
    NSString *postDataFormat =[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",@"xml=<busca><passo>LISTAR_AGENCIAS_PROXIMIDADE</passo>",@"<segmento>ITAU</segmento>",@"<tipo>AGENCIA</tipo>",@"<latitude>",[[NSUserDefaults standardUserDefaults] objectForKey:@"myLatitude"],@"</latitude>",@"<longitude>",[[NSUserDefaults standardUserDefaults] objectForKey:@"myLongitude"],@"</longitude>",@"</busca>"];
    
    //Formata os Dados
    NSData *postData = [postDataFormat dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    //Transforma os Dados de String para Bytes
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:ws]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    
    NSError *requestError = nil;
    NSURLResponse *response = NULL;
    
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request        returningResponse:&response error:&requestError];;
    
    NSString *responseString  = [[NSString alloc] initWithData:requestHandler encoding:NSUTF8StringEncoding];
    
    NSDictionary *xmlDict = [XMLReader dictionaryForXMLString:responseString error:NULL];
    
    NSArray *agencias = [xmlDict objectForKey:@"resultado"];
    
    if (agencias.count > 0) {
        [self drawAnotationsPoints:xmlDict];
    }
    
}

-(void)drawAnotationsPoints:(NSDictionary *)xmlDict
{   [self.agencyIcon removeAllObjects];
    NSDictionary *resultado =[xmlDict objectForKey:@"resultado"];
    NSDictionary *agencias = [resultado objectForKey:@"agencias"];
    NSDictionary *agencia = [agencias objectForKey:@"agencia"];
    CLLocation *agencyLocation;
    if([agencia isKindOfClass:[NSArray class]]){
        
        NSMutableArray *values = [[NSMutableArray alloc] init];
        values = [agencia copy];
        
        for(int i =0; i<values.count-1; i++)
        {
            NSDictionary *agency = [values objectAtIndex:i];
            NSDictionary *latitude = [agency objectForKey:@"latitude"];
            NSDictionary *longitude = [agency objectForKey:@"longitude"];
            
            agencyLocation = [[CLLocation alloc] initWithLatitude:[[latitude objectForKey:@"text"] doubleValue] longitude:[[longitude objectForKey:@"text"] doubleValue]];
            MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
            annotationPoint.coordinate = agencyLocation.coordinate;
            NSDictionary *agenciaId =[agency objectForKey:@"id"];
            NSDictionary *endereco =[agency objectForKey:@"endereco"];
            NSDictionary *bairro =[agency objectForKey:@"bairro"];
            NSDictionary *cep =[agency objectForKey:@"cep"];
            NSDictionary *cidade =[agency objectForKey:@"cidade"];
            NSDictionary *uf =[agency objectForKey:@"uf"];
            NSDictionary *segmento  = [agency objectForKey:@"segmento"];
            [self.agencyIcon addObject:[segmento objectForKey:@"text"]];
            NSDictionary *telefone = [agency objectForKey:@"tel"];
            
            NSDictionary *horabe = [agency objectForKey:@"horabe"];
            NSDictionary *horafec = [agency objectForKey:@"horafec"];
            
            NSString *address = [NSString stringWithFormat:@"%@%@%@%@%@%@\r\r%@%@%@", [endereco objectForKey:@"text"],@" ",[bairro objectForKey:@"text"],@" CEP: ",[cep objectForKey:@"text"],@" ",[cidade objectForKey:@"text"],@", ",[uf objectForKey:@"text"]];
            
            NSString *FontName = [[UIFont systemFontOfSize:12] fontName];
            
            NSString *ArialBold = [[UIFont boldSystemFontOfSize:12] fontName];
            NSMutableAttributedString *adds= [[NSMutableAttributedString alloc] initWithString:address attributes:@{NSFontAttributeName: FontName}];
            
            
            NSMutableAttributedString *horario= [[NSMutableAttributedString alloc] initWithString:@"Horario de Atendimento: " attributes:@{NSFontAttributeName: ArialBold}];
            
            NSMutableString *horA = [NSMutableString stringWithString:[horabe objectForKey:@"text"]];
            [horA insertString:@":" atIndex:2];
            NSMutableString *horF = [NSMutableString stringWithString:[horafec objectForKey:@"text"]];
            [horF insertString:@":" atIndex:2];
            
            annotationPoint.title = [NSString stringWithFormat:@"%@%@", @"Agência ",[agenciaId objectForKey:@"text"]];
            annotationPoint.subtitle = [NSString stringWithFormat:@"%@\r\r%@\r%@%@%@%@", [adds string], [horario string],@"segunda a sexta das ", horA, @" às ",horF];
            
            
            [self.mapItau addAnnotation:annotationPoint];
            
        }
    } else if (agencia != nil) {
        
        NSDictionary *agency = agencia;
        NSDictionary *latitude = [agency objectForKey:@"latitude"];
        NSDictionary *longitude = [agency objectForKey:@"longitude"];
        
        agencyLocation = [[CLLocation alloc] initWithLatitude:[[latitude objectForKey:@"text"] doubleValue] longitude:[[longitude objectForKey:@"text"] doubleValue]];
        MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
        annotationPoint.coordinate = agencyLocation.coordinate;
        NSDictionary *agenciaId =[agency objectForKey:@"id"];
        NSDictionary *endereco =[agency objectForKey:@"endereco"];
        NSDictionary *bairro =[agency objectForKey:@"bairro"];
        NSDictionary *cep =[agency objectForKey:@"cep"];
        NSDictionary *cidade =[agency objectForKey:@"cidade"];
        NSDictionary *uf =[agency objectForKey:@"uf"];
        NSDictionary *segmento  = [agency objectForKey:@"segmento"];
        [self.agencyIcon addObject:[segmento objectForKey:@"text"]];
        
        //NSDictionary *telefone = [agency objectForKey:@"tel"];
        
        NSDictionary *horabe = [agency objectForKey:@"horabe"];
        NSDictionary *horafec = [agency objectForKey:@"horafec"];
        
        NSString *address = [NSString stringWithFormat:@"%@%@%@%@%@%@\r\r%@%@%@", [endereco objectForKey:@"text"],@" ",[bairro objectForKey:@"text"],@" CEP: ",[cep objectForKey:@"text"],@" ",[cidade objectForKey:@"text"],@", ",[uf objectForKey:@"text"]];
        
        NSString *FontName = [[UIFont systemFontOfSize:12] fontName];
        
        NSString *ArialBold = [[UIFont boldSystemFontOfSize:12] fontName];
        NSMutableAttributedString *adds= [[NSMutableAttributedString alloc] initWithString:address attributes:@{NSFontAttributeName: FontName}];
        
        
        NSMutableAttributedString *horario= [[NSMutableAttributedString alloc] initWithString:@"Horario de Atendimento: " attributes:@{NSFontAttributeName: ArialBold}];
        
        NSMutableString *horA = [NSMutableString stringWithString:[horabe objectForKey:@"text"]];
        [horA insertString:@":" atIndex:2];
        NSMutableString *horF = [NSMutableString stringWithString:[horafec objectForKey:@"text"]];
        [horF insertString:@":" atIndex:2];
        
        annotationPoint.title = [NSString stringWithFormat:@"%@%@", @"Agência ",[agenciaId objectForKey:@"text"]];
        annotationPoint.subtitle = [NSString stringWithFormat:@"%@\r\r%@\r%@%@%@%@", [adds string], [horario string],@"segunda a sexta das ", horA, @" às ",horF];
        
        [self.mapItau addAnnotation:annotationPoint];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self removeNotificationApp];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Agencia"];
        /**/
        
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Agencia"];
            //pinView.animatesDrop = YES;
            pinView.canShowCallout = NO;
            
            int annotationIndex = [mapView.annotations indexOfObject:pinView.annotation];
            
            if(annotationIndex > 0)
            {
                if([[self.agencyIcon objectAtIndex:annotationIndex-1] isEqualToString:@"UBB"])
                {
                    pinView.image = [UIImage imageNamed:@"ipaditau-logo_mapa"];
                    
                }else
                {
                    pinView.image = [UIImage imageNamed:@"ipad-logo_mapa"];
                }
            }else
            {
                if([[self.agencyIcon objectAtIndex:0] isEqualToString:@"UBB"])
                {
                    pinView.image = [UIImage imageNamed:@"ipaditau-logo_mapa"];
                    
                }else
                {
                    pinView.image = [UIImage imageNamed:@"ipad-logo_mapa"];
                }
            }
            
            
            pinView.calloutOffset = CGPointMake(0, 10);
            
            
        } else {
            pinView.annotation = annotation;
        }
        
        
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *myCustomImage = [[UIImageView alloc] initWithImage:pinView.image];
        
        pinView.rightCalloutAccessoryView = rightButton;
        pinView.leftCalloutAccessoryView = myCustomImage;
        
        [pinView addObserver:self
                  forKeyPath:@"selected"
                     options:NSKeyValueObservingOptionNew
                     context:(__bridge void *)(GMAP_ANNOTATION_SELECTED)];
        
        return pinView;
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    
    NSString *action = (__bridge NSString*)context;
    MKAnnotationView *annotation = (MKAnnotationView*)object;
    
    if([action isEqualToString:GMAP_ANNOTATION_SELECTED]){
        BOOL annotationAppeared = [[change valueForKey:@"new"] boolValue];
        
        if (annotationAppeared) {
            //build our custom popover view
            UIViewController* popoverContent = [[UIViewController alloc] init];
            int maxHeight = 200;
            UIView* popoverView = [[UIView alloc]
                                   initWithFrame:CGRectMake(0, 10, 250, 160)];
            popoverContent.view = popoverView;
            
            
            UILabel *lbName = [[UILabel alloc] init];
            [lbName setFont:[UIFont fontWithName:@"Arial-Bold" size:14]];
            [lbName setTextColor:[UIColor blackColor]];
            [lbName setBackgroundColor:[UIColor clearColor]];
            [lbName setNumberOfLines:0];
            [lbName setText:[annotation.annotation title]];
            CGRect rectName = [lbName textRectForBounds:CGRectMake(12, 12, 200-10, 70) limitedToNumberOfLines:0];
            [lbName setFrame:rectName];
            [popoverView addSubview:lbName];
            
            NSString *info = [NSString string];
            info = [annotation.annotation subtitle];
            
            UILabel *lbData = [[UILabel alloc] init];
            [lbData setTextColor:[UIColor blackColor]];
            [lbData setBackgroundColor:[UIColor clearColor]];
            [lbData setFont:[UIFont fontWithName:@"Arial" size:12]];
            [lbData setNumberOfLines:0];
            [lbData setText:info];
            CGRect rectData = [lbData textRectForBounds:CGRectMake(12, rectName.origin.y + rectName.size.height + 12, 230, maxHeight - rectName.size.height - 12) limitedToNumberOfLines:0];
            [lbData setFrame:rectData];
            [popoverView addSubview:lbData];
            
            
            
            popoverContent.preferredContentSize = popoverView.frame.size;
            
            [self setPopoverController:[[UIPopoverController alloc] initWithContentViewController:popoverContent]];
            [self.popoverController setDelegate:self];
            
            
            CGPoint p = [self.mapItau convertCoordinate:annotation.annotation.coordinate toPointToView:self.mapItau];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.popoverController presentPopoverFromRect:CGRectMake(p.x, p.y, 1, 1)
                                                        inView:self.mapItau
                                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                                      animated:YES];
            });
        }
        // do something
        
    }
}



-(BOOL)prefersStatusBarHidden {
    
    return YES;
}



-(void)setMap:(NSString *)lat withLongitude:(NSString *) longi
{
    
    NSString *latitude = lat;
    NSString *longitude =longi;
    self.currentLocation = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    [self.locationManager stopUpdatingLocation];
    CLLocationCoordinate2D location;
    
    location.latitude = (double) self.currentLocation.coordinate.latitude;
    location.longitude = (double) self.currentLocation.coordinate.longitude ;
    
    
    
    if([self.networkMonitor networkStatus])
    {
        self.mapItau.showsUserLocation = YES;
        
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 2000, 2000);
                               
                               [self.mapItau setRegion:region animated:YES];
                               [self getAgencias];
                               
                               
                           });
                           
                           
                       });
    }
    
    
}

-(void)removeNotificationApp
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}


@end
