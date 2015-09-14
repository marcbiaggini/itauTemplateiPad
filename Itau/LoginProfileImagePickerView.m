//
//  LoginProfileImagePickerView.m
//  Itau
//
//  Created by TIVIT_iOS on 13/07/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import "LoginProfileImagePickerView.h"
#import "UIImage+Itau.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <libextobjc/extobjc.h>


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)


@interface LoginProfileImagePickerView() {
    
    BOOL imgPadrao;
}

@property (strong, nonatomic) UIImage *theImage;

@property (strong, nonatomic) UIImageView *imageViewRecorteFoto;
@property (retain, nonatomic) UIActivityIndicatorView *indicadorAtividade;

// Gestos (reduzir ou aumentar tamanho e definir enquadramento
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation LoginProfileImagePickerView

-(instancetype)init {
    
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] objectAtIndex:0];
        
        [self prepareUI];
    }
    return self;
}

-(void)updateImageMasks {
    
    if (!imgPadrao) {
        if (!self.mascaraFoto) {
            CAShapeLayer *cinza = [CAShapeLayer layer];
            cinza.fillColor = [[UIColor grayColor] CGColor];
            cinza.backgroundColor = [[UIColor blackColor] CGColor];
            cinza.opacity = 0.6;
            _mascaraFoto = cinza;
        }
        [self.imageView.layer addSublayer:self.mascaraFoto];
        self.mascaraFoto.frame = self.imageView.bounds;
        
        if (!self.imageViewRecorteFoto) {
            self.imageViewRecorteFoto = [[UIImageView alloc] init];
            self.imageViewRecorteFoto.contentMode = self.imageView.contentMode;
        }
        
        [self.imageView addSubview:self.imageViewRecorteFoto];
        self.imageViewRecorteFoto.layer.mask = self.maskLayer;
        
        self.imageViewRecorteFoto.frame = self.imageView.bounds;
        self.imageViewRecorteFoto.image = self.imageView.image;
    }
    
}

-(void)setTheImage:(UIImage *)theImage {
    
    _theImage = theImage;
    self.imageView.image = theImage;
    [self updateImageMasks];
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    [self updateImageMasks];
}

-(void)prepareUI {
    
    self.clipsToBounds = YES;
    
    // Texto descrição de recorte da imagem
    _descricaoRecorteImagem.textColor = [UIColor whiteColor];
    _descricaoRecorteImagem.text = @"Arraste e posicione a máscara em cima da área desejada.";
    
    // Imagem padrão
    [self imagemPadrao];
    
    [self.botaoTirarFoto setImage:[UIImage targetedImageNamed:@"tirar_foto"] forState:UIControlStateNormal];
    [self.botaoEscolherFoto setImage:[UIImage targetedImageNamed:@"escolher_foto"] forState:UIControlStateNormal];
    [self.botaoFotoFacebook setImage:[UIImage targetedImageNamed:@"importar_facebook"] forState:UIControlStateNormal];
    [self.botaoExcluirFoto setImage:[UIImage targetedImageNamed:@"excluir_foto"] forState:UIControlStateNormal];
    [self.botaoUtilizarPressionado setImage:[UIImage targetedImageNamed:@"salvar"] forState:UIControlStateNormal];
    
    // criar layer da máscara para a iamgem
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    self.maskLayer = maskLayer;
    
    // Criar layer em círculo para ficar por cima da imagem
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.imageView.layer addSublayer:circleLayer];
    self.circleLayer = circleLayer;
    
    // Definindo local do círculo (layer) criado
    [self updateCirclePathAtLocation:CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 3.0) radius:self.bounds.size.width * 0.30];
    
    // Criar enquadramento da imagem (via gestos) create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.imageView addGestureRecognizer:pan];
    self.imageView.userInteractionEnabled = YES;
    self.pan = pan;
    
    // Reduzir ou aumentar tamanho da máscara utilizando gestos
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self addGestureRecognizer:pinch];
    self.pinch = pinch;
    
    // Verifica se existe camera no iPad
    self.botaoTirarFoto.enabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}





// Método utilizado para foto importada do Facebook
-(void)imagemFacebook:(UIImage *)fotoUsuario{
    
    self.theImage = fotoUsuario;
    imgPadrao = NO;
}

// Método utilizado na captura de imagem (álbum ou captura) - botão done
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    imgPadrao = NO;
    
    [self limparViews];
    
    [self.popoverImageViewController dismissPopoverAnimated:true];
    
    if (!picker.allowsEditing)
    {
        self.theImage = info[UIImagePickerControllerOriginalImage];
    }
    else
    {
        self.theImage = info[UIImagePickerControllerEditedImage];
    }
    
    [self updateImageMasks];
}


// Método utilizado na captura de imagem (álbum ou captura) - botão cancel
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


