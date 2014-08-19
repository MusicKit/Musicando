//
//  PegarNotasEPausasCena.m
//  Musicando
//
//  Created by Emerson Barros on 18/08/14.
//  Copyright (c) 2014 EMERSON DE SOUZA BARROS. All rights reserved.
//
#import "PegarNotasEPausasCena.h"
#define GRAVIDADE_MUNDO -0.05


@implementation PegarNotasEPausasCena

-(id)initWithSize:(CGSize)size{
    
    if (self = [super initWithSize: size]){
        
    //Configura física do mundo
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, GRAVIDADE_MUNDO);
        
    //Inicia zerado auxiliar para pausa, contadores de tempo e pontuação
        self.simboloMusicalAtual = @"";
        self.densidadeAtual = 0.02f;
        
        self.estadoPauseJogo = 0;
        self.tempoPercorrido = 0;
        self.auxTempoPercorrido = 0;
        self.pontuacaoJogadorAtual = 0;
        self.indiceSimboloAtualSorteado = 0;
        
        self.quantidadeMovimentoEsquerda = 1;
        self.quantidadeMovimentoDireita = 1;
        
    //Inicia lista de notas e indice para sorteio
        self.listaDeSimbolosMusicais = [[NSMutableArray alloc] initWithObjects: @"notaSemibreve", @"notaMinima", @"notaSeminima", @"notaColcheia", @"notaSemicolcheia", @"notaFusa", @"notaSemiFusa", @"pausa4Tempos", @"pausa2Tempos", @"pausa1Tempo", @"pausa1-2Tempo", @"pausa1-4Tempo", @"pausa1-8Tempo", @"pausa1-16Tempo", nil];
        
        self.listaNomeDosSimbolosMusicais = [[NSMutableArray alloc] initWithObjects: @"semibreve", @"miníma", @"seminíma", @"colcheia", @"semicolcheia", @"fusa", @"semifusa", @"pausa 4", @"pausa 2", @"pausa 1", @"pausa 1/2", @"pausa 1/4", @"pausa 1/8", @"pausa 1/16", nil];
        
        [self sortearSimboloAtual];
        [self sortearSimboloCerto];
        
    //Inicia primeiros nós
        [self carregarPrimeirosComponentes];
    }
    
    return self;
}


-(void)carregarPrimeirosComponentes{
    
//Ambiente
    [self criaFundo];
    [self criaPiso];
    [self criaMascote];
    
//Botoes
    [self addChild: [self criaBotaoDireita]];
    [self addChild: [self criaBotaoEsquerda]];
    
//Configura as labels de pontuação
    self.stringDePontuacao = [[SKLabelNode alloc]init];
    self.stringDePontuacao.fontColor = [UIColor blackColor];
    self.stringDePontuacao.fontSize = 50.0f;
    self.stringDePontuacao.position = CGPointMake(800, 700);
    self.stringDePontuacao.zPosition = 2;
    self.stringDePontuacao.text = @"Pontuação: ";
    self.stringDePontuacao.fontName = @"Marker Felt Thin";
    [self addChild: self.stringDePontuacao];
    
    self.labelDePontuacao = [[SKLabelNode alloc]init];
    self.labelDePontuacao.fontColor = [UIColor blackColor];
    self.labelDePontuacao.fontSize = 50.0f;
    self.labelDePontuacao.position = CGPointMake(950, 700);
    self.labelDePontuacao.zPosition = 2;
    self.labelDePontuacao.text = [NSString stringWithFormat: @"%d", self.pontuacaoJogadorAtual];
    self.labelDePontuacao.fontName = @"Marker Felt Thin";
    [self addChild: self.labelDePontuacao];
    
    self.stringDeSimboloMusical = [[SKLabelNode alloc]init];
    self.stringDeSimboloMusical.fontColor = [UIColor blackColor];
    self.stringDeSimboloMusical.fontSize = 50.0f;
    self.stringDeSimboloMusical.position = CGPointMake(710, 650);
    self.stringDeSimboloMusical.zPosition = 2;
    self.stringDeSimboloMusical.text = @"Símbolo: ";
    self.stringDeSimboloMusical.fontName = @"Marker Felt Thin";
    [self addChild: self.stringDeSimboloMusical];
    
    self.labelDeSimboloMusical = [[SKLabelNode alloc]init];
    self.labelDeSimboloMusical.fontColor = [UIColor blackColor];
    self.labelDeSimboloMusical.fontSize = 50.0f;
    self.labelDeSimboloMusical.position = CGPointMake(900, 650);
    self.labelDeSimboloMusical.zPosition = 2;
    self.labelDeSimboloMusical.text = self.simboloMusicalAtual;
    self.labelDeSimboloMusical.fontName = @"Marker Felt Thin";
    [self addChild: self.labelDeSimboloMusical];

//Simbolos
    [self simboloPraCair1];
    [self simboloPraCair2];
    [self simboloPraCair3];
}


