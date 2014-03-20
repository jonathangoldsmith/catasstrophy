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

static inline CGPoint rwAdd(CGPoint a, CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b)
{
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a)
{
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a)
{
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

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
        
        self.motionManager = [[CMMotionManager alloc] init];
        [self.motionManager startAccelerometerUpdates];
        self.table = CGRectMake(tableCornerX, tableCornerY, tableWidth, tableHeight);
        self.updateSpeed = startSpeed;
        self.choasCount = 0; //Set choas to 0, when it hits 100, game over
        
        //Set up the world physics
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.table];
        self.physicsBody.collisionBitMask = aimCategory;
        self.physicsWorld.contactDelegate = self;
        
        //background
        SKSpriteNode *background =[SKSpriteNode spriteNodeWithImageNamed:@"play_area.png"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self scaleSpriteNode:background scaleRatio:0.5];
        [self addChild:background];
        
        //player
        self.player=[SKSpriteNode spriteNodeWithImageNamed:@"thing_lamp.png"];
        self.player.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetHeight(self.frame)-self.player.size.height/6);
        [self scaleSpriteNode:self.player scaleRatio:0.4];
        [self addChild:self.player];
        
        [self initializeAimer];
        [self initializeTimer];
        [self initializeCat];
        [self updateCat];
        for (int i=0;i<5;i++)
        {
            [self addItem];
        }
        
    }
    return self;
}

//updater to the accelerometer to chage the aimer
-(void)processUserMotionForUpdate:(NSTimeInterval)currentTime
{
    CMAccelerometerData* data = self.motionManager.accelerometerData;
    if (fabs(data.acceleration.y) > 0.2)
    {
        [self.aim.physicsBody applyForce:CGVectorMake(400.0 * data.acceleration.y, 0)];
    }
    if (fabs(data.acceleration.x) > 0.2)
    {
        [self.aim.physicsBody applyForce:CGVectorMake(0, -400.0 * data.acceleration.x)];
    }
}

- (void)initializeAimer
{
    self.aim=[SKSpriteNode spriteNodeWithImageNamed:@"projectile.png"];
    self.aim.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetHeight(self.table));
    [self scaleSpriteNode:self.aim scaleRatio:0.5];
    
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
    [self scaleSpriteNode:self.cat scaleRatio:0.5];
    
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

- (void)updateCat
{
    //determine wall to send cat towards that isnt current wall
    NSInteger r = self.currentWall;
    while(self.currentWall == r)
    {
        r = arc4random_uniform(4);
    }
    self.currentWall = r;
    
    int catXDestination, catYDestination;
    //Determine the new location to send cat based on new wall
    switch(self.currentWall) {
            case 0: catYDestination = tableHeight-tableCornerY;
                    catXDestination = (arc4random() % tableWidth) + tableCornerX;
                    break;
            case 1: catXDestination = tableCornerX;
                    catYDestination = (arc4random() % tableHeight) + tableCornerY;
                    break;
            case 2: catYDestination = tableCornerY;
                    catXDestination = (arc4random() % tableWidth) + tableCornerX;
                    break;
            case 3: catXDestination = tableWidth-tableCornerX;
                    catYDestination = (arc4random() % tableHeight) + tableCornerY;
                    break;
            default: catXDestination = self.cat.position.x;
                    catYDestination = self.cat.position.y;
                    break;
    }
    
    SKAction * actionMove = [SKAction moveTo:CGPointMake(catXDestination, catYDestination) duration:(self.updateSpeed/100)];
    
    [self.cat runAction:[SKAction sequence:@[actionMove]]];
    
}


- (void)addItem
{
    // Create item to place on table
    SKSpriteNode * item = [SKSpriteNode spriteNodeWithImageNamed:@"thing_eraser.png"];
    [self scaleSpriteNode:item scaleRatio:0.5];
    
    // Determine where to spawn the item on the table
    int itemYPostion = (arc4random() %(tableHeight - 4*tableCornerY)) + tableCornerY + item.size.height/2;
    int itemXPosition = (arc4random() %(tableWidth - 3*tableCornerX)) + tableCornerX + item.size.width/2;
    item.position = CGPointMake(itemXPosition,itemYPostion);
    
    //set up physics of item
    item.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:item.size];
    item.physicsBody.dynamic = YES;
    item.physicsBody.categoryBitMask = itemCategory;
    item.physicsBody.contactTestBitMask = catCategory;
    item.physicsBody.collisionBitMask = !aimCategory;
    item.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:item];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    //music for on hit
    //[self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    
    // Choose one of the touches to work with
    //UITouch * touch = [touches anyObject];
    //CGPoint location = [touch locationInNode:self];
    
    CGPoint location = self.aim.position;
    
    // Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"thing_mouse.png"];
    [self scaleSpriteNode:projectile scaleRatio:0.1];
    
    //projectile physics
    projectile.position = self.player.position;
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = itemCategory;
    projectile.physicsBody.collisionBitMask = !aimCategory;;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;

    
    // Determine offset of location to projectile
    CGPoint offset = rwSub(location, projectile.position);
    
    // Bail out if shooting up
    if (offset.y >= 0) return;

    [self addChild:projectile];
    
    //get the destination and duration for the animation
    CGPoint projectileDestination = [self assetDestionation:&offset assetPosition:projectile.position];
    float animationDuration = [self getAnimationDuration];
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:projectileDestination duration:animationDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (CGPoint)assetDestionation:(CGPoint *)initialDirection assetPosition:(CGPoint)assetPossition
{
    // Get the direction of where to shoot the item
    CGPoint direction = rwNormalize(*initialDirection);
    // Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, self.frame.size.width*2);
    return rwAdd(shootAmount, assetPossition);
}

-(float)getAnimationDuration
{
    float velocity = 480.0/1.0;
    return self.size.width / velocity;
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
    
    CGPoint itemDestination = [self assetDestionation:&offset assetPosition:item.position];
    float animationDuration = [self getAnimationDuration];
    SKAction * actionMove = [SKAction moveTo:itemDestination duration:animationDuration];
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
    
    
    CGPoint itemDestination = [self assetDestionation:&offsetItem assetPosition:item.position];
    CGPoint projectileDestination = [self assetDestionation:&offsetProjectile assetPosition:projectile.position];
    float animationDuration = [self getAnimationDuration];

    SKAction * actionMoveItem = [SKAction moveTo:itemDestination duration:animationDuration];
    SKAction * actionMoveProjectile = [SKAction moveTo:projectileDestination duration:animationDuration];
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
    self.updateSpeed=startSpeed-self.totalTimeInterval;
    self.timerLabel.text = [NSString stringWithFormat:@"Time: %d", startSpeed-self.updateSpeed];
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

@end
