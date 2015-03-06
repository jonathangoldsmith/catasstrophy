//
//  Tutorial.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/25/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "Tutorial.h"
#import "Menu.h"
#import "math.h"
#import "Countdown.h"

@interface Tutorial() <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) SKSpriteNode * cat;
@property (nonatomic) SKSpriteNode * cat2;
@property (nonatomic) SKSpriteNode * item;
@property NSArray * catWalkingFramesLeft;
@property NSArray * catWalkingFramesRight;
@property NSArray * catFlippingFramesLeft;
@property NSArray * catFlippingFramesRight;
@property NSArray * catHitFramesLeft;
@property NSArray * catHitFramesRight;
@property NSArray * catSitFrame;
@property (nonatomic) SKSpriteNode * aim;
@property (nonatomic) SKSpriteNode * chaosBarBackground;
@property (nonatomic) SKSpriteNode * chaosBarCharger;
@property (nonatomic) SKSpriteNode * shootingBarBackground;
@property (nonatomic) SKSpriteNode * shootingBarBackgroundWhenClicked;
@property (nonatomic) SKSpriteNode * shootingBarCharger;
@property (nonatomic) SKLabelNode* timerLabel;
@property (nonatomic) SKLabelNode* tutorialLabel;
@property (nonatomic) SKLabelNode* tutorialLabel2;
@property (nonatomic) SKLabelNode* tutorialLabel3;
@property (nonatomic) float beginningShotTime;
@property (nonatomic) float shotPower;
@property (nonatomic) float chaosCount;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic) CGRect table;
@property (nonatomic) float chaosBarWidth;
@property (nonatomic) float dogBarHeight;
@property (nonatomic) NSInteger frameNumber;
@property (nonatomic) BOOL sendCatToMiddle;
@property (nonatomic) BOOL shootingBool;
@property (nonatomic) BOOL shotsFired;
@property (nonatomic) NSTimeInterval totalTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end
@implementation Tutorial


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
    sprite.xScale = scale*self.size.width/568;
    sprite.yScale = scale*self.size.height/320;
}

//updater to the accelerometer to chage the aimer
-(void)processUserMotionForUpdate:(NSTimeInterval)currentTime
{
    CMAccelerometerData* data = self.motionManager.accelerometerData;
    if (fabs(data.acceleration.y) > 0.1)
    {
        [self.aim.physicsBody applyForce:CGVectorMake(1500.0 * data.acceleration.y, 0)];
    }
    if (fabs(data.acceleration.x) > 0.1)
    {
        [self.aim.physicsBody applyForce:CGVectorMake(0, -1500.0 * data.acceleration.x)];
    }
}


-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        self.motionManager = [[CMMotionManager alloc] init];
        [self.motionManager startAccelerometerUpdates];
        self.table = CGRectMake(tableCornerX*self.size.width/568, tableCornerY*self.size.height/320, tableWidth*self.size.width/568, tableHeight*self.size.height/320);
        self.chaosCount = 0;
        
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
        
        
        //chaos bar/aimer/timer/cat/
        [self initializeAimer];
        self.aim.hidden = YES;
        [self initializeCat];
        self.cat.hidden = YES;
        [self initializeSecondCat];
        self.cat2.hidden = YES;
        [self addItem];
        self.item.hidden = YES;
        [self initializeChaosBar];
        self.chaosBarCharger.hidden = YES;
        self.chaosBarBackground.hidden = YES;
        [self initializeDogBar];
        self.shootingBarBackground.hidden = YES;
        self.shootingBarBackgroundWhenClicked.hidden = YES;
        self.shootingBarCharger. hidden = YES;
        
        self.frameNumber = 0;
        [self initializeTutorialLabels];
        [self increment:self.frameNumber];
    }
    return self;
}