/////////////////////////////////////////////////////// UPDATE DO TEMPO ////////////////////////////////////////////////
-(void)update:(CFTimeInterval)currentTime{
    
    if (self.estadoPauseJogo == 0) {
        self.auxTempoPercorrido+=1;
        
        //CADA 30ms do AUXILIAR = 1s NO TEMPO
        if (self.auxTempoPercorrido == 30) {
            
            //A cada 10 segundos cria novos simbolos
            if (self.tempoPercorrido % 10 == 0) {
//                [self simboloPraCair1];
//                [self simboloPraCair2];
//                [self simboloPraCair3];
            }
            
            //A cada 1 min troca o simbolo pedido e aumenta densidade
            if (self.tempoPercorrido % 60 == 0) {
                [self sortearSimboloAtual];
            }

        self.tempoPercorrido++;
        self.auxTempoPercorrido = 0;
        }
        
    }
    
}



/////////////////////////////////////////////////////// COLISÃO ////////////////////////////////////////////////////////
-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    SKPhysicsBody *primeiroCorpoFisico;
    SKPhysicsBody *segundoCorpoFisico;
    
//Padrão delegate
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
        primeiroCorpoFisico = contact.bodyA;
        segundoCorpoFisico = contact.bodyB;
    }
    else{
        primeiroCorpoFisico = contact.bodyB;
        segundoCorpoFisico = contact.bodyA;
    }
    
    
    
    //VERIFICADOR DAS COLISÕES
    if ((primeiroCorpoFisico.categoryBitMask & simboloMusicalCorreto) != 0) {
        
        //COLISÃO MASCOTE
        if((segundoCorpoFisico.categoryBitMask & mascoteCategoria) != 0){
                
                //SIMBOLO CERTO
                if([primeiroCorpoFisico.node.name isEqual: [self simboloMusicalAtual]]){
                    NSLog(@"%@ colidiu com mascote", primeiroCorpoFisico.node.name);

                    //Remove o simbolo da view
                    [primeiroCorpoFisico.node removeFromParent];
                    
                    //Adiciona pontuação
                    self.pontuacaoJogadorAtual += 10;
                    self.labelDePontuacao.text = [NSString stringWithFormat: @"%d", self.pontuacaoJogadorAtual];
                    
                //SIMBOLO ERRADO
                }else{
                    NSLog(@"GAMEOVER %@ colidiu com mascote", primeiroCorpoFisico.node.name);
                    //[self gameOver];
                    
                }
        
        
        
        //COLISAO NO CHÃO
        }else if((segundoCorpoFisico.categoryBitMask & pisoCategoria)!= 0){
            
                //NOTAS CERTAS
                if(![primeiroCorpoFisico.node.name isEqual: [self simboloMusicalAtual]]){
                    NSLog(@"GAMEOVER %@ colidiu com mascote", primeiroCorpoFisico.node.name);
                    //[self gameOver];
                    
                //NOTAS ERRADAS
                }else{
                    NSLog(@"%@ colidiu com mascote", primeiroCorpoFisico.node.name);
                    //Remove o simbolo da view
                    [primeiroCorpoFisico.node removeFromParent];
                    
                    //Adiciona pontuação
                    self.pontuacaoJogadorAtual += 10;
                    self.labelDePontuacao.text = [NSString stringWithFormat: @"%d", self.pontuacaoJogadorAtual];
                   
                }
            
        }
        
        
    }

    
}


/////////////////////////////////////////////////////// TOQUES ////////////////////////////////////////////////////////
//CHAMADO QUANDO HÁ UM TOQUE NA TELA
-(void)touchesBegan:(NSSet*)touches withEvent: (UIEvent*)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint: location];
    
    
//Botão direita
    if ([node.name isEqualToString:@"botaoDireita"]) {
        
        //Ate 2 movimentos
        if (self.quantidadeMovimentoDireita < 2) {
            self.botaoDireita.alpha = 0;
            
            [self acaoMoverDireita: _mascote];
            self.quantidadeMovimentoDireita++;
            
            if(self.quantidadeMovimentoEsquerda != 0)
                self.quantidadeMovimentoEsquerda--;
        }    }
    
