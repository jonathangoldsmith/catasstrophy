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
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface GameOverScreen()
@property (nonatomic) SKSpriteNode * background;
@property (nonatomic) SKLabelNode * scoreText;
@property (nonatomic) SKSpriteNode * replay;
@property (nonatomic) SKSpriteNode * menu;
@property (nonatomic) SKSpriteNode * replayClicked;
@end
@implementation GameOverScreen

//for scaling sprites
- (void)scaleSpriteNode:(SKSpriteNode *)sprite scaleRatio:(float)scale
{
    sprite.xScale = scale;
    sprite.yScale = scale;
}

-(id)initWithSize:(CGSize)size score:(NSInteger)score {
    if (self = [super initWithSize:size]) {
        
        //background
        self.background =[SKSpriteNode spriteNodeWithImageNamed:@"game_over.png"];
        self.background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self scaleSpriteNode:self.background scaleRatio:0.5];
        [self addChild:self.background];
        
        //score
        self.scoreText = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        self.scoreText.fontSize = 30;
        self.scoreText.fontColor = Rgb2UIColor(255, 150, 50);
        self.scoreText.text = [NSString stringWithFormat:@"%ld", (long)score];
        self.scoreText.position = CGPointMake(self.scoreText.frame.size.width*3.5, self.scoreText.frame.size.height*2);
        [self addChild:self.scoreText];
        
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

    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //the only button on the screen is clicked
    if ([node.name isEqualToString:@"replayButton"]) {
        //[NSThread sleepForTimeInterval:1];
        SKScene * game = [[MyScene alloc] initWithSize:self.size];
        [self.view presentScene:game];
    }
    else if ([node.name isEqualToString:@"menuButton"]) {
        SKScene * menu = [[Menu alloc] initWithSize:self.size];
        [self.view presentScene:menu];
    }
}

@end

