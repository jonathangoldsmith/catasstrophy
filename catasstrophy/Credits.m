//
//  Credits.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/27/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "Credits.h"
#import "Menu.h"

@interface Credits()
@property (nonatomic) SKSpriteNode * background;
@property (nonatomic) SKSpriteNode * menu;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@end

@implementation Credits

- (void)scaleSpriteNode:(SKSpriteNode *)sprite scaleRatio:(float)scale
{
    sprite.xScale = scale*self.size.width/568;
    sprite.yScale = scale*self.size.height/320;
}

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        //background
        self.background =[SKSpriteNode spriteNodeWithImageNamed:@"credits.png"];
        self.background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self scaleSpriteNode:self.background scaleRatio:0.5];
        [self addChild:self.background];
        
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
    [self.backgroundMusicPlayer stop];
    SKScene * menu = [[Menu alloc] initWithSize:self.size];
    [self.view presentScene:menu transition:[SKTransition fadeWithDuration:.5]];
}



@end