//Botão esquerda
    if ([node.name isEqualToString:@"botaoEsquerda"]) {
        
        //Ate 2 movimentos
        if (self.quantidadeMovimentoEsquerda < 2) {
            self.botaoEsquerda.alpha = 0;
            
            [self acaoMoverEsquerda: _mascote];
            self.quantidadeMovimentoEsquerda++;
            
            if(self.quantidadeMovimentoDireita != 0)
                self.quantidadeMovimentoDireita--;
        }
    }
    
    
}

/////////////////////////////////////////////////////// SORTEIOS ////////////////////////////////////////////////////////
-(void)sortearSimboloAtual{
    
    self.indiceSimboloAtualSorteado = arc4random() % 14;
    
    self.simboloMusicalAtual = [self.listaDeSimbolosMusicais objectAtIndex: self.indiceSimboloAtualSorteado];
    self.labelDeSimboloMusical.text = [self.listaNomeDosSimbolosMusicais objectAtIndex: self.indiceSimboloAtualSorteado];
    
}

-(NSString*)sortearSimboloPraCair{
    
    self.indiceParaSorteio = arc4random() % 14;
    return [self.listaDeSimbolosMusicais objectAtIndex: self.indiceParaSorteio];

}

-(void)sortearSimboloCerto{
    _indiceSortearCerto = arc4random() % 3;
    NSLog(@"%d", _indiceSortearCerto);
}

/////////////////////////////////////////////////////// CRIAÇÃO ////////////////////////////////////////////////////////
//SIMBOLO 1
-(void)simboloPraCair1{
    
//Aloca, seta nome e tamanho do nó
    simbolo1 = [[SKNode alloc]init];
    
    if (_indiceSortearCerto == 0) {
        simbolo1.name = self.simboloMusicalAtual;
    }else{
        simbolo1.name = [self sortearSimboloPraCair];
    }
    
//Inicia
    self.simboloMusicalPraCair1 = [[SKSpriteNode alloc] init];
    self.simboloMusicalPraCair1.position = CGPointMake(312, 800);
    self.simboloMusicalPraCair1.size = CGSizeMake(50, 100);
    self.simboloMusicalPraCair1.zPosition = 5;
    
//Imagem
    SKTexture *textura = [SKTexture textureWithImageNamed: [NSString stringWithFormat:@"%@.png", simbolo1.name]];
    self.simboloMusicalPraCair1.texture = textura;
    
//Cria o corpo físico
    self.simboloMusicalPraCair1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: self.simboloMusicalPraCair1.size];
    self.simboloMusicalPraCair1.physicsBody.dynamic = YES;
    self.simboloMusicalPraCair1.physicsBody.affectedByGravity = YES;
    self.simboloMusicalPraCair1.physicsBody.density = self.densidadeAtual;
    self.simboloMusicalPraCair1.physicsBody.usesPreciseCollisionDetection = YES;
    self.simboloMusicalPraCair1.physicsBody.restitution = 0;
    self.simboloMusicalPraCair1.physicsBody.contactTestBitMask = pisoCategoria | mascoteCategoria;

    self.simboloMusicalPraCair1.physicsBody.categoryBitMask = simboloMusicalCorreto;
    NSLog(@"Simbolo 1 %@",simbolo1.name);
    
    [simbolo1 addChild: self.simboloMusicalPraCair1];
    [self addChild: simbolo1];

}

//SIMBOLO 2
-(void)simboloPraCair2{
    
    if (_indiceSortearCerto == 1) {
        simbolo2.name = [self simboloMusicalAtual];
    }else{
        simbolo2.name = [self sortearSimboloPraCair];
    }
    
//Aloca, seta nome e tamanho do nó
    simbolo2 = [[SKNode alloc]init];
    simbolo2.name = [self sortearSimboloPraCair];
    
//Inicia
    self.simboloMusicalPraCair2 = [[SKSpriteNode alloc] init];
    self.simboloMusicalPraCair2.position = CGPointMake(512, 800);
    self.simboloMusicalPraCair2.size = CGSizeMake(50, 100);
    self.simboloMusicalPraCair2.zPosition = 5;

//Imagem
    SKTexture *textura = [SKTexture textureWithImageNamed: [NSString stringWithFormat:@"%@.png", simbolo2.name]];
    self.simboloMusicalPraCair2.texture = textura;
    
//Cria o corpo físico
    self.simboloMusicalPraCair2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: self.simboloMusicalPraCair2.size];
    self.simboloMusicalPraCair2.physicsBody.dynamic = YES;
    self.simboloMusicalPraCair2.physicsBody.affectedByGravity = YES;
    self.simboloMusicalPraCair2.physicsBody.density = self.densidadeAtual;
    self.simboloMusicalPraCair2.physicsBody.usesPreciseCollisionDetection = YES;
    self.simboloMusicalPraCair2.physicsBody.restitution = 0;
    self.simboloMusicalPraCair2.physicsBody.contactTestBitMask = pisoCategoria | mascoteCategoria;
    
    self.simboloMusicalPraCair2.physicsBody.categoryBitMask = simboloMusicalCorreto;
    
    NSLog(@"Simbolo 2 %@",simbolo2.name);
    
    [simbolo2 addChild: self.simboloMusicalPraCair2];
    [self addChild: simbolo2];
    
}

