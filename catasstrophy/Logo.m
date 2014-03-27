//
//  Logo.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/25/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "Logo.h"
#import "Menu.h"

@interface Logo()
@property (nonatomic) SKSpriteNode * background;
@end

@implementation Logo

- (void)scaleSpriteNode:(SKSpriteNode *)sprite scaleRatio:(float)scale
{
    sprite.xScale = scale;
    sprite.yScale = scale;
}

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        //background
        self.background =[SKSpriteNode spriteNodeWithImageNamed:@"nest_640x1136.png"];
        self.background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        SKAction * rotate = [SKAction rotateByAngle:3*3.14/2 duration:0];
        [self scaleSpriteNode:self.background scaleRatio:0.5];
        self.background.name = @"logo";
        [self.background runAction:rotate];
        [self addChild:self.background];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //the only button on the screen is clicked
    if ([node.name isEqualToString:@"logo"]) {
        SKScene * menu = [[Menu alloc] initWithSize:self.size];
        [self.view presentScene:menu transition:[SKTransition fadeWithDuration:.5]];
    }
}

@end
