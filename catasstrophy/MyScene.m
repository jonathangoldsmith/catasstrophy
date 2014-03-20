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
@property (nonatomic) SKSpriteNode * aim;
@property (nonatomic) SKLabelNode* timerLabel;
@property (nonatomic) CGRect table;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval totalTimeInterval;
@property (nonatomic) NSInteger currentWall;
@property (nonatomic) int choasCount;
@property (strong, nonatomic) CMMotionManager *motionManager;
@end

@implementation MyScene

@synthesize updateSpeed;

//constants
#define CONSTANT 

//various physics functions
static const uint32_t itemCategory        =  0x1 << 0;
static const uint32_t projectileCategory     =  0x1 << 1;
static const uint32_t catCategory        =  0x1 << 2;
static const uint32_t aimCategory        =  0x1 << 3;

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
        
        self.motionManager = [[CMMotionManager alloc] init];
        [self.motionManager startAccelerometerUpdates];
        
        //set table up with its dimensions
        self.table = CGRectMake(tableCornerX, tableCornerY, tableWidth, tableHeight);
        
        self.updateSpeed = startSpeed;
        
        SKSpriteNode *background =[SKSpriteNode spriteNodeWithImageNamed:@"play_area.png"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self scaleSpriteNode:background];
        [self addChild:background];
        
        //Set choas to 0, when it hits 100, game over
        self.choasCount = 0;
        
        //Set up the physics
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.table];
        self.physicsBody.collisionBitMask = aimCategory;
        self.physicsWorld.contactDelegate = self;
        
        //add player, cat, aimer, timer, items, and start cat movement
        self.player=[SKSpriteNode spriteNodeWithImageNamed:@"thing_lamp.png"];
        self.player.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetHeight(self.frame)-self.player.size.height/6);
        [self scaleSpriteNode:self.player];
        [self addChild:self.player];
        
        [self initializeAimer];
        [self initializeTimer];
        
        for (int i=0;i<5;i++){
            [self addItem];}
        [self initializeCat];
        [self updateCat];
    }
    return self;
}



-(void)processUserMotionForUpdate:(NSTimeInterval)currentTime {
    
    CMAccelerometerData* data = self.motionManager.accelerometerData;
    if (fabs(data.acceleration.y) > 0.2) {
        [self.aim.physicsBody applyForce:CGVectorMake(400.0 * data.acceleration.y, 0)];
    }
    if (fabs(data.acceleration.x) > 0.2) {
        [self.aim.physicsBody applyForce:CGVectorMake(0, -400.0 * data.acceleration.x)];
    }
}

- (void)initializeAimer {
    
    self.aim=[SKSpriteNode spriteNodeWithImageNamed:@"projectile.png"];
    self.aim.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetHeight(self.table));
    [self scaleSpriteNode:self.aim];
    //[self addChild:self.aim];
    
    //aimer phsysics
    self.aim.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.aim.frame.size];
    self.aim.physicsBody.dynamic = YES;
    self.aim.physicsBody.categoryBitMask = aimCategory;
    self.aim.physicsBody.collisionBitMask = aimCategory;
    self.aim.physicsBody.affectedByGravity = NO;
    self.aim.physicsBody.mass = 1.0;

    [self addChild:self.aim];
}

-(void)initializeTimer
{
    self.timerLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    self.timerLabel.fontSize = 15;
    self.timerLabel.fontColor = [SKColor redColor];
    self.timerLabel.text = [NSString stringWithFormat:@"Time: %i", 0];
    self.timerLabel.position = CGPointMake(self.size.width - self.timerLabel.frame.size.width/2 - 20, self.size.height - (20 + self.timerLabel.frame.size.height/2));
    [self addChild:self.timerLabel];
}

- (void)initializeCat {
    
    self.cat=[SKSpriteNode spriteNodeWithImageNamed:@"thing_catbug.png"];
    self.cat.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetMidY(self.table));
    [self scaleSpriteNode:self.cat];
    
    //Current wall for the cat to head towards
    self.currentWall = 0;

    //cat phsysics
    self.cat.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.cat.size];
    self.cat.physicsBody.dynamic = YES;
    self.cat.physicsBody.categoryBitMask = catCategory;
    self.cat.physicsBody.contactTestBitMask = projectileCategory;
    self.cat.physicsBody.collisionBitMask = !aimCategory;
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
    int maxY = self.frame.size.height - self.cat.size.height / 2 - 55;
    int rangeY = maxY - minY;
    int minX = self.cat.size.width / 2;
    int maxX = self.frame.size.width - self.cat.size.width / 2 - 95;
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
    
    //Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, actualY) duration:(self.updateSpeed/100)];
    
    [self.cat runAction:[SKAction sequence:@[actionMove]]];
    
}


