//
//  MyScene.m
//  tutorial
//
//  Created by CSB313CignaFL13 on 2/11/14.
//  Copyright (c) 2014 NESTGaming. All rights reserved.
//

#import "MyScene.h"
#import "math.h"
#import "GameOverScreen.h"

@interface MyScene() <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) SKSpriteNode * cat;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval totalTimeInterval;
@property (nonatomic) NSInteger currentWall;
@property (nonatomic) int choasCount;
@end

@implementation MyScene


//various physics functions
static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t catCategory        =  0x1 << 2;
static const uint32_t itemCategory        =  0x1 << 1;

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
        
        SKSpriteNode *background =[SKSpriteNode spriteNodeWithImageNamed:@"play_area.png"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        background.xScale = 0.5;
        background.yScale = 0.5;
        [self addChild:background];
        
        //Set choas to 0, when it hits 100, game over
        self.choasCount = 0;
        
        //Set up the physics
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        //add player, cat, items, and start cat movement
        self.player=[SKSpriteNode spriteNodeWithImageNamed:@"cat_0.png"];
        self.player.position=CGPointMake(CGRectGetMidX(self.frame),CGRectGetHeight(self.frame)-40);
        [self addChild:self.player];
        for (int i=0;i<5;i++){
            [self addItem];}
        [self initializeCat];
        [self updateCat];
    }
    return self;
}

- (void)initializeCat {
    
    self.cat=[SKSpriteNode spriteNodeWithImageNamed:@"thing_catbug.png"];
    self.cat.position=CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    
    //Current wall for the cat to head towards
    self.currentWall = 0;

    //cat phsysics
    self.cat.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.cat.size];
    self.cat.physicsBody.dynamic = YES;
    self.cat.physicsBody.categoryBitMask = catCategory;
    self.cat.physicsBody.contactTestBitMask = projectileCategory;
    self.cat.physicsBody.collisionBitMask = 0;
    [self addChild:self.cat];
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
    SKSpriteNode * item = [SKSpriteNode spriteNodeWithImageNamed:@"thing_eraser.png"];
    
    // Determine where to spawn the monster along the Y axis
    int minY = item.size.height / 2;
    int maxY = self.frame.size.height - item.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    int minX = item.size.width / 2;
    int maxX = self.frame.size.width - item.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the X/Y axis as calculated above
    item.position = CGPointMake(actualX, actualY);
    
    
    //set up physics of item
    item.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:item.size];
    item.physicsBody.dynamic = YES;
    item.physicsBody.categoryBitMask = itemCategory;
    item.physicsBody.contactTestBitMask = catCategory;
    item.physicsBody.collisionBitMask = 0;
    item.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:item];
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //music for on hit
    //[self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    
    // Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"thing_mouse.png"];
    projectile.position = self.player.position;
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = catCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;

    
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

- (void)projectile:(SKSpriteNode *)projectile didCollideWithCat:(SKSpriteNode *)cat {
    NSLog(@"Hit");
    [projectile removeFromParent];
    
    if(self.choasCount > 0)
    self.choasCount--;
    NSLog(@"%d",self.choasCount);
    
    //on hit, cat turns transparent for a quarter second
    //SKAction * transparentCat = [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:1];
    SKAction * transparentCat = [SKAction colorizeWithColorBlendFactor:0.5 duration:0.25];
    SKAction * normalCat = [SKAction colorizeWithColorBlendFactor:0.0 duration:0.25];
    [cat runAction:[SKAction sequence:@[transparentCat, normalCat]]];
    
    //set cat to go new random direction
    self.currentWall = 5;
    [self updateCat];
}

- (void)item:(SKSpriteNode *)item didCollideWithCat:(SKSpriteNode *)cat {
    NSLog(@"Item Hit");
    self.choasCount = self.choasCount + 10;
    NSLog(@"%d",self.choasCount);
    if (self.choasCount >= 100) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScreen alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition: reveal];
    }
    
    // Determine offset of item to the cat
    CGPoint offset = rwSub(item.position, cat.position);
    
    // Get the direction of where to shoot the item
    CGPoint direction = rwNormalize(offset);
    
    // Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, item.position);
    
    // Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [item runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    //set cat to go new random direction
    self.currentWall = 5;
    [self updateCat];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & catCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithCat:(SKSpriteNode *) secondBody.node];
    } else if (((firstBody.categoryBitMask & itemCategory) != 0 &&
                (secondBody.categoryBitMask & catCategory) != 0)) {
        [self item:(SKSpriteNode *) firstBody.node didCollideWithCat:(SKSpriteNode *) secondBody.node];
    }
}


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    self.totalTimeInterval += timeSinceLast;
    
    // For evey two seconds add another item/ update cat
    if (self.lastSpawnTimeInterval > 2) {
        self.lastSpawnTimeInterval = 0;
        [self addItem];
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