-(void)initializeChaosBar
{
    self.chaosBarBackground=[SKSpriteNode spriteNodeWithImageNamed:@"chaos_filled.png"];
    [self scaleSpriteNode:self.chaosBarBackground scaleRatio:0.5];
    self.chaosBarBackground.position=CGPointMake(tableWidth*self.size.width/568 - 40*self.size.width/568, tableHeight*self.size.height/320 + self.chaosBarBackground.size.height/2*self.size.height/320+5*self.size.width/568);
    [self addChild:self.chaosBarBackground];
    
    self.chaosBarCharger=[SKSpriteNode spriteNodeWithImageNamed:@"chaos_inner.png"];
    [self scaleSpriteNode:self.chaosBarCharger scaleRatio:0.5];
    self.chaosBarCharger.anchorPoint = CGPointMake(1,0.5);
    self.chaosBarCharger.position=CGPointMake(546*self.size.width/568,289*self.size.height/320);
    self.chaosBarWidth = self.chaosBarCharger.size.width;
    [self addChild:self.chaosBarCharger];
    
}

-(void)initializeDogBar {
    
    self.shootingBarBackgroundWhenClicked=[SKSpriteNode spriteNodeWithImageNamed:@"dogbar_clicked.png"];
    [self scaleSpriteNode:self.shootingBarBackgroundWhenClicked scaleRatio:0.5];
    self.shootingBarBackgroundWhenClicked.position=CGPointMake(tableWidth*self.size.width/568 + self.shootingBarBackgroundWhenClicked.size.width/1.5, tableHeight/2*self.size.height/320 + 5*self.size.height/320);
    [self addChild:self.shootingBarBackgroundWhenClicked];
    SKAction * fadeOutBarInitially = [SKAction fadeOutWithDuration:0];
    [self.shootingBarBackgroundWhenClicked runAction:[SKAction sequence:@[fadeOutBarInitially]]];
    
    self.shootingBarBackground=[SKSpriteNode spriteNodeWithImageNamed:@"dogbar.png"];
    [self scaleSpriteNode:self.shootingBarBackground scaleRatio:0.5];
    self.shootingBarBackground.position=CGPointMake(tableWidth*self.size.width/568 + self.shootingBarBackground.size.width/1.5, tableHeight/2*self.size.height/320 + 5*self.size.height/320);
    [self addChild:self.shootingBarBackground];
    
    self.shootingBarCharger=[SKSpriteNode spriteNodeWithImageNamed:@"dogbar_inner.png"];
    [self scaleSpriteNode:self.shootingBarCharger scaleRatio:0.5];
    self.shootingBarCharger.anchorPoint = CGPointMake(0.5,1);
    self.shootingBarCharger.position=CGPointMake(512.4*self.size.width/568,259*self.size.height/320);
    self.dogBarHeight = self.shootingBarCharger.size.height;
    [self addChild:self.shootingBarCharger];
    
}

-(void)initializeAimer
{
    self.aim=[SKSpriteNode spriteNodeWithImageNamed:@"target.png"];
    self.aim.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetHeight(self.table));
    [self scaleSpriteNode:self.aim scaleRatio:0.8];
    
    [self addChild:self.aim];
}

-(void)initializeTimer
{
    self.timerLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
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
    
    NSMutableArray *sitFrames = [NSMutableArray array];
    SKTextureAtlas *catAnimatedAtlasSit = [SKTextureAtlas atlasNamed:@"catImagesSit"];
    textureName = [NSString stringWithFormat:@"cat_0"];
    temp = [catAnimatedAtlasSit textureNamed:textureName];
    [sitFrames addObject:temp];
    self.catHitFramesRight = sitFrames;
    
    self.cat = [SKSpriteNode spriteNodeWithImageNamed:@"cat_0.png"];
    self.cat.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetMidY(self.table));
    [self scaleSpriteNode:self.cat scaleRatio:0.25];
    
    //cat phsysics
    self.cat.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.cat.size];
    self.cat.physicsBody.dynamic = YES;
    self.cat.physicsBody.categoryBitMask = catCategory;
    self.cat.physicsBody.contactTestBitMask = projectileCategory;
    self.cat.physicsBody.collisionBitMask = !aimCategory;
    
    [self addChild:self.cat];
}

