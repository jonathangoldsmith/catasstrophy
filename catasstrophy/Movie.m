//
//  Movie.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/26/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "Movie.h"
#import "Menu.h"
#import "Tutorial.h"

@interface Movie ()
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic) AVPlayerItem *playerItem;
@property (nonatomic) AVPlayer *player;
@end

@implementation Movie


-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        //background
        /*self.background =[SKSpriteNode spriteNodeWithImageNamed:@"nest_640x1136.png"];
         self.background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
         SKAction * rotate = [SKAction rotateByAngle:3*3.14/2 duration:0];
         [self scaleSpriteNode:self.background scaleRatio:0.5];
         self.background.name = @"logo";
         [self.background runAction:rotate];
         [self addChild:self.background];*/
        
        /*SKVideoNode *vid1 = [SKVideoNode videoNodeWithVideoFileNamed:@"game_intro.mov"];
         vid1.position = CGPointMake(160, 180);
         [self addChild:vid1];
         [vid1 play];
         */
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *moviePath = [bundle pathForResource:@"game_intro" ofType:@"mov"];
        NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
        [self loadData];
        MPMoviePlayerController *controller = [[MPMoviePlayerController alloc]initWithContentURL:movieURL];
        self.moviePlayer = controller;
        self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        //self.moviePlayer.view.transform = CGAffineTransformConcat(self.moviePlayer.view.transform,CGAffineTransformMakeRotation(3*M_PI_2));
        UIWindow *backgroundWindow = [[UIApplication sharedApplication] keyWindow];
        [self.moviePlayer.view setFrame:backgroundWindow.frame];
        [backgroundWindow addSubview:self.moviePlayer.view];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:self.moviePlayer];
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer play];
        /*
         NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"game_intro" ofType:@"mov"];
         NSURL *introVideoURL = [NSURL fileURLWithPath:resourcePath];
         self.playerItem = [AVPlayerItem playerItemWithURL:introVideoURL];
         self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
         
         SKVideoNode *introVideo = [SKVideoNode videoNodeWithAVPlayer:self.player];
         [introVideo setSize:CGSizeMake(self.size.width, self.size.height)];
         [introVideo setPosition:self.view.center];
         [self addChild:introVideo];
         [introVideo play];
         */
        
    }
    
    return self;
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    if(highScore > 0) {
        SKScene * menu = [[Menu alloc] initWithSize:self.size];
        [self.view presentScene:menu transition:[SKTransition fadeWithDuration:.5]];
    } else {
        SKScene * tutorial = [[Tutorial alloc] initWithSize:self.size];
        [self.view presentScene:tutorial transition:[SKTransition fadeWithDuration:.5]];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(highScore > 0) {
        SKScene * menu = [[Menu alloc] initWithSize:self.size];
        [self.view presentScene:menu transition:[SKTransition fadeWithDuration:.5]];
    } else {
        SKScene * tutorial = [[Tutorial alloc] initWithSize:self.size];
        [self.view presentScene:tutorial transition:[SKTransition fadeWithDuration:.5]];
    }
}

- (void)loadData
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    highScore = [defaults integerForKey:@"highScore"];
}

@end