// Método chamado para definir imagem padrão
- (void)imagemPadrao
{
    imgPadrao = YES;
    UIImage *imagemDefault = [UIImage targetedImageNamed:@"editar_primeira_foto"];
    self.theImage = imagemDefault;
}

-(void)showActivityIndicator {
    
    if (self.activityIndicator == nil) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        self.activityIndicator.hidesWhenStopped = YES;
        self.activityIndicator.exclusiveTouch = YES;
        self.activityIndicator.opaque = NO;
        self.activityIndicator.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        
        [self addSubview:self.activityIndicator];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];
        
        [self.activityIndicator startAnimating];
        [self layoutIfNeeded];
    }
}

-(void)dismissActivityIndicator {
    
    if (self.activityIndicator) {
        
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}


#pragma mark - Métodos Auxiliares

// Método utilizado para definir circulo a ser utilizado para cortar a foto
- (void)updateCirclePathAtLocation:(CGPoint)location radius:(CGFloat)radius
{
    self.circleCenter = location;
    self.circleRadius = radius;
    
    float novoX = location.x;
    float novoY = location.y;
    
    if (novoX - radius < 0){
        novoX = radius;
    }
    if (novoX + radius > self.imageView.bounds.size.width){
        novoX = self.imageView.bounds.size.width - radius;
    }
    if (novoY - radius < 0){
        novoY = radius;
    }
    if (novoY + radius > self.imageView.bounds.size.height){
        novoY = self.imageView.bounds.size.height - radius;
    }
    
    self.circleCenter = CGPointMake(novoX, novoY);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:self.circleCenter
                    radius:self.circleRadius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
    
    self.maskLayer.path = [path CGPath];
    self.circleLayer.path = [path CGPath];
}

#pragma mark - Métodos (abrir albúm, tirar e salvar foto)

- (void)limparViews
{
    if (_mascaraFoto != nil && _imageViewRecorteFoto.image != nil)
    {
        [_mascaraFoto removeFromSuperlayer];
        _imageViewRecorteFoto.image = nil;
        [_imageViewRecorteFoto removeFromSuperview];
    }
}

// Método utilizado para acessar albúm de fotos
-(IBAction)acessarAlbum:(id)sender {
    
    self.imageString.text = @"";
    
    if ([self.popoverImageViewController isPopoverVisible]) {
        [self.popoverImageViewController dismissPopoverAnimated:YES];
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            UIButton *botao = (UIButton*)sender;
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            imagePicker.allowsEditing = YES;
            
            self.popoverImageViewController = [[UIPopoverController alloc]
                                               initWithContentViewController:imagePicker];
            
            self.popoverImageViewController.delegate = self;
            
            [self.popoverImageViewController presentPopoverFromRect:botao.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            
        }
    }
}

// Método utilizado para chamar camera
-(IBAction)tirarFoto:(UIButton *)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        
        //Permite o crop das fotos
        imagePicker.allowsEditing = YES;
        
        //Vai direto para o Camera Roll
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront | UIImagePickerControllerCameraDeviceRear;
        }
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        self.popoverImageViewController.contentViewController.preferredContentSize = CGSizeMake(600.0, 1000.0);
        
        popover.delegate = self;
        
        [popover presentPopoverFromRect:sender.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Atenção" message:@"Câmera indisponível" delegate:nil cancelButtonTitle:@"Voltar" otherButtonTitles:nil]show];
    }
    
    [self limparViews];
}


// Método utilizado para importar foto do Facebook
-(IBAction)importarFotoFacebook:(UIButton *)sender {
    
    [self limparViews];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithReadPermissions:@[@"public_profile"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else if (result.isCancelled) {
            
            [self dismissActivityIndicator];

            [[[UIAlertView alloc] initWithTitle:@"Atenção" message:@"Falha na conexão com o Facebook. Por favor tente novamente." delegate:nil cancelButtonTitle:@"Voltar" otherButtonTitles:nil]show];
        
        } else {
            
            if ([FBSDKAccessToken currentAccessToken]) {
                
                [self showActivityIndicator];
                
                @weakify(self)
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=picture.width(768)" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        
                        @strongify(self)
                        
                        NSDictionary *data = (NSDictionary *)result[@"picture"][@"data"];
                        
                        if (![data[@"is_silhouette"] boolValue]) {
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                
                                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString: data[@"url"]]];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    if (imageData) {
                                        
                                        imgPadrao = NO;
                                        
                                        [self limparViews];
                                        
                                        self.theImage = [UIImage imageWithData:imageData];
                                        
                                        [self updateImageMasks];
                                        
                                        [self dismissActivityIndicator];
                                        
                                        [login logOut];
                                        
                                    } else {
                                        
                                        [self dismissActivityIndicator];
                                    }
                                    
                                });
                                
                            });
                            
                        }
                        
                    } else {
                        
                        @strongify(self)
                        
                        [self dismissActivityIndicator];
                        
                        [[[UIAlertView alloc] initWithTitle:@"Atenção" message:@"Falha na conexão com o Facebook. Por favor tente novamente." delegate:nil cancelButtonTitle:@"Voltar" otherButtonTitles:nil]show];
                    }
                }];
            }
        }
    }];
    
}

