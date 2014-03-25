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
#import "DogSpriteNode.h"

@interface MyScene() <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) SKSpriteNode * cat;
@property NSArray * catWalkingFramesLeft;
@property NSArray * catWalkingFramesRight;
@property NSArray * catFlippingFramesLeft;
@property NSArray * catFlippingFramesRight;
@property NSArray * catHitFramesLeft;
@property NSArray * catHitFramesRight;
@property (nonatomic) SKSpriteNode * aim;
@property (nonatomic) SKSpriteNode * chaosBarBackground;
@property (nonatomic) SKSpriteNode * chaosBarCharger;
@property (nonatomic) SKSpriteNode * shootingBarBackground;
@property (nonatomic) SKSpriteNode * shootingBarBackgroundWhenClicked;
@property (nonatomic) SKSpriteNode * shootingBarCharger;
@property (nonatomic) SKLabelNode* timerLabel;
@property (nonatomic) SKLabelNode* countdownLabel;
@property (nonatomic) CGRect table;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval totalTimeInterval;
@property (nonatomic) BOOL shootingBool;
@property (nonatomic) NSInteger currentWall;
@property (nonatomic) double chaosCount;
@property (nonatomic) double chaosBarWidth;
@property (nonatomic) double dogBarHeight;
@property (nonatomic) double beginningShotTime;
@property (strong, nonatomic) CMMotionManager *motionManager;
@end

@implementation MyScene

@synthesize updateSpeed;

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
        self.chaosCount = 0; //Set choas to 0, when it hits 100, game over
        
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
        self.player=[SKSpriteNode spriteNodeWithImageNamed:@"onion.png"];
        self.player.position=CGPointMake(CGRectGetMidX(self.table)-self.player.size.width/6,CGRectGetHeight(self.frame)-self.player.size.height/4);
        [self scaleSpriteNode:self.player scaleRatio:0.4];
        [self addChild:self.player];
        
        //chaos bar
        [self initializeBars];
        
        [self initializeAimer];
        [self initializeTimer];
        [self initializeCat];
        [self countdown];
        
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
        [self.aim.physicsBody applyForce:CGVectorMake(1000.0 * data.acceleration.y, 0)];
    }
    if (fabs(data.acceleration.x) > 0.2)
    {
        [self.aim.physicsBody applyForce:CGVectorMake(0, -1000.0 * data.acceleration.x)];
    }
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
    self.timerLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
    self.timerLabel.fontSize = 15;
    self.timerLabel.fontColor = [SKColor redColor];
    self.timerLabel.text = [NSString stringWithFormat:@"Time: %i", 0];
    self.timerLabel.position = CGPointMake(self.timerLabel.frame.size.width, self.table.size.height + self.timerLabel.frame.size.height*2);
    
    [self addChild:self.timerLabel];
}