- (void)initializeSecondCat
{
    self.cat2 = [SKSpriteNode spriteNodeWithImageNamed:@"cat_0.png"];
    self.cat2.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetMidY(self.table));
    [self scaleSpriteNode:self.cat2 scaleRatio:0.25];
    
    //cat phsysics
    self.cat2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.cat.size];
    self.cat2.physicsBody.dynamic = YES;
    self.cat2.physicsBody.categoryBitMask = catCategory;
    self.cat2.physicsBody.contactTestBitMask = projectileCategory;
    self.cat2.physicsBody.collisionBitMask = !aimCategory;
    
    [self addChild:self.cat2];
}

-(void)increment:(NSInteger)frameNumber{
    //SKAction * fadetutorial = [SKAction fadeOutWithDuration:1];
    //SKAction * unfadetutorial = [SKAction fadeInWithDuration:0];
    
    if(self.frameNumber==0) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"This is you"];
    }else if(self.frameNumber==1) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"This is your cat (he's a jerk)"];
        self.cat.hidden = NO;
    }else if(self.frameNumber==2) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"He likes to knock stuff off of your desk "];
        self.tutorialLabel2.text = [NSString stringWithFormat:@"(what a jerk!)"];

        self.item.hidden = NO;
        
    }else if(self.frameNumber==3) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"Every time he knocks something off of your desk,"];
        self.tutorialLabel2.text = [NSString stringWithFormat:@"your life slowly devolves into chaos,"];
        self.tutorialLabel3.text = [NSString stringWithFormat:@"convieniently tracked by this bar"];
        // self.cat = [SKSpriteNode spriteNodeWithImageNamed:@"cat_0.png"];
        self.sendCatToMiddle = NO;
        [self moveCat];
        //cat move to and flip item
        self.chaosBarBackground.hidden = NO;
        self.chaosBarCharger.hidden = NO;
    }else if(self.frameNumber==4) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"Thankfully you have your patented"];
        self.tutorialLabel2.text = [NSString stringWithFormat:@"Discipline-Omatic-Gun(TM)"];
        self.tutorialLabel3.text = [NSString stringWithFormat:@""];
        self.aim.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetHeight(self.table));
        self.shootingBarBackground.hidden = NO;
        self.aim.hidden = NO;
        self.shootingBarBackgroundWhenClicked.hidden = NO;
        self.shootingBarCharger. hidden = NO;
    } else if(self.frameNumber==5) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"Tilt your iPhone to aim your DOG"];
        self.tutorialLabel2.text = [NSString stringWithFormat:@"and click to shoot"];
        //aimer physics
    } else if(self.frameNumber==6) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"The more you charge your DOG"];
        self.tutorialLabel2.text = [NSString stringWithFormat:@"the better you will feel about disciplining your cat"];
        self.tutorialLabel3.text = [NSString stringWithFormat:@"(less chaos on hit)"];
        
    } else if(self.frameNumber==7) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"Cats dont like DOGs though so good luck"];
        self.tutorialLabel2.text = [NSString stringWithFormat:@""];
        self.tutorialLabel3.text = [NSString stringWithFormat:@""];
    } else {
        SKScene * game = [[Countdown alloc] initWithSize:self.size];
        [self.view presentScene:game transition:[SKTransition fadeWithDuration:0]];
    }
    
    //[self.tutorialLabel runAction:[SKAction sequence:@[unfadetutorial, fadetutorial]]];
    self.frameNumber++;
}