//SIMBOLO 3
-(void)simboloPraCair3{
    
    if (_indiceSortearCerto == 2) {
        simbolo3.name = [self simboloMusicalAtual];
    }else{
        simbolo3.name = [self sortearSimboloPraCair];
    }
    
//Aloca, seta nome e tamanho do nó
    simbolo3 = [[SKNode alloc]init];
    simbolo3.name = [self sortearSimboloPraCair];
    
//Incia
    self.simboloMusicalPraCair3 = [[SKSpriteNode alloc] init];
    self.simboloMusicalPraCair3.position = CGPointMake(712, 800);
    self.simboloMusicalPraCair3.size = CGSizeMake(50, 100);
    self.simboloMusicalPraCair3.zPosition = 5;
    
//Imagem
    SKTexture *textura = [SKTexture textureWithImageNamed: [NSString stringWithFormat:@"%@.png", simbolo3.name]];
    self.simboloMusicalPraCair3.texture = textura;
    
//Cria o corpo físico
    self.simboloMusicalPraCair3.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: self.simboloMusicalPraCair3.size];
    self.simboloMusicalPraCair3.physicsBody.dynamic = YES;
    self.simboloMusicalPraCair3.physicsBody.affectedByGravity = YES;
    self.simboloMusicalPraCair3.physicsBody.density = self.densidadeAtual;
    self.simboloMusicalPraCair3.physicsBody.usesPreciseCollisionDetection = YES;
    self.simboloMusicalPraCair3.physicsBody.restitution = 0;
    self.simboloMusicalPraCair3.physicsBody.contactTestBitMask = pisoCategoria | mascoteCategoria;
    
    self.simboloMusicalPraCair3.physicsBody.categoryBitMask = simboloMusicalCorreto;
    NSLog(@"Simbolo 3 %@", simbolo3.name);

        [simbolo3 addChild: self.simboloMusicalPraCair3];
    [self addChild: simbolo3];
}


-(void)criaMascote{
    
//Incia
    _mascote = [[SKSpriteNode alloc] init];
    _mascote.position = CGPointMake(512, 100);
    _mascote.zPosition = 5;
    _mascote.name = @"mascote";
    
//Posicao e img
    SKTexture *textura = [SKTexture textureWithImageNamed: @"mascote.png"];
    _mascote.texture = textura;
    _mascote.size = CGSizeMake(100, 100);
    
//Cria o corpo físico do bloco
    _mascote.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: CGSizeMake(100, 30)];
    _mascote.physicsBody.dynamic = YES;
    _mascote.physicsBody.affectedByGravity = NO;
    _mascote.physicsBody.density = 0.2f;
    _mascote.physicsBody.usesPreciseCollisionDetection = YES;
    _mascote.physicsBody.restitution = 0;
    
//Colisao
    _mascote.physicsBody.categoryBitMask = mascoteCategoria;
    _mascote.physicsBody.contactTestBitMask = simboloMusicalCorreto | simboloMusicalErrado;
    
//Adiciona a textura ao nó e o nó a cena
    [self addChild: _mascote];
    
}

//FUNDO
-(void)criaFundo{
    
//Aloca, seta nome e posição do nó
    self.fundo = [[SKSpriteNode alloc] init];
    self.fundo.name = @"fundo";
    self.fundo.position  = CGPointMake(512, 384);
    
//Cria textura
    SKTexture *texturaFundoPrincipal = [SKTexture textureWithImageNamed: @"papelAntigo.jpg"];
    self.fundo.texture = texturaFundoPrincipal;
    self.fundo.size = CGSizeMake(1024, 768);
    self.fundo.zPosition = -5;
    
//Adiciona a textura ao nó e o nó a cena
    [self addChild: self.fundo];
}

