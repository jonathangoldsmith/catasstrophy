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
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

// A flag indicating whether the Game Center features can be used after a user has been authenticated.
@property (nonatomic) BOOL gameCenterEnabled;

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
        highScore = 0;
        [self LoadData];
        if(score>highScore){
            highScore = score;
            [self SaveData];
        }
        
        self.highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.highScoreLabel.fontSize = 30;
        self.highScoreLabel.fontColor = Rgb2UIColor(255, 150, 50);
        self.highScoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)highScore];
        self.highScoreLabel.position = CGPointMake(480*self.size.width/568, self.highScoreLabel.frame.size.height*2*self.size.height/320);
        self.highScoreLabel.name = @"highScoreLabel";//how the node is identified later

        [self addChild:self.highScoreLabel];
        
        //replay button
        
        self.replay = [SKSpriteNode spriteNodeWithImageNamed:@"gg_cat.png"];
        [self scaleSpriteNode:self.replay scaleRatio:0.5];
        self.replay.position = CGPointMake(self.background.size.width/2, self.background.size.height/2);
        self.replay.name = @"replayButton";//how the node is identified later
        [self addChild:self.replay];
        
        //self.replayClicked = [SKSpriteNode spriteNodeWithImageNamed:@"gg_cat2.png"];
        //[self scaleSpriteNode:self.replayClicked scaleRatio:0.6];
        //self.replayClicked.position = CGPointMake(self.background.size.width/2, self.background.size.height/2);
        //[self addChild:self.replayClicked];
        
        //return to menu button
        self.menu = [SKSpriteNode spriteNodeWithImageNamed:@"return_menu.png"];
        [self scaleSpriteNode:self.menu scaleRatio:0.5];
        self.menu.position = CGPointMake(self.background.size.width/2, self.background.size.height/2-130);
        self.menu.name = @"menuButton";//how the node is identified later
        [self addChild:self.menu];

        
        [self authenticateLocalPlayer];
        _leaderboardIdentifier = @"Scores";
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
        score.value = highScore;
        
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];

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
    else if ([node.name isEqualToString:@"highScoreLabel"]) {
        [self.backgroundMusicPlayer stop];
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
    [defaults setInteger:highScore forKey:@"highScore"];
    [defaults synchronize];
    
}

-(IBAction)LoadData
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    highScore = [defaults integerForKey:@"highScore"];
    self.highScoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)highScore];
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
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}


- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController {
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}@end