-(void)addItem
{
    // Create item to place on table
    
    NSString *itemImageURL = [self randomItem];
    self.item = [SKSpriteNode spriteNodeWithImageNamed:itemImageURL];
    [self scaleSpriteNode:self.item scaleRatio:0.3];
    
    // Determine where to spawn the item on the table
    int itemYPostion = tableHeight/2 + tableCornerY + self.item.size.height/2;
    int itemXPosition = 10 + tableCornerX + self.item.size.width/2;
    
    if(self.sendCatToMiddle) {
        itemYPostion = tableHeight/2 + tableCornerY - self.item.size.height;
        itemXPosition = tableWidth/2 + tableCornerX + self.item.size.width/2;
    }
    self.item.position = CGPointMake(itemXPosition*self.size.width/568,itemYPostion*self.size.height/320);
    
    //set up physics of item
    self.item.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.item.size];
    self.item.physicsBody.dynamic = YES;
    self.item.physicsBody.categoryBitMask = itemCategory;
    self.item.physicsBody.contactTestBitMask = catCategory;
    self.item.physicsBody.collisionBitMask = !aimCategory;
    self.item.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:self.item];
    
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
        case 15: return @"thing_bird.png";
            break;
        case 16: return @"thing_fish.png";
            break;
        case 17: return @"thing_frog.png";
            break;
        case 18: return @"thing_mouse.png";
            break;
        default: return @"onion.png";
            break;
    }
}


-(void)initializeTutorialLabels
{
    CGFloat fontSize = 15*self.size.width/568;
    self.tutorialLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.tutorialLabel.fontSize = fontSize;
    self.tutorialLabel.fontColor = [SKColor whiteColor];
    self.tutorialLabel.text = [NSString stringWithFormat:@""];
    self.tutorialLabel.position = CGPointMake(CGRectGetMidX(self.table), CGRectGetMidY(self.table)+70*self.size.height/320);
    [self addChild:self.tutorialLabel];
    
    self.tutorialLabel2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.tutorialLabel2.fontSize = fontSize;
    self.tutorialLabel2.fontColor = [SKColor whiteColor];
    self.tutorialLabel2.text = [NSString stringWithFormat:@""];
    self.tutorialLabel2.position = CGPointMake(CGRectGetMidX(self.table), CGRectGetMidY(self.table)+50*self.size.height/320);
    [self addChild:self.tutorialLabel2];
    
    self.tutorialLabel3 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.tutorialLabel3.fontSize = fontSize;
    self.tutorialLabel3.fontColor = [SKColor whiteColor];
    self.tutorialLabel3.text = [NSString stringWithFormat:@""];
    self.tutorialLabel3.position = CGPointMake(CGRectGetMidX(self.table), CGRectGetMidY(self.table)+30*self.size.height/320);
    [self addChild:self.tutorialLabel3];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch = [touches anyObject];
    //CGPoint location = [touch locationInNode:self];
    //SKNode *node = [self nodeAtPoint:location];
    
    //pressed skip button
    //if ([node.name isEqualToString:@"menuButton"]) {
    //    SKScene * menu = [[Menu alloc] initWithSize:self.size];
    //    [self.view presentScene:menu transition:[SKTransition fadeWithDuration:.5]];
    //}
    
    if(self.frameNumber < 4)
    {
        [self increment:self.frameNumber];
        
    } else if (self.frameNumber > 5) {
        self.shootingBool = YES;
        self.beginningShotTime=self.totalTimeInterval;
        SKAction * fadeUnclickedBarAway = [SKAction fadeOutWithDuration:0];
        [self.shootingBarBackground runAction:fadeUnclickedBarAway];
        SKAction * showClickedBar = [SKAction fadeInWithDuration:0];
        [self.shootingBarBackgroundWhenClicked runAction:showClickedBar];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.frameNumber > 5) {
        // Choose one of the touches to work with
        UITouch * touch = [touches anyObject];
        CGPoint locationCheck = [touch locationInNode:self];
        NSLog(@"%f  %f",locationCheck.x, locationCheck.y);
        
        self.shootingBool = NO;
        self.shotPower = 10*(1-(self.shootingBarCharger.size.height/self.dogBarHeight));
        SKAction * scaleEmptyDogBar = [SKAction resizeToHeight:(self.dogBarHeight) duration:0];
        [self.shootingBarCharger runAction:[SKAction sequence:@[scaleEmptyDogBar]]];
        SKAction * fadeClickedBarAway = [SKAction fadeOutWithDuration:0];
        [self.shootingBarBackgroundWhenClicked runAction:fadeClickedBarAway];
        SKAction * showUnclickedBar = [SKAction fadeInWithDuration:0];
        [self.shootingBarBackground runAction:showUnclickedBar];
        
        if(!self.shotsFired) {
            self.shotsFired = YES;
            SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"puppy.png"];
            [self scaleSpriteNode:projectile scaleRatio:0.2];
            
            //music for shot
            NSInteger random = arc4random_uniform(2);
            switch(random) {
                case 0:[self runAction:[SKAction playSoundFileNamed:@"woof2.mp3" waitForCompletion:NO]];
                    break;
                default:[self runAction:[SKAction playSoundFileNamed:@"bark2.mp3" waitForCompletion:NO]];
                    break;
            }
            
            //projectile physics
            projectile.position = CGPointMake((tableCornerX+tableWidth/2)*self.size.width/568, (tableCornerY+tableHeight)*self.size.height/320);        projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
            projectile.physicsBody.dynamic = YES;
            projectile.physicsBody.categoryBitMask = projectileCategory;
            projectile.physicsBody.contactTestBitMask = itemCategory;
            projectile.physicsBody.collisionBitMask = !aimCategory;
            projectile.physicsBody.usesPreciseCollisionDetection = YES;
            CGPoint normal = rwSub(self.aim.position, projectile.position);
            float slope = normal.y/normal.x;
            float possibleX = (-10-projectile.position.y)/slope + projectile.position.x;
            float possibleY = slope*(-10-projectile.position.x) + projectile.position.y;
            float possibleY2 = slope*(575*self.size.height/320-projectile.position.x) + projectile.position.y;
            
            
            CGPoint projectileDestinationMaybe;
            if(0 < possibleX && possibleX < 568*self.size.width/568) {
                projectileDestinationMaybe=CGPointMake(possibleX, -10);
            } else if (possibleY > possibleY2) {
                projectileDestinationMaybe=CGPointMake(575*self.size.width/568, possibleY2);
            } else {
                projectileDestinationMaybe=CGPointMake(-10, possibleY);
            }
            CGFloat rotationRadians = atan2f(normal.y, normal.x) + 3.14/2;
            
            
            // Determine offset of location to projectile
            CGPoint offset = rwSub(self.aim.position, projectile.position);
            
            // Bail out if shooting up
            if (offset.y >= 0) return;
            
            [self addChild:projectile];
            
            //get the destination and duration for the animation
            //CGPoint projectileDestination = [self assetDestination:&offset assetPosition:projectile.position];
            //float animationDuration = [self getAnimationDuration:@"projectile"];
            
            // Create the actions
            SKAction * rotateProjectile = [SKAction rotateToAngle:rotationRadians duration:0];
            SKAction * actionMove = [SKAction moveTo:projectileDestinationMaybe duration:0.5];
            SKAction * actionMoveDone = [SKAction removeFromParent];
            [projectile runAction:[SKAction sequence:@[rotateProjectile, actionMove, actionMoveDone]] completion:^{
                //set cat to go new random direction
                self.shotsFired = NO;
            }];
            
        }
    }
}