//PISO
-(void)criaPiso{
    
//Aloca, seta nome e tamanho do nó
    piso = [[SKSpriteNode alloc]init];
    piso.name = @"piso";
    piso.position = CGPointMake(512, 10);
    
//Cria testura do piso
    SKTexture *texturaPiso = [SKTexture textureWithImageNamed: @"chao.png"];
    self.pisoPrincipal = [SKSpriteNode spriteNodeWithTexture:texturaPiso size: CGSizeMake(2400, 50)];
    
//Cria o corpo físico do piso
    self.pisoPrincipal.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: self.pisoPrincipal.size];
    self.pisoPrincipal.physicsBody.dynamic = NO;
    self.pisoPrincipal.physicsBody.affectedByGravity = NO;
    self.pisoPrincipal.physicsBody.allowsRotation = NO;
    self.pisoPrincipal.physicsBody.density = 0.6f;
    self.pisoPrincipal.physicsBody.restitution = 0;
    
//Configuração colisão do corpo físico do piso
    self.pisoPrincipal.physicsBody.categoryBitMask = pisoCategoria;
    self.pisoPrincipal.physicsBody.contactTestBitMask = simboloMusicalErrado | simboloMusicalCorreto;
    
//Adiciona a textura ao nó, e o nó a cena
    [piso addChild: self.pisoPrincipal];
    [self addChild: piso];
}

-(SKSpriteNode*)criaBotaoDireita{
    
    _botaoDireita = [[SKSpriteNode alloc] init];
    _botaoDireita = [SKSpriteNode spriteNodeWithImageNamed:@"buttonMagic.png"];
    _botaoDireita.position = CGPointMake(900, 200);
    _botaoDireita.size = CGSizeMake(50, 50);
    _botaoDireita.name = @"botaoDireita";
    _botaoDireita.zPosition = +5.0;
    
    return _botaoDireita;
}

-(SKSpriteNode*)criaBotaoEsquerda{
    
    _botaoEsquerda = [[SKSpriteNode alloc] init];
    _botaoEsquerda = [SKSpriteNode spriteNodeWithImageNamed:@"buttonMagic.png"];
    _botaoEsquerda.position = CGPointMake(100, 200);
    _botaoEsquerda.size = CGSizeMake(50, 50);
    _botaoEsquerda.name = @"botaoEsquerda";
    _botaoEsquerda.zPosition = +5.0;
    
    return _botaoEsquerda;
}

/////////////////////////////////////////////////////// AÇÕES, ANIMAÇÕES E SPRITES ////////////////////////////////////////////////////////

//MOVIMENTO DIREITA ESQUERDA
-(void)acaoMoverDireita: (SKNode*)node{
    SKAction *moverPraDireita = [SKAction moveTo: CGPointMake(node.position.x+200, node.position.y) duration: 1.5];
    [node runAction: moverPraDireita];
    
    self.botaoDireita.alpha = 1;

}

-(void)acaoMoverEsquerda: (SKNode*)node{
    SKAction *moverPraEsquerda = [SKAction moveTo: CGPointMake(node.position.x-200, node.position.y) duration: 1.5];
    [node runAction: moverPraEsquerda];
    
    self.botaoEsquerda.alpha = 1;
}


//RECORTA SPRITES E ANIMA
-(NSMutableArray*)loadSpriteSheetFromImageWithName:(NSString*)name withNumberOfSprites:(int)numSprites withNumberOfRows:(int)numRows withNumberOfSpritesPerRow:(int)numSpritesPerRow {
    NSMutableArray* animationSheet = [NSMutableArray array];
    
    SKTexture *mainTexture = [SKTexture textureWithImageNamed:name];
    
    for(int j = numRows-1; j >= 0; j--) {
        for(int i = 0; i < numSpritesPerRow; i++) {
            
            SKTexture* part = [SKTexture textureWithRect:CGRectMake( i * (1.0f/numSpritesPerRow), j * (1.0f/numRows), 1.0f/numSpritesPerRow, 1.0f/numRows) inTexture: mainTexture];
            [animationSheet addObject: part];
            
            if(animationSheet.count == numSprites)
                break;
        }
        
        if(animationSheet.count == numSprites)
            break;
        
    }
    return animationSheet;
}

//////////////////////////////// GAME OVER ////////////////////////////////////////////
-(void)gameOver{
    [[GameOverViewController sharedManager]gameOverParaUmaCena].view.hidden = NO;
    [self pausaJogo];
}

-(void)pausaJogo{
    self.scene.view.paused = YES;
}

@end