#pragma mark - Métodos NSURLConnection
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    
    if (_dadosImagem == nil) {
        _dadosImagem = [[NSMutableData alloc] initWithCapacity:2048];
    }
    
    [_dadosImagem appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    
    [_activityIndicator stopAnimating];
    _conexao = nil;
    
    _imageView.image = [UIImage imageWithData:_dadosImagem];
    [self imagemFacebook:_imageView.image];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [_activityIndicator stopAnimating];
}



// Método para exportar foto para Kony
-(IBAction)utilizarFoto:(UIButton *)sender {
    
    if (!imgPadrao) {
        CGFloat scale  = [[self.imageView.window screen] scale];
        CGFloat radius = self.circleRadius * scale;
        CGPoint center = CGPointMake(self.circleCenter.x * scale, self.circleCenter.y * scale);
        
        CGRect frame = CGRectMake(center.x - radius,
                                  center.y - radius,
                                  radius * 2.0,
                                  radius * 2.0);
        
        // Remover temporariamente o layer do círculo
        CALayer *circleLayer = self.circleLayer;
        [self.circleLayer removeFromSuperlayer];
        
        // render the clipped image
        UIGraphicsBeginImageContextWithOptions(self.imageViewRecorteFoto.frame.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if ([self.imageViewRecorteFoto respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            // SE iOS 7, apenas mostra imagem
            [self.imageViewRecorteFoto drawViewHierarchyInRect:self.imageViewRecorteFoto.bounds afterScreenUpdates:YES];
        } else {
            // SE iOS anterior ao iOS 7, corte manual
            CGContextAddArc(context, self.circleCenter.x, self.circleCenter.y, self.circleRadius, 0, M_PI * 2.0, YES);
            CGContextClip(context);
            [self.imageViewRecorteFoto.layer renderInContext:context];
        }
        
        // Capturando a imagem e fechando contexto da imagem
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Adicionando layer em círculo novamente
        [self.imageViewRecorteFoto.backgroundColor = [UIColor grayColor]CGColor];
        [self.imageViewRecorteFoto.layer addSublayer:circleLayer];
        
        // Cortando a imagem
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], frame);
        CGFloat escala = frame.size.width / (81 * scale);
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:escala orientation:UIImageOrientationUp];
        
        // Salvando a imagem em NSData
        NSData *data = UIImagePNGRepresentation(croppedImage);
        
        if ([self.delegate respondsToSelector:@selector(loginImagePicker:willFinishWithImageData:)]) {
            [self.delegate loginImagePicker:self willFinishWithImageData:data];
        }
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(loginImagePickerWillFinishAskingDeleteImage:)]) {
            
            [self.delegate loginImagePickerWillFinishAskingDeleteImage:self];
        }
    }
    
    [self dismiss];
}

// Método para cancelar
-(IBAction)cancelar {
    
    if ([self.delegate respondsToSelector:@selector(loginImagePickerDidCancel:)]) {
        [self.delegate loginImagePickerDidCancel:self];
    }
    
    [self dismiss];
}

-(void)dismiss {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



// Método chamado para excluir foto atual
-(IBAction)excluirFotoAtual
{
    if (_imageViewRecorteFoto.image != nil) {
        
        [self limparViews];
        [self imagemPadrao];
        _imageString.text = @"";
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(loginImagePickerWillFinishAskingDeleteImage:)]) {
            [self.delegate loginImagePickerWillFinishAskingDeleteImage:self];
        }
    }
}

#pragma mark - Conversão de imagem para String

// Método utilizado para converter imagem para string
- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

#pragma mark - Reconhecimento de gestos

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    static CGPoint oldCenter;
    CGPoint tranlation = [gesture translationInView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldCenter = self.circleCenter;
    }
    
    CGPoint newCenter = CGPointMake(oldCenter.x + tranlation.x, oldCenter.y + tranlation.y);
    
    [self updateCirclePathAtLocation:newCenter radius:self.circleRadius];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    static CGFloat oldRadius;
    CGFloat scale = [gesture scale];
    
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldRadius = self.circleRadius;
    }
    
    CGFloat newRadius = oldRadius * scale;
    if (newRadius < 81)
    {
        newRadius = 81;
    }
    else if (newRadius > 386)
    {
        newRadius = 386;
    }
    [self updateCirclePathAtLocation:self.circleCenter radius:newRadius];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ((gestureRecognizer == self.pan   && otherGestureRecognizer == self.pinch) ||
        (gestureRecognizer == self.pinch && otherGestureRecognizer == self.pan))
        if (gestureRecognizer == self.pan)
            
        {
            return YES;
        }
    
    return NO;
}






@end
