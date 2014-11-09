//
//  Menu.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/25/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "Menu.h"
#import "MyScene.h"
#import "Tutorial.h"
#import "MovieViewController.h"
#import "Movie.h"
#import "Countdown.h"
#import "Credits.h"

@interface Menu()
@property (nonatomic) SKSpriteNode * background;
@property (nonatomic) SKSpriteNode * play;
@property (nonatomic) SKSpriteNode * movie;
@property (nonatomic) SKSpriteNode * how;
@property (nonatomic) SKSpriteNode * credits;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@end

@implementation Menu

- (void)scaleSpriteNode:(SKSpriteNode *)sprite scaleRatio:(float)scale
{
    sprite.xScale = scale;
    sprite.yScale = scale;
}

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        //background
        self.background =[SKSpriteNode spriteNodeWithImageNamed:@"menu_bg.png"];
        self.background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self scaleSpriteNode:self.background scaleRatio:0.5];
        [self addChild:self.background];
        
        //play button
        self.play = [SKSpriteNode spriteNodeWithImageNamed:@"play_button.png"];
        [self scaleSpriteNode:self.play scaleRatio:0.5];
        self.play.position = CGPointMake(self.background.size.width/2+15, self.background.size.height/4+15);
        self.play.name = @"playButton";//how the node is identified later
        [self addChild:self.play];
        
        //play movie button
        self.movie = [SKSpriteNode spriteNodeWithImageNamed:@"playvid_button.png"];
        [self scaleSpriteNode:self.movie scaleRatio:0.5];
        self.movie.position = CGPointMake(self.background.size.width/2+200, self.background.size.height/4+40);
        self.movie.name = @"movieButton";//how the node is identified later
        [self addChild:self.movie];
        
        //how to play button
        self.how = [SKSpriteNode spriteNodeWithImageNamed:@"how_to_play.png"];
        [self scaleSpriteNode:self.how scaleRatio:0.5];
        self.how.position = CGPointMake(self.background.size.width-90, self.background.size.height-290);
        self.how.name = @"howButton";//how the node is identified later
        [self addChild:self.how];
        
        //credits
        self.credits = [SKSpriteNode spriteNodeWithImageNamed:@"credits_button.png"];
        [self scaleSpriteNode:self.credits scaleRatio:0.5];
        self.credits.position = CGPointMake(self.background.size.width-70, self.background.size.height-37);
        self.credits.name = @"creditsButton";//how the node is identified later
        [self addChild:self.credits];
        
        //for the background music
         NSError *error;
         NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"Menu" withExtension:@"mp3"];
         self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
         self.backgroundMusicPlayer.numberOfLoops = -1;
         [self.backgroundMusicPlayer prepareToPlay];
         [self.backgroundMusicPlayer play];
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //pressed play button
    if ([node.name isEqualToString:@"playButton"]) {
        [self.backgroundMusicPlayer stop];
        SKScene * game = [[Countdown alloc] initWithSize:self.size];
        [self.view presentScene:game transition:[SKTransition fadeWithDuration:.5]];
    }
    
    //pressed movie button
    else if ([node.name isEqualToString:@"movieButton"]) {
        [self.backgroundMusicPlayer stop];
        SKScene * movie = [[Movie alloc] initWithSize:self.size];
        [self.view presentScene:movie transition:[SKTransition fadeWithDuration:.5]];
    }
    
    else if ([node.name isEqualToString:@"howButton"]) {
        [self.backgroundMusicPlayer stop];
        SKScene * tutorial = [[Tutorial alloc] initWithSize:self.size];
        [self.view presentScene:tutorial transition:[SKTransition fadeWithDuration:.5]];
    }
    
    else if ([node.name isEqualToString:@"creditsButton"]) {
        [self.backgroundMusicPlayer stop];
        SKScene * credits = [[Credits alloc] initWithSize:self.size];
        [self.view presentScene:credits transition:[SKTransition fadeWithDuration:.5]];
    }
}

@end