- (void)initializeCat
{
    NSMutableArray *walkFramesLeft = [NSMutableArray array];
    SKTextureAtlas *catAnimatedAtlasLeft = [SKTextureAtlas atlasNamed:@"catImagesLeft"];
    for (int i=1; i <= catAnimatedAtlasLeft.textureNames.count; i++) {
        NSString *textureName = [NSString stringWithFormat:@"cat_left%d", i];
        SKTexture *temp = [catAnimatedAtlasLeft textureNamed:textureName];
        [walkFramesLeft addObject:temp];
    }
    self.catWalkingFramesLeft = walkFramesLeft;
    
    NSMutableArray *walkFramesRight = [NSMutableArray array];
    SKTextureAtlas *catAnimatedAtlasRight = [SKTextureAtlas atlasNamed:@"catImagesRight"];
    for (int i=1; i <= catAnimatedAtlasRight.textureNames.count; i++) {
        NSString *textureName = [NSString stringWithFormat:@"cat_right%d", i];
        SKTexture *temp = [catAnimatedAtlasRight textureNamed:textureName];
        [walkFramesRight addObject:temp];
    }
    self.catWalkingFramesRight = walkFramesRight;
    
    NSMutableArray *catFramesFlipLeft = [NSMutableArray array];
    SKTextureAtlas *catAnimatedAtlasFlipLeft = [SKTextureAtlas atlasNamed:@"catImagesFlipLeft"];
    NSString *textureName = [NSString stringWithFormat:@"cat_left_flip"];
    SKTexture *temp = [catAnimatedAtlasFlipLeft textureNamed:textureName];
    [catFramesFlipLeft addObject:temp];
    self.catFlippingFramesLeft = catFramesFlipLeft;
    
    NSMutableArray *catFramesFlipRight = [NSMutableArray array];
    SKTextureAtlas *catAnimatedAtlasFlipRight = [SKTextureAtlas atlasNamed:@"catImagesFlipRight"];
    textureName = [NSString stringWithFormat:@"cat_right_flip"];
    temp = [catAnimatedAtlasFlipRight textureNamed:textureName];
    [catFramesFlipRight addObject:temp];
    self.catFlippingFramesRight = catFramesFlipRight;
    
    NSMutableArray *walkFramesHitLeft = [NSMutableArray array];
    SKTextureAtlas *catAnimatedAtlasHitLeft = [SKTextureAtlas atlasNamed:@"catImagesHitLeft"];
    textureName = [NSString stringWithFormat:@"cat_left_hit"];
    temp = [catAnimatedAtlasHitLeft textureNamed:textureName];
    [walkFramesHitLeft addObject:temp];
    self.catHitFramesLeft = walkFramesHitLeft;
    
    NSMutableArray *walkFramesHitRight = [NSMutableArray array];
    SKTextureAtlas *catAnimatedAtlasHitRight = [SKTextureAtlas atlasNamed:@"catImagesHitRight"];
    textureName = [NSString stringWithFormat:@"cat_right_hit"];
    temp = [catAnimatedAtlasHitRight textureNamed:textureName];
    [walkFramesHitRight addObject:temp];
    self.catHitFramesRight = walkFramesHitRight;
    
    self.cat = [SKSpriteNode spriteNodeWithImageNamed:@"cat_0.png"];
    
    self.cat.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetMidY(self.table));
    [self scaleSpriteNode:self.cat scaleRatio:0.25];
    
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

-(void)countdown
{
    self.countdownLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    self.countdownLabel.fontSize = 50;
    self.countdownLabel.fontColor = [SKColor blueColor];
    self.countdownLabel.text = [NSString stringWithFormat:@"%i", 3];
    self.countdownLabel.position = CGPointMake(CGRectGetMidX(self.table), CGRectGetMidY(self.table));
    [self addChild:self.countdownLabel];
    SKAction * fadeCountdown = [SKAction fadeOutWithDuration:1];
    SKAction * unfadeCountdown = [SKAction fadeInWithDuration:0];
    SKAction * removeCountdown = [SKAction removeFromParent];
    SKAction * wait = [SKAction waitForDuration:1];
    
    [self.countdownLabel runAction:[SKAction sequence:@[fadeCountdown, wait]]];
    self.countdownLabel.text = [NSString stringWithFormat:@"%i", 2];

    [self.countdownLabel runAction:[SKAction sequence:@[unfadeCountdown, fadeCountdown, wait]]];
    self.countdownLabel.text = [NSString stringWithFormat:@"%i", 1];

    [self.countdownLabel runAction:[SKAction sequence:@[unfadeCountdown, fadeCountdown, wait]]];
    self.countdownLabel.text = [NSString stringWithFormat:@"GO!"];

    [self.countdownLabel runAction:[SKAction sequence:@[fadeCountdown, removeCountdown, wait]]];
}

-(void)updateCat
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
    SKAction * animate;
    CGPoint location = self.cat.position;
    if (location.x <= catXDestination) {
        //walk right
        animate = [SKAction repeatAction:[SKAction animateWithTextures:self.catWalkingFramesRight
                                                           timePerFrame:0.2] count:5];
    } else {
        //walk left
        animate = [SKAction repeatAction:[SKAction animateWithTextures:self.catWalkingFramesLeft
                                                                    timePerFrame:0.2] count:5];;
    }
    
    [self.cat runAction:[SKAction group:@[animate, actionMove]]];
    
    
}

