//
//  BarraSuperiorViewController.h
//  Musicando
//
//  Created by Vinicius Resende Fialho on 22/07/14.
//  Copyright (c) 2014 EMERSON DE SOUZA BARROS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EfeitoBarraSuperior.h"
#import "BibliotecaViewController.h"

@interface BarraSuperiorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnHome;
- (IBAction)btnActionHome:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *txtAulaAtual;

@end
