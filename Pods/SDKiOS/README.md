# SDKiOS

## Instalação

O SDKiOS está disponível via [CocoaPods](http://cocoapods.org). Para instalar basta adicionar a linha abaixo no seu Podfile e rodar o `pod install`:

```ruby
pod 'SDKiOS', :git => 'git@10.56.147.16:framework/sdk-ios.git'
```

## Pods incluídos como dependência no Core

- [AFNetworking (2.5.4)](http://afnetworking.com)
- [AFNetworkActivityLogger (2.0.4)](https://github.com/AFNetworking/AFNetworkActivityLogger)
- [CocoaLumberjack (2.0.0)](https://github.com/CocoaLumberjack/CocoaLumberjack)
- [libextobjc (0.4.1)](https://github.com/jspahrsummers/libextobjc)
- [Mantle (2.0.2)](https://github.com/Mantle/Mantle)

## Inicializando o App

O SDKiOS disponibiliza um método para realizar configurações gerais do app. Na versão atual, é feita apenas a configuração dos logs para utilizar CocoaLumberjack em desenvolvimento e desabilitar logs em produção. Para que isso funcione, é necessário chamar o método `configureApp` da classe `IMAppConfigurator`. 

Também é necessário inicializar o `IMBackendClient`. Essa classe deve ser inicializada em produção apenas com `initializeDefaultClient` onde utilizará os endereços oficiais dos servidores.
Em ambientes de teste deve ser utilizado com `initWithRoutes:routerURL:andLightURL:`, passando como parâmetros as URLs de teste do router e da api light. Configurações com URL personalizada em produção gerarão exception e o app quebrará.

Recomenda-se realizar estar configurações no `application:didFinishLaunchingWithOptions:` conforme exemplo abaixo.

```objc

#import "AppDelegate.h"
#import <sdk-ios-core/SDKiOSCore.h>

NSString *const kRouterDevBaseURL = @"http://10.77.138.8:8080/router-app/router";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Configura logs em debug para usar CocoaLumberjack
    // Para ter o log colorido é necessário instalar o plugin XcodeColors via Alcatraz
    [IMAppConfigurator configureApp];

    // Configuração para build de teste/debug com URLs customizadas

    NSDictionary *routes = @{
        @"teclado"   : @"/login/empresas/teclado_virtual",
        @"logon"     : @"/login/empresas/autenticacao",
        @"listarContasOperador" : @"/operadores/{codigo_operador}/contas"
    };

    NSURL *routerURL = [NSURL URLWithString:kRouterDevBaseURL];
    [IMBackendClient initWithRoutes:routes routerURL:routerURL andLightURL:nil];
    
    // Configuração para build de produção e teste/debug com URLs padrão
    // Detecta automaticamente o ambiente do build e usa a URL do ambiente correto
    // Atenção para build com certificado enterprise que serão considerados produção sempre

    [IMBackendClient initializeDefaultClient];

    // Obs: o IMBackendClient só deve ser inicializado uma vez, para recuperá-lo após a inicialização 
    // deve ser utilizado o método `sharedClient` como `[IMBackendClient sharedClient]`.
    
    return YES;
}

@end

```

## Modelo de dicionário de configuração de endpoints para API Light

```objc

@{
    @"teclado"   : @"/login/empresas/teclado_virtual",
    @"logon"     : @"/login/empresas/autenticacao",
    @"listarContasOperador" : @"/operadores/{codigo_operador}/contas"
}

```


## Modelo de dicionário de parâmetros para requests

```objc

@{
    // obrigatório
    @"method" : @"GET | POST | PUT | PATCH | DELETE",

    // opcional
    @"query": @{ @"key"   : @"valor da chave do query parameter : NSString",
                 @"value" : @"valor do query parameter : NSString" },

    // opcional
    @"path": @{ @"key"   : @"chave do path component : NSString",
                @"value" : @"valor do path component : NSString" },

    // opcional
    @"header" : @{ @"key"  : @"valor da chave do header customizado : NSString",
                   @"value" : @"valor do header customizado : NSString" },

    // opcional
    @"body": @{} // NSDictionary para ser serializado e enviado como JSON body
}

```

## Modelos de chamadas a API Light e Router

```objc

- (void)executePreLogin
{
    NSDictionary *params =
    @{ @"method" : @"POST",
       @"query"  : @{},
       @"path"   : @{},
       @"header" : @{},
       @"body"   : @{@"pre-login" : @"pre-login",
                     @"tipoLogon" : @"50",
                     @"usuario.operador" : @"123456789" } };

    @weakify(self);
    
    [self.client requestWithFormURLEncodedParams:params OPKey:nil
    successBlock:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
    
        @strongify(self);
        DDLogWarn(@"Completado com data: %@",responseObject);
        self.operador = responseObject[0][@"codigoOperador"];
            
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        
       DDLogError(@"erro: %@",error.localizedDescription);
       [SVProgressHUD showErrorWithStatus:error.localizedDescription];        
    }];
}

- (void)askForKeyboard
{
    NSDictionary *params =
    @{ @"method" : @"POST",
       @"query"  : @{},
       @"path"   : @{},
       @"header" : @{},
       @"body"   : @{@"operador" : @"123456789"} };

    @weakify(self);
    [self.client requestWithJSONParams:params OPKey:@"teclado"
    successBlock:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
    
        @strongify(self);
        DDLogWarn(@"Completado com data: %@",responseObject);
        self.idTeclado = responseObject[@"id_teclado"];
        
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
    
        DDLogError(@"erro: %@",error.localizedDescription);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)lightAskForKeyboard
{
    NSDictionary *params =
        @{ @"method" : @"GET",
           @"query"  : @{@"codigo_operador" : @"892363568"},
           @"path"   : @{},
           @"header" : @{},
           @"body"   : @{} };
    
    @weakify(self);
    [self.client requestWithJSONParams:params OPKey:@"teclado"
      successBlock:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
          
          @strongify(self);
          DDLogWarn(@"Completado com data: %@",responseObject);
          self.idTeclado = responseObject[@"id_teclado"];
          
      } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
          
          DDLogError(@"erro: %@",error.localizedDescription);
          [SVProgressHUD showErrorWithStatus:error.localizedDescription];
      }];
}

- (void)performLogon
{
    if (!_operador) {
        [SVProgressHUD showErrorWithStatus:@"Pré-login não realizado"];
        return;
    }
    if (!_idTeclado) {
        [SVProgressHUD showErrorWithStatus:@"Teclado não solicitado"];
        return;
    }

    NSDictionary *params =
    @{ @"method" : @"POST",
       @"query"  : @{},
       @"path"   : @{},
       @"header" : @{},
       @"body"   : @{ @"operador"   : _operador,
                      @"senha"      : @"E3G671D21OIU70",
                      @"id_teclado" : _idTeclado } };
    
    [self.client requestWithFormURLEncodedParams:params OPKey:@"logon"
    successBlock:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        
        DDLogWarn(@"Completado com data: %@",responseObject);
        
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"erro: %@",error.localizedDescription);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];        
    }];
}

- (void)askForUserMenu
{
    NSDictionary *params =
    @{ @"method" : @"POST",
       @"query"  : @{},
       @"path"   : @{},
       @"header" : @{},
       @"body"   : @{}};
    
    [self.client requestWithJSONParams:params OPKey:@"menu"
      successBlock:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
          
          DDLogWarn(@"Completado com data: %@",responseObject);
          
      } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
          
          DDLogError(@"erro: %@",error.localizedDescription);
          [SVProgressHUD showErrorWithStatus:error.localizedDescription];
      }];
}

- (void)askForUserAccounts
{
    NSDictionary *params =
    @{ @"method" : @"POST",
       @"query"  : @{},
       @"path"   : @{},
       @"header" : @{},
       @"body"   : @{}};
    
    [self.client requestWithJSONParams:params OPKey:@"listarContasOperador"
      successBlock:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
          
          DDLogWarn(@"Completado com data: %@",responseObject);
          
      } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
          
          DDLogError(@"erro: %@",error.localizedDescription);
      }];
}

```