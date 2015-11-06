//
//  ViewController.m
//  tutorial
//
//  Created by CSB313CignaFL13 on 2/11/14.
//  Copyright (c) 2014 lamesauce. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "Logo.h"
#import "Menu.h"
#import "MovieViewController.h"

@import AVFoundation;


@interface ViewController ()

@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@end


@implementation ViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    if(!skView.scene){
        //skView.showsFPS=YES;
        //skView.showsNodeCount=YES;
        
        SKScene * scene = [Logo sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        [skView presentScene:scene];
    }
}

- (BOOL)shouldAutorotate
{
    // Return YES for supported orientations
        return YES;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