//move that cat!
-(void)moveCat {
    int catXDestination = 0;
    int catYDestination = 0;
    if(self.sendCatToMiddle) {
        catYDestination = (tableHeight/2) + tableCornerY; //center
        catXDestination = self.table.size.width;
        
    } else {
        catXDestination = tableCornerX*2; //left wall
        catYDestination = (tableHeight/2) + tableCornerY;
    }
    SKAction * actionMove = [SKAction moveTo:CGPointMake(catXDestination*self.size.width/568, catYDestination*self.size.height/320) duration:(startSpeed/119)];
    SKAction * animate;
    //SKAction * actaf = [SKAction anim]
    CGPoint location = self.cat.position;
    if (location.x <= catXDestination) {
        //walk right
        animate = [SKAction repeatAction:[SKAction animateWithTextures:self.catWalkingFramesRight
                                                          timePerFrame:0.25] count:10];
    } else {
        //walk left
        animate = [SKAction repeatAction:[SKAction animateWithTextures:self.catWalkingFramesLeft
                                                          timePerFrame:0.25] count:6];
        // animate = [SKAction animateWithTextures:self.catWalkingFramesLeft
        //timePerFrame:0.2];
        //animate.duration = 3;
        
    }
    [self.cat runAction:[SKAction group:@[animate, actionMove]] completion:^{
        self.cat.hidden = YES;
        self.cat.physicsBody = nil;
        self.cat2.hidden = NO;
        [self increment:self.frameNumber];
        
    }];
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
    if(self.frameNumber == 6) {
        [self increment:self.frameNumber];
    }
    
    NSLog(@"Hit");
    [projectile removeFromParent];
    self.shotsFired = NO;
    
    [self runAction:[SKAction playSoundFileNamed:@"meow2.mp3" waitForCompletion:NO]];
    
    if(self.chaosCount > 0)
    {
        self.chaosCount=MAX(0,self.chaosCount - self.shotPower);
    } else {
        if(self.frameNumber > 6)
            [self increment:self.frameNumber];
        
    }
    [self updateChaosBar];
    NSLog(@"%f",self.chaosCount);
    
    //on hit, cat turns red for a short period second
    SKAction *pulseRed = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.05],
                                              [SKAction waitForDuration:0.05],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.05]]];
    
    
    SKAction * hitAnimation;
    if(projectile.position.x >= cat.position.x) {
        hitAnimation = [SKAction animateWithTextures:self.catHitFramesRight timePerFrame:0.5];
    } else {
        hitAnimation = [SKAction animateWithTextures:self.catHitFramesLeft timePerFrame:0.5];
    }
    SKAction * normalCat = [SKAction colorizeWithColorBlendFactor:0.0 duration:0.25];
    [self.cat2 runAction:[SKAction group:@[pulseRed, hitAnimation]]];
    [self.cat2 runAction:[SKAction sequence:@[normalCat]] completion:^{
        //set cat to go new random direction
        //[self updateCat];
    }];
}

