//
//  GameOverScreen.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 2/25/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "GameOverScreen.h"
#import "MyScene.h"
#import "Menu.h"
#import "ViewController.h"
#import "Countdown.h"
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface GameOverScreen() <GKGameCenterControllerDelegate>

@property (nonatomic) SKSpriteNode * background;
@property (nonatomic) SKLabelNode * scoreText;
@property (nonatomic) SKLabelNode * highScoreLabel;
@property (nonatomic) SKSpriteNode * replay;
@property (nonatomic) SKSpriteNode * menu;
@property (nonatomic) SKSpriteNode * replayClicked;
@property (nonatomic) SKSpriteNode * leaderboard;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (nonatomic) NSInteger highScore;

// This property stores the default leaderboard's identifier.
@property (nonatomic, strong) NSString *leaderboardIdentifier;

@end
@implementation GameOverScreen

//for scaling sprites
- (void)scaleSpriteNode:(SKSpriteNode *)sprite scaleRatio:(float)scale
{
    sprite.xScale = scale*self.size.width/568;
    sprite.yScale = scale*self.size.height/320;
}


-(id)initWithSize:(CGSize)size score:(NSInteger)score {
    if (self = [super initWithSize:size]) {
        
        //background
        self.background =[SKSpriteNode spriteNodeWithImageNamed:@"game_over.png"];
        self.background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self scaleSpriteNode:self.background scaleRatio:0.5];
        [self addChild:self.background];
        
        
        //for the background music
        NSError *error;
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"Game Over Symphony" withExtension:@"mp3"];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer prepareToPlay];
        [self.backgroundMusicPlayer play];
        
        //score
        self.scoreText = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.scoreText.fontSize = 30;
        self.scoreText.fontColor = Rgb2UIColor(255, 150, 50);
        self.scoreText.text = [NSString stringWithFormat:@"%ld", (long)score];
        self.scoreText.position = CGPointMake(self.scoreText.frame.size.width*3.5*self.size.width/568, self.scoreText.frame.size.height*2*self.size.height/320);
        [self addChild:self.scoreText];
        
        //high score
        self.highScore = 0;
        [self LoadData];
        if(score>self.highScore){
            self.highScore = score;
            [self SaveData];
        }
        
        self.highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.highScoreLabel.fontSize = 30;
        self.highScoreLabel.fontColor = Rgb2UIColor(255, 150, 50);
        self.highScoreLabel.text = [NSString stringWithFormat:@"%lu", self.highScore];
        self.highScoreLabel.position = CGPointMake(480*self.size.width/568, self.highScoreLabel.frame.size.height*2*self.size.height/320);
        self.highScoreLabel.name = @"highScoreLabel";//how the node is identified later

        [self addChild:self.highScoreLabel];
        
        //replay button
        self.replay = [SKSpriteNode spriteNodeWithImageNamed:@"gg_cat.png"];
        [self scaleSpriteNode:self.replay scaleRatio:0.5];
        self.replay.position = CGPointMake(self.background.size.width/2, self.background.size.height/2);
        self.replay.name = @"replayButton";//how the node is identified later
        [self addChild:self.replay];
        
        //return to menu button
        self.menu = [SKSpriteNode spriteNodeWithImageNamed:@"return_menu.png"];
        [self scaleSpriteNode:self.menu scaleRatio:0.5];
        self.menu.position = CGPointMake(self.background.size.width/2, self.background.size.height/2-130);
        self.menu.name = @"menuButton";//how the node is identified later
        [self addChild:self.menu];

        
        //leaderboard
        self.leaderboard = [SKSpriteNode spriteNodeWithImageNamed:@"leaderboard.png"];
        [self scaleSpriteNode:self.leaderboard scaleRatio:0.5];
        self.leaderboard.position = CGPointMake(self.background.size.width - 50, self.background.size.height/2 - 20);
        self.leaderboard.name = @"leaderboard";//how the node is identified later
        [self addChild:self.leaderboard];

        [self authenticateLocalPlayer];

    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"replayButton"]) {
        //[NSThread sleepForTimeInterval:1];
        [self.backgroundMusicPlayer stop];
        SKScene * game = [[Countdown alloc] initWithSize:self.size];
        [self.view presentScene:game];
    }
    else if ([node.name isEqualToString:@"menuButton"]) {
        [self.backgroundMusicPlayer stop];
        SKScene * menu = [[Menu alloc] initWithSize:self.size];
        [self.view presentScene:menu];
    }
    else if ([node.name isEqualToString:@"leaderboard"]) {
        [self.backgroundMusicPlayer stop];
        
        _leaderboardIdentifier = @"Scores";
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
        score.value = self.highScore;
        
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
        
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        if (gameCenterController != nil)
        {
            gameCenterController.gameCenterDelegate = self;
            gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
            UIViewController *vc = self.view.window.rootViewController;
            [vc presentViewController: gameCenterController animated: YES completion:nil];
        }
    }
    
}

-(IBAction)SaveData
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.highScore forKey:@"highScore"];
    [defaults synchronize];
    
}

-(IBAction)LoadData
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    self.highScore = [defaults integerForKey:@"highScore"];
    self.highScoreLabel.text = [NSString stringWithFormat:@"%lu", self.highScore];
}

-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            UIViewController *vc = self.view.window.rootViewController;
            [vc presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardIdentifier];
                        score.value = self.highScore;
                        
                        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
                            if (error != nil) {
                                NSLog(@"%@", [error localizedDescription]);
                            }
                        }];
                    }
                }];
            }
        }
    };
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController {
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

@end