- (void)addItem {
    
    // Create item to place on table
    SKSpriteNode * item = [SKSpriteNode spriteNodeWithImageNamed:@"thing_eraser.png"];
    [self scaleSpriteNode:item];
    
    
    // Determine where to spawn the item on the table
    int minY = tableCornerY;
    int maxY = self.frame.size.height - item.size.height / 2 - 55;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    int minX = item.size.width / 2;
    int maxX = self.frame.size.width - item.size.width / 2 - 95;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    item.position = CGPointMake(actualX, actualY);
    
    //set up physics of item
    item.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:item.size];
    item.physicsBody.dynamic = YES;
    item.physicsBody.categoryBitMask = itemCategory;
    item.physicsBody.contactTestBitMask = catCategory;
    item.physicsBody.collisionBitMask = !aimCategory;
    item.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:item];
    
}

- (void)scaleSpriteNode:(SKSpriteNode *)sprite {
    sprite.xScale = 0.5;
    sprite.yScale = 0.5;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //music for on hit
    //[self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    
    // Choose one of the touches to work with
    //UITouch * touch = [touches anyObject];
    //CGPoint location = [touch locationInNode:self];
    
    CGPoint location = self.aim.position;
    
    // Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"thing_mouse.png"];
    projectile.xScale = 0.2;
    projectile.yScale = 0.2;
    
    
    projectile.position = self.player.position;
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = itemCategory;
    projectile.physicsBody.collisionBitMask = !aimCategory;;
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
    
    //on hit, cat turns red for a short period second
    SKAction *pulseRed = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.05],
                                              [SKAction waitForDuration:0.05],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.05]]];

    SKAction * normalCat = [SKAction colorizeWithColorBlendFactor:0.0 duration:0.25];
    [cat runAction:[SKAction sequence:@[pulseRed, normalCat]]];
    
    //set cat to go new random direction
    self.currentWall = 5;
    [self updateCat];
}

- (void)item:(SKSpriteNode *)item didCollideWithCat:(SKSpriteNode *)cat {
    NSLog(@"Item Hit by cat");
    self.choasCount = self.choasCount + 10;
    NSLog(@"%d",self.choasCount);
    [self checkIfGameOver];
    
    // Determine offset of item to the cat
    CGPoint offset = rwSub(item.position, cat.position);
    
   CGPoint shootAmount = [self shootAmount:&offset];
    
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

- (void)item:(SKSpriteNode *)item didCollideWithProjectile:(SKSpriteNode *)projectile {
    NSLog(@"Item Hit by projectile");
    self.choasCount = self.choasCount + 3;
    NSLog(@"%d",self.choasCount);
    
    [self checkIfGameOver];
    // Determine offset of item to the cat
    CGPoint offsetItem = rwSub(item.position, projectile.position);
    CGPoint offsetProjectile = rwSub(projectile.position, item.position);
    
    CGPoint itemShootAmount = [self shootAmount:&offsetItem];
    CGPoint projectileShootAmount = [self shootAmount:&offsetProjectile];
    
    // Add the shoot amount to the current position
    CGPoint realDestItem = rwAdd(itemShootAmount, item.position);
    CGPoint realDestProjectile = rwAdd(projectileShootAmount, projectile.position);
    
    // Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMoveItem = [SKAction moveTo:realDestItem duration:realMoveDuration];
    SKAction * actionMoveProjectile = [SKAction moveTo:realDestProjectile duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [item runAction:[SKAction sequence:@[actionMoveItem, actionMoveDone]]];
    [projectile runAction:[SKAction sequence:@[actionMoveProjectile, actionMoveDone]]];
    
    //set cat to go new random direction
    self.currentWall = 5;
    [self updateCat];
}

-(void)checkIfGameOver
{
    /*if (self.choasCount >= 100) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScreen alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition: reveal];
    }*/
}

- (CGPoint)shootAmount:(CGPoint *)initialDirection {
    // Get the direction of where to shoot the item
    CGPoint direction = rwNormalize(*initialDirection);
    
    
    // Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    return shootAmount;
    
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
    
    
    if ((firstBody.categoryBitMask == projectileCategory) &&
        (secondBody.categoryBitMask == catCategory))
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithCat:(SKSpriteNode *) secondBody.node];
    } else if (((firstBody.categoryBitMask == itemCategory) &&
                (secondBody.categoryBitMask == catCategory))) {
        [self item:(SKSpriteNode *) firstBody.node didCollideWithCat:(SKSpriteNode *) secondBody.node];
    } else if (((firstBody.categoryBitMask == itemCategory) &&
                (secondBody.categoryBitMask == projectileCategory))) {
        [self item:(SKSpriteNode *) firstBody.node didCollideWithProjectile:(SKSpriteNode *) secondBody.node];
    }
}


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    self.totalTimeInterval += timeSinceLast;
    
    // For every current value of updateSpeed/100 add another item/ update cat
    if (self.lastSpawnTimeInterval > (self.updateSpeed/100)) {
        self.lastSpawnTimeInterval = 0;
        [self addItem];
        [self updateCat];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    
    [self processUserMotionForUpdate:currentTime];
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    
    
    
    // more than a second since last update, update lastUpdateTimeInterval
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    //change updateSpeed and set the timer based on the speed
    self.updateSpeed=200-self.totalTimeInterval;
    self.timerLabel.text = [NSString stringWithFormat:@"Time: %ld", 200-self.updateSpeed];
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

@end