-(void)addItem
{
    // Create item to place on table
    
    NSString *itemImageURL = [self randomItem];
    SKSpriteNode * item = [SKSpriteNode spriteNodeWithImageNamed:itemImageURL];
    [self scaleSpriteNode:item scaleRatio:0.3];
    
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

-(NSString *)randomItem
{
    NSInteger random = arc4random_uniform(itemAssets);
    switch(random) {
        case 0: return @"thing_book.png";
            break;
        case 1: return @"thing_bread.png";
            break;
        case 2: return @"thing_candy.png";
            break;
        case 3: return @"thing_cup.png";
            break;
        case 4: return @"thing_dagger.png";
            break;
        case 5: return @"thing_eraser.png";
            break;
        case 6: return @"thing_lamp.png";
            break;
        case 7: return @"thing_laptop.png";
            break;
        case 8: return @"thing_mug.png";
            break;
        case 9: return @"thing_pen.png";
            break;
        case 10: return @"thing_pencil.png";
            break;
        case 11: return @"thing_ramen.png";
            break;
        case 12: return @"thing_snowglobe.png";
            break;
        case 13: return @"thing_thermos.png";
            break;
        case 14: return @"thing_vase.png";
            break;
        default: return @"onion.png";
            break;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.shootingBool = NO;
    SKAction * scaleEmptyDogBar = [SKAction resizeToHeight:(self.dogBarHeight) duration:0];
    [self.shootingBarCharger runAction:[SKAction sequence:@[scaleEmptyDogBar]]];
    //music for on hit
    //[self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    
    // Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint locationCheck = [touch locationInNode:self];
    NSLog(@"%f  %f",locationCheck.x, locationCheck.y);
    
    // Set up initial location of projectile
    DogSpriteNode * projectile;
    [projectile setShotPower:7];
    
    [SKSpriteNode spriteNodeWithImageNamed:@"puppy.png"];
    [self scaleSpriteNode:projectile scaleRatio:0.2];
    
    //projectile physics
    projectile.position = CGPointMake(tableCornerX+tableWidth/2, tableCornerY+tableHeight);
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = itemCategory;
    projectile.physicsBody.collisionBitMask = !aimCategory;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    CGPoint normal = rwSub(self.aim.position, projectile.position);
    CGFloat rotationRadians = atan2f(normal.y, normal.x) + 3.14/2;

    
    // Determine offset of location to projectile
    CGPoint offset = rwSub(self.aim.position, projectile.position);
    
    // Bail out if shooting up
    if (offset.y >= 0) return;

    [self addChild:projectile];
    
    //get the destination and duration for the animation
    CGPoint projectileDestination = [self assetDestination:&offset assetPosition:projectile.position];
    float animationDuration = [self getAnimationDuration:@"projectile"];
    
    // Create the actions
    SKAction * rotateProjectile = [SKAction rotateToAngle:rotationRadians duration:0];
    SKAction * actionMove = [SKAction moveTo:projectileDestination duration:animationDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[rotateProjectile, actionMove, actionMoveDone]]];
    SKAction * fadeClickedBarAway = [SKAction fadeOutWithDuration:0];
    [self.shootingBarBackgroundWhenClicked runAction:fadeClickedBarAway];
    SKAction * showUnclickedBar = [SKAction fadeInWithDuration:0];
    [self.shootingBarBackground runAction:showUnclickedBar];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.shootingBool = YES;
    self.beginningShotTime=self.totalTimeInterval;
    SKAction * fadeUnclickedBarAway = [SKAction fadeOutWithDuration:0];
    [self.shootingBarBackground runAction:fadeUnclickedBarAway];
    SKAction * showClickedBar = [SKAction fadeInWithDuration:0];
    [self.shootingBarBackgroundWhenClicked runAction:showClickedBar];
}

-(CGPoint)assetDestination:(CGPoint *)initialDirection assetPosition:(CGPoint)assetPossition
{
    // Get the direction of where to shoot the item
    CGPoint direction = rwNormalize(*initialDirection);
    // Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, self.frame.size.width*2);
    return rwAdd(shootAmount, assetPossition);
}

-(float)getAnimationDuration:(NSString*)asset
{
    if ([asset isEqual:@"projectile"]) {
        return self.size.width / 180;
    } else if ([asset isEqualToString:@"item"]) {
        return self.size.width / 480;
    } else {
        NSLog(@"invalid asset!");
        exit(0);
    }
}

-(void)projectile:(SKSpriteNode *)projectile didCollideWithCat:(SKSpriteNode *)cat
{
    NSLog(@"Hit");
    [projectile removeFromParent];
    
    if(self.chaosCount > 0)
    self.chaosCount--;
    [self updateChaosBar];
    NSLog(@"%f",self.chaosCount);
    
    //on hit, cat turns red for a short period second
    SKAction *pulseRed = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.05],
                                              [SKAction waitForDuration:0.05],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.05]]];

    
    SKAction * hitAnimation;
    if(projectile.position.x >= cat.position.x) {
        hitAnimation = [SKAction animateWithTextures:self.catHitFramesRight timePerFrame:0.8];
    } else {
        hitAnimation = [SKAction animateWithTextures:self.catHitFramesLeft timePerFrame:0.8];
    }
    SKAction * normalCat = [SKAction colorizeWithColorBlendFactor:0.0 duration:0.25];
    [self.cat runAction:[SKAction group:@[pulseRed, hitAnimation]]];
    [self.cat runAction:[SKAction sequence:@[normalCat]] completion:^{
        //set cat to go new random direction
        [self updateCat];
    }];
}

