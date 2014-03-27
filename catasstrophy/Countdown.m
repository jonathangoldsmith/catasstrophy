//
//  Countdown.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/27/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "Countdown.h"
#import "MyScene.h"

@interface Countdown() <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) SKSpriteNode * cat;
@property (nonatomic) SKSpriteNode * aim;
@property (nonatomic) SKSpriteNode * chaosBarBackground;
@property (nonatomic) SKSpriteNode * chaosBarCharger;
@property (nonatomic) SKSpriteNode * shootingBarBackground;
@property (nonatomic) SKSpriteNode * shootingBarBackgroundWhenClicked;
@property (nonatomic) SKSpriteNode * shootingBarCharger;
@property (nonatomic) SKLabelNode* timerLabel;
@property (nonatomic) SKLabelNode* countdownLabel;
@property (nonatomic) CGRect table;
@property (nonatomic) float chaosBarWidth;
@property (nonatomic) float dogBarHeight;
@property (nonatomic) NSInteger count;
@end
@implementation Countdown

//for scaling sprites
- (void)scaleSpriteNode:(SKSpriteNode *)sprite scaleRatio:(float)scale
{
    sprite.xScale = scale;
    sprite.yScale = scale;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.table = CGRectMake(tableCornerX, tableCornerY, tableWidth, tableHeight);
        
        //background
        SKSpriteNode *background =[SKSpriteNode spriteNodeWithImageNamed:@"play_area.png"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self scaleSpriteNode:background scaleRatio:0.5];
        [self addChild:background];
        
        //player
        self.player=[SKSpriteNode spriteNodeWithImageNamed:@"onion.png"];
        self.player.position=CGPointMake(CGRectGetMidX(self.table)-self.player.size.width/6,CGRectGetHeight(self.frame)-self.player.size.height/4);
        [self scaleSpriteNode:self.player scaleRatio:0.4];
        [self addChild:self.player];
        
        //chaos bar/aimer/timer/cat/
        [self initializeBars];
        [self initializeAimer];
        [self initializeTimer];
        [self initializeCat];
        
        self.count=3;
        [self countdown];
    }
    return self;
}

-(void)initializeBars
{
    self.chaosBarBackground=[SKSpriteNode spriteNodeWithImageNamed:@"chaos_filled.png"];
    [self scaleSpriteNode:self.chaosBarBackground scaleRatio:0.5];
    self.chaosBarBackground.position=CGPointMake(tableWidth - 40, tableHeight + self.chaosBarBackground.size.height/2);
    [self addChild:self.chaosBarBackground];
    
    self.chaosBarCharger=[SKSpriteNode spriteNodeWithImageNamed:@"chaos_inner.png"];
    [self scaleSpriteNode:self.chaosBarCharger scaleRatio:0.5];
    self.chaosBarCharger.anchorPoint = CGPointMake(1,0.5);
    self.chaosBarCharger.position=CGPointMake(546,284);
    self.chaosBarWidth = self.chaosBarCharger.size.width;
    [self addChild:self.chaosBarCharger];
    
    self.shootingBarBackgroundWhenClicked=[SKSpriteNode spriteNodeWithImageNamed:@"dogbar_clicked.png"];
    [self scaleSpriteNode:self.shootingBarBackgroundWhenClicked scaleRatio:0.5];
    self.shootingBarBackgroundWhenClicked.position=CGPointMake(tableWidth + self.shootingBarBackgroundWhenClicked.size.width/1.5, tableHeight/2 + 5);
    [self addChild:self.shootingBarBackgroundWhenClicked];
    SKAction * fadeOutBarInitially = [SKAction fadeOutWithDuration:0];
    [self.shootingBarBackgroundWhenClicked runAction:[SKAction sequence:@[fadeOutBarInitially]]];
    
    self.shootingBarBackground=[SKSpriteNode spriteNodeWithImageNamed:@"dogbar.png"];
    [self scaleSpriteNode:self.shootingBarBackground scaleRatio:0.5];
    self.shootingBarBackground.position=CGPointMake(tableWidth + self.shootingBarBackground.size.width/1.5, tableHeight/2 + 5);
    [self addChild:self.shootingBarBackground];
    
    self.shootingBarCharger=[SKSpriteNode spriteNodeWithImageNamed:@"dogbar_inner.png"];
    [self scaleSpriteNode:self.shootingBarCharger scaleRatio:0.5];
    self.shootingBarCharger.anchorPoint = CGPointMake(0.5,1);
    self.shootingBarCharger.position=CGPointMake(512.4,259);
    self.dogBarHeight = self.shootingBarCharger.size.height;
    [self addChild:self.shootingBarCharger];
    
}

-(void)initializeAimer
{
    self.aim=[SKSpriteNode spriteNodeWithImageNamed:@"target.png"];
    self.aim.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetHeight(self.table));
    [self scaleSpriteNode:self.aim scaleRatio:0.8];
    
    [self addChild:self.aim];
}

-(void)initializeTimer
{
    self.timerLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
    self.timerLabel.fontSize = 15;
    self.timerLabel.fontColor = [SKColor redColor];
    self.timerLabel.text = [NSString stringWithFormat:@"Time: %i", 0];
    self.timerLabel.position = CGPointMake(self.timerLabel.frame.size.width, self.table.size.height + self.timerLabel.frame.size.height*2);
    
    [self addChild:self.timerLabel];
}

- (void)initializeCat
{
    
    self.cat = [SKSpriteNode spriteNodeWithImageNamed:@"cat_0.png"];
    
    self.cat.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetMidY(self.table));
    [self scaleSpriteNode:self.cat scaleRatio:0.25];
    
    [self addChild:self.cat];
}

-(void)increment:(NSTimer*)thing{
    SKAction * fadeCountdown = [SKAction fadeOutWithDuration:1];
    SKAction * unfadeCountdown = [SKAction fadeInWithDuration:0];
    
    if(self.count<1) {
        self.countdownLabel.text = [NSString stringWithFormat:@"GO!"];
        SKScene * game = [[MyScene alloc] initWithSize:self.size];
        [self.view presentScene:game transition:[SKTransition fadeWithDuration:0]];
    }else {
        self.countdownLabel.text = [NSString stringWithFormat:@"%li", (long)self.count];
    }
    
    [self.countdownLabel runAction:[SKAction sequence:@[unfadeCountdown, fadeCountdown]]];
    self.count--;
}

-(void)countdown
{
    self.countdownLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
    self.countdownLabel.fontSize = 50;
    self.countdownLabel.fontColor = [SKColor blueColor];
    self.countdownLabel.text = [NSString stringWithFormat:@""];
    self.countdownLabel.position = CGPointMake(CGRectGetMidX(self.table), CGRectGetMidY(self.table));
    [self addChild:self.countdownLabel];
    
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(increment:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(increment:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(increment:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(increment:) userInfo:nil repeats:NO];
    
    
    
}
@end


