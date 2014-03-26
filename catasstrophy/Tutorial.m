//
//  Tutorial.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/25/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "Tutorial.h"
#import "Menu.h"

@interface Tutorial()
@property (nonatomic) SKSpriteNode * background;
@property (nonatomic) SKSpriteNode * menu;
@end

@implementation Tutorial

- (void)scaleSpriteNode:(SKSpriteNode *)sprite scaleRatio:(float)scale
{
    sprite.xScale = scale;
    sprite.yScale = scale;
}

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        //background
        self.background =[SKSpriteNode spriteNodeWithImageNamed:@"tutorial.png"];
        self.background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self scaleSpriteNode:self.background scaleRatio:0.5];
        [self addChild:self.background];
        
        //return to menu button
        self.menu = [SKSpriteNode spriteNodeWithImageNamed:@"return_menu.png"];
        [self scaleSpriteNode:self.menu scaleRatio:0.5];
        self.menu.position = CGPointMake(70, 280);
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
    
    //pressed menu button
    if ([node.name isEqualToString:@"menuButton"]) {
        SKScene * menu = [[Menu alloc] initWithSize:self.size];
        [self.view presentScene:menu];
    }
}

@end
