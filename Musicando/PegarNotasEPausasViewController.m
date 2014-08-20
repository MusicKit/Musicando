//
//  PegarNotasEPausasViewController.m
//  Musicando
//
//  Created by EMERSON DE SOUZA BARROS on 18/08/14.
//  Copyright (c) 2014 EMERSON DE SOUZA BARROS. All rights reserved.
//

#import "PegarNotasEPausasViewController.h"

@interface PegarNotasEPausasViewController ()
@end


@implementation PegarNotasEPausasViewController

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskLandscape;
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear: animated];
    [[EfeitoTransicao sharedManager]finalizaExercicio:self];
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //Add barra, Mascote, View de Retornar Pagina ao Xib
    [[EfeitoComponeteView sharedManager]addComponetesViewExercicio:self:[Biblioteca sharedManager].exercicioAtual];
    self.viewGesturePassaFala = [MascoteViewController sharedManager].viewGesturePassaFala;
    
    //Gamer para SpriteKit
    [[GameOverViewController sharedManager]addBarraSuperioAoXibOculto:self:[Biblioteca sharedManager].exercicioAtual];
    
    //Cria Seletor e manda ele como paramentro para outros View Controllers poderem usar
    SEL selectors1 = @selector(pulaFalaMascote);
    [[MascoteViewController sharedManager] addGesturePassaFalaMascote: self.viewGesturePassaFala :selectors1:self];
    [[RetornaPaginaViewController sharedManager]addGesturePassaFalaMascote: [RetornaPaginaViewController sharedManager].viewRetornaPagina:selectors1:self];
    
    //Biblioteca
    self.lblFalaDoMascote = [MascoteViewController sharedManager].lblFalaDoMascote;
    self.testaBiblio = [MascoteViewController sharedManager].testaBiblio;
    self.testaConversa = [MascoteViewController sharedManager].testaConversa;
    self.imagemDoMascote2 = [MascoteViewController sharedManager].imagemDoMascote2;
    [[EfeitoMascote sharedManager]chamaAnimacaoMascotePulando:self.imagemDoMascote2];
    
    [self pulaFalaMascote];
}

-(void)chamaJogo{
    
    //Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    skView.backgroundColor = [UIColor whiteColor];
    
    //Create and configure the scene.
    SKScene * cenaPrincipal = [PegarNotasEPausasCena sceneWithSize: skView.bounds.size];
    cenaPrincipal.scaleMode = SKSceneScaleModeAspectFill;
                                     
    //Present the scene.
    [skView presentScene: cenaPrincipal];
}


-(void)addGesturePassaFalaMascote:(UIView*)viewGesture{
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pulaFalaMascote)];
    singleTap.numberOfTouchesRequired = 1;
    singleTap.enabled = NO;
    viewGesture.userInteractionEnabled = NO;
    [viewGesture addGestureRecognizer:singleTap];
    
}

//Gerencia o passa de falas
-(void)pulaFalaMascote{
    //Usa pra não dar erro de nulo na ultima fala
    int contadorMaximo = (int)self.testaConversa.listaDeFalas.count;
    
    [[BarraSuperiorViewController sharedManager]txtNumeroAulaAtual].text = [NSString stringWithFormat:@"%d",1+[MascoteViewController sharedManager].contadorDeFalas];
    
    if([MascoteViewController sharedManager].contadorDeFalas < contadorMaximo){
        switch ([MascoteViewController sharedManager].contadorDeFalas) {
            case 0:
                [self chamaMetodosFala0];
                break;
            case 1:
                [self chamaMetodosFala1];
                break;
            default:
                break;
        }
        
        self.testaFala = [self.testaConversa.listaDeFalas objectAtIndex:[MascoteViewController sharedManager].contadorDeFalas];
        self.lblFalaDoMascote.text = self.testaFala.conteudo;
        
        [MascoteViewController sharedManager].contadorDeFalas += 1;
        
    }
}

-(void)chamaMetodosFala0{
    [[EfeitoMascote sharedManager]chamaAddBrilho:self.imagemDoMascote2: 2.0f:self.viewGesturePassaFala];
}

-(void)chamaMetodosFala1{
    
    for(UIView *view in self.view.subviews){
        if((view.tag == 1001)||(view.tag == 9999)){
        }else [view removeFromSuperview];
    }
    
    [self chamaJogo];
}

@end