-(void)sendCatBack {
    
}

-(CGPoint)assetDestination:(CGPoint *)initialDirection assetPosition:(CGPoint)assetPosition
{
    // Get the direction of where to shoot the item
    CGPoint direction = rwNormalize(*initialDirection);
    // Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, self.frame.size.width*2);
    return rwAdd(shootAmount, assetPosition);
}

-(void)item:(SKSpriteNode *)item didCollideWithCat:(SKSpriteNode *)cat
{
    NSLog(@"Item Hit by cat");
    self.chaosCount = self.chaosCount + 11;
    [self updateChaosBar];
    NSLog(@"%f",self.chaosCount);
    //[self checkIfGameOver];
    
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
        self.sendCatToMiddle = YES;
        [self moveCat];
    }];
}

-(void)item:(SKSpriteNode *)item didCollideWithProjectile:(SKSpriteNode *)projectile
{
    NSLog(@"Item Hit by projectile");
    self.chaosCount = self.chaosCount + 3;
    [self updateChaosBar];
    //NSLog(@"%f",self.chaosCount);
    [projectile removeFromParent];
    //self.shotsFired = NO;
    
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

-(void)updateChaosBar
{
    SKAction * scaleEmptyChaosBar = [SKAction resizeToWidth:(self.chaosBarWidth*(101-self.chaosCount)/100) duration:0];
    [self.chaosBarCharger runAction:[SKAction sequence:@[scaleEmptyChaosBar]]];
}

-(void)updateDogBar
{
    SKAction * scaleEmptyDogBar = [SKAction resizeToHeight:(self.dogBarHeight*(maxShotTime-MIN(self.totalTimeInterval- self.beginningShotTime, 1))) duration:0];
    [self.shootingBarCharger runAction:[SKAction sequence:@[scaleEmptyDogBar]]];
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
    
    self.totalTimeInterval += timeSinceLast;
    
    if (self.shootingBool) {
        [self updateDogBar];
    }
    
    //self.backgroundMusicPlayerFast.rate = 0.5 + self.chaosCount/1000;
    
}

@end