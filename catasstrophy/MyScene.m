//
//  MyScene.m
//  tutorial
//
//  Created by CSB313CignaFL13 on 2/11/14.
//  Copyright (c) 2014 NESTGaming. All rights reserved.
//

#import "MyScene.h"
#import "math.h"


@interface MyScene()
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) SKSpriteNode * cat;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval totalTimeInterval;
@property (nonatomic) NSInteger currentWall;
@end

@implementation MyScene

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.backgroundColor=[SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        self.player=[SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position=CGPointMake(245,280);
        self.cat=[SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.cat.position=CGPointMake(245,140);
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        self.currentWall = 0;
        [self addChild:self.player];
        [self addChild:self.cat];
        [self updateCat];
    }
    return self;
}

- (void)updateCat {
    //determine wall to send cat towards that isnt current wall
    NSInteger r = self.currentWall;
    while(self.currentWall == r) {
        r = arc4random_uniform(4);
    }
    self.currentWall = r;
    
    
    // Determine range to send the cat
    int minY = self.cat.size.height / 2;
    int maxY = self.frame.size.height - self.cat.size.height / 2;
    int rangeY = maxY - minY;
    int minX = self.cat.size.width / 2;
    int maxX = self.frame.size.width - self.cat.size.width / 2;
    int rangeX = maxX - minX;
    int actualX, actualY;
    
    //Determine the new location to send cat based on new wall
    switch(self.currentWall) {
            case 0: actualY = maxY;
                    actualX = (arc4random() % rangeX) + minX;
                    break;
            case 1: actualX = minX;
                    actualY = (arc4random() % rangeY) + minY;
                    break;
            case 2: actualY = minY;
                    actualX = (arc4random() % rangeX) + minX;
                    break;
            case 3: actualX = maxX;
                    actualY = (arc4random() % rangeY) + minY;
                    break;
            default: actualX = self.cat.position.x;
                    actualY = self.cat.position.y;
                    break;
    }
        // Determine speed of the cat
    //int minDuration = 0.2;
    //int maxDuration = log(self.totalTimeInterval);
    //int rangeDuration = maxDuration - minDuration;
    //int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    //Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, actualY) duration:2];
    //SKAction * actionMoveDone = [SKAction actionMov];
    
    [self.cat runAction:[SKAction sequence:@[actionMove]]];
    
}


- (void)addItem {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    // Determine where to spawn the monster along the Y axis
    int minY = monster.size.height / 2;
    int maxY = self.frame.size.height - monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    int minX = monster.size.width / 2;
    int maxX = self.frame.size.width - monster.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(actualX, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    //int minDuration = 2.0;
    //int maxDuration = 4.0;
    //int rangeDuration = maxDuration - minDuration;
    //int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    //SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    //SKAction * actionMoveDone = [SKAction removeFromParent];
    //[monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.position = self.player.position;
    
    // Determine offset of location to projectile
    CGPoint offset = rwSub(location, projectile.position);
    
    // Bail out if you are shooting up
    if (offset.y >= 0) return;
    
    // OK to add now - we've double checked position
    [self addChild:projectile];
    
    // Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    // Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    self.totalTimeInterval += timeSinceLast;
    
    // For evey two seconds add another item/cat
    if (self.lastSpawnTimeInterval > 2) {
        self.lastSpawnTimeInterval = 0;
        //[self addItem];
        [self updateCat];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

@end
