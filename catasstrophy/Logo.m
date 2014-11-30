//
//  Logo.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/25/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "Logo.h"
#import "Menu.h"
#import "Movie.h"


@interface Logo()
@property (nonatomic) SKSpriteNode * background;
@end

@implementation Logo

- (void)scaleSpriteNode:(SKSpriteNode *)sprite scaleRatio:(float)scale
{
    sprite.xScale = scale*self.size.width/568;
    sprite.yScale = scale*self.size.height/320;
}

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        //background
        self.background =[SKSpriteNode spriteNodeWithImageNamed:@"nest_logo.png"];
        self.background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self scaleSpriteNode:self.background scaleRatio:0.5];
        self.background.name = @"logo";
        [self addChild:self.background];
        [self LoadData];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(highScore > 0) {
        SKScene * menu = [[Menu alloc] initWithSize:self.size];
        [self.view presentScene:menu transition:[SKTransition fadeWithDuration:.5]];
    } else {
        SKScene * movie = [[Movie alloc] initWithSize:self.size];
        [self.view presentScene:movie transition:[SKTransition fadeWithDuration:.5]];
    }
}
-(IBAction)LoadData
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    highScore = [defaults integerForKey:@"highScore"];
}


@end