-(void)item:(SKSpriteNode *)item didCollideWithCat:(SKSpriteNode *)cat
{
    NSLog(@"Item Hit by cat");
    self.chaosCount = self.chaosCount + 10;
    [self updateChaosBar];
    NSLog(@"%f",self.chaosCount);
    [self checkIfGameOver];
    
    // Determine offset of item to the cat
    CGPoint offset = rwSub(item.position, cat.position);
    
    CGPoint itemDestination = [self assetDestination:&offset assetPosition:item.position];
    float animationDuration = [self getAnimationDuration:@"item"];
    SKAction * actionMove = [SKAction moveTo:itemDestination duration:animationDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [item runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    
    SKAction * flipAnimation;
    if(item.position.x >= cat.position.x) {
        flipAnimation = [SKAction animateWithTextures:self.catFlippingFramesRight timePerFrame:0.3];
    } else {
      flipAnimation = [SKAction animateWithTextures:self.catFlippingFramesLeft timePerFrame:0.3];
    }
    //SKAction * actionMoveCat = [SKAction waitForDuration:0.5];

    [self.cat runAction:[SKAction group:@[flipAnimation]] completion:^{
        //set cat to go new random direction
        [self updateCat];
    }];
}

-(void)item:(SKSpriteNode *)item didCollideWithProjectile:(SKSpriteNode *)projectile
{
    NSLog(@"Item Hit by projectile");
    self.chaosCount = self.chaosCount + 3;
    [self updateChaosBar];
    NSLog(@"%f",self.chaosCount);
    
    [self checkIfGameOver];
    // Determine offset of item to the cat
    CGPoint offsetItem = rwSub(item.position, projectile.position);
    CGPoint offsetProjectile = rwSub(projectile.position, item.position);
    
    
    CGPoint itemDestination = [self assetDestination:&offsetItem assetPosition:item.position];
    CGPoint projectileDestination = [self assetDestination:&offsetProjectile assetPosition:projectile.position];
    float animationDuration = [self getAnimationDuration:@"item"];

    SKAction * actionMoveItem = [SKAction moveTo:itemDestination duration:animationDuration];
    SKAction * actionMoveProjectile = [SKAction moveTo:projectileDestination duration:animationDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [item runAction:[SKAction sequence:@[actionMoveItem, actionMoveDone]]];
    [projectile runAction:[SKAction sequence:@[actionMoveProjectile, actionMoveDone]]];
    
    //add another item
    [self addItem];
}

-(void)updateChaosBar
{
    SKAction * scaleEmptyChaosBar = [SKAction resizeToWidth:(self.chaosBarWidth*(101-self.chaosCount)/100) duration:0];
    [self.chaosBarCharger runAction:[SKAction sequence:@[scaleEmptyChaosBar]]];
}

-(void)updateDogBar
{
    SKAction * scaleEmptyDogBar = [SKAction resizeToHeight:(self.dogBarHeight*(maxShotTime-(self.totalTimeInterval- self.beginningShotTime))/maxShotTime) duration:0];
    [self.shootingBarCharger runAction:[SKAction sequence:@[scaleEmptyDogBar]]];
}

-(void)checkIfGameOver
{
    if (self.chaosCount >= 100) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScreen alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition: reveal];
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact
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

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    
    self.lastSpawnTimeInterval += timeSinceLast;
    self.totalTimeInterval += timeSinceLast;
    
    // For every current value of updateSpeed/100 add another item/ update cat
    if (self.lastSpawnTimeInterval > (self.updateSpeed/100)) {
        self.lastSpawnTimeInterval = 0;
        [self addItem];
        [self updateCat];
    }
}

-(void)update:(NSTimeInterval)currentTime
{
    
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
    
    if (((self.totalTimeInterval-self.beginningShotTime) < maxShotTime) && self.shootingBool) {
        [self updateDogBar];
    }
    
}

@end