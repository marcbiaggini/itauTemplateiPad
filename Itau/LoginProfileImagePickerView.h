//
//  LoginProfileImagePickerView.h
//  Itau
//
//  Created by TIVIT_iOS on 13/07/15.
//  Copyright (c) 2015 Pérsio GV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginProfileImagePickerView;

@protocol LoginProfileImagePickerViewDelegate <NSObject>

-(void)loginImagePicker:(LoginProfileImagePickerView *)picker willFinishWithImageData:(NSData *)imageData;
-(void)loginImagePickerWillFinishAskingDeleteImage:(LoginProfileImagePickerView *)picker;
-(void)loginImagePickerDidCancel:(LoginProfileImagePickerView *)picker;

@end

@interface LoginProfileImagePickerView : UIView <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, UIPopoverControllerDelegate>

// Propriedades utilizadas para login do Facebook
@property (strong, nonatomic) NSURLConnection *conexao;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *dadosImagem;

// Propriedade iOS 5 - álbum de fotos
@property (strong) UIPopoverController *popoverImageViewController;

@property (nonatomic, strong) IBOutlet UIButton *botaoTirarFoto; //cameraTirarFoto
@property (nonatomic, strong) IBOutlet UIButton *botaoEscolherFoto; //escolherFoto
@property (nonatomic, strong) IBOutlet UIButton *botaoExcluirFoto;

//@property (nonatomic, strong) UIImagePickerController *selecaoFotos;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UIButton *botaoFotoFacebook;

@property (strong, nonatomic) IBOutlet UILabel *imageString;
@property (strong, nonatomic) IBOutlet UILabel *descricaoRecorteImagem;

@property (strong, nonatomic) IBOutlet UIButton *botaoUtilizarPressionado;

@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGPoint circleCenter;

@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *mascaraFoto;

@property (strong, nonatomic) id<LoginProfileImagePickerViewDelegate> delegate;




-(IBAction)acessarAlbum:(id)sender;
-(IBAction)tirarFoto:(UIButton *)sender;
-(IBAction)utilizarFoto:(UIButton *)sender;
-(IBAction)cancelar;
-(IBAction)excluirFotoAtual;
-(IBAction)importarFotoFacebook:(id)sender;





@end
