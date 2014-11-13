//
//  Tutorial.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/25/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "Tutorial.h"
#import "Menu.h"
#import "Countdown.h"

@interface Tutorial() <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) SKSpriteNode * cat;
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
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic) CGRect table;
@property (nonatomic) float chaosBarWidth;
@property (nonatomic) float dogBarHeight;
@property (nonatomic) NSInteger frameNumber;
@end
@implementation Tutorial


//various physics functions
static const uint32_t itemCategory        =  0x1 << 0;
static const uint32_t projectileCategory     =  0x1 << 1;
static const uint32_t catCategory        =  0x1 << 2;
static const uint32_t aimCategory        =  0x1 << 3;

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
        
        //Set up the world physics
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.table];
        self.physicsBody.collisionBitMask = aimCategory;
        self.physicsWorld.contactDelegate = self;

        self.table = CGRectMake(tableCornerX, tableCornerY, tableWidth, tableHeight);
        
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
        
        self.frameNumber = 0;
        [self initializeTutorialLabels];
        [self increment:self.frameNumber];
        //chaos bar/aimer/timer/cat/
        //[self initializeBars];
        //[self initializeAimer];
        //[self initializeCat];
        
    }
    return self;
}

-(void)initializeChaosBar
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
    
}

-(void)initializeDogBar {
    
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
    
    self.cat = [SKSpriteNode spriteNodeWithImageNamed:@"cat_0.png"];
    
    self.cat.position=CGPointMake(CGRectGetMidX(self.table),CGRectGetMidY(self.table));
    [self scaleSpriteNode:self.cat scaleRatio:0.25];
    
    [self addChild:self.cat];
}

-(void)increment:(NSInteger)frameNumber{
    //SKAction * fadetutorial = [SKAction fadeOutWithDuration:1];
    //SKAction * unfadetutorial = [SKAction fadeInWithDuration:0];
    
    if(self.frameNumber==0) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"This is you"];
    }else if(self.frameNumber==1) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"This is your cat (he's a jerk)"];
        [self initializeCat];
    }else if(self.frameNumber==2) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"He likes to knock stuff off of your desk (what a jerk!)"];
        [self addItem];
        //cat move to and flip item
    }else if(self.frameNumber==3) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"Every time he knocks something off of your desk,"];
        self.tutorialLabel2.text = [NSString stringWithFormat:@"your life slowly devolves into chaos,"];
        self.tutorialLabel3.text = [NSString stringWithFormat:@"convieniently tracked by this bar"];
        [self initializeChaosBar];
    }else if(self.frameNumber==4) {
            self.tutorialLabel.text = [NSString stringWithFormat:@"Thankfully you have your patented"];
        self.tutorialLabel2.text = [NSString stringWithFormat:@"Discipline-Omatic-Gun(TM)"];
        self.tutorialLabel3.text = [NSString stringWithFormat:@""];
        [self initializeAimer];
        [self initializeDogBar];
    } else if(self.frameNumber==5) {
        self.tutorialLabel.text = [NSString stringWithFormat:@"Tilt your iPhone to aim your DOG and click to shoot"];
        self.tutorialLabel2.text = [NSString stringWithFormat:@""];
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
    SKSpriteNode * item = [SKSpriteNode spriteNodeWithImageNamed:itemImageURL];
    [self scaleSpriteNode:item scaleRatio:0.3];
    
    // Determine where to spawn the item on the table
    int itemYPostion = 90 + tableCornerY + item.size.height/2;
    int itemXPosition = 10 + tableCornerX + item.size.width/2;
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
    self.tutorialLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
    self.tutorialLabel.fontSize = 15;
    self.tutorialLabel.fontColor = [SKColor blueColor];
    self.tutorialLabel.text = [NSString stringWithFormat:@""];
    self.tutorialLabel.position = CGPointMake(CGRectGetMidX(self.table), CGRectGetMidY(self.table)+70);
    [self addChild:self.tutorialLabel];
    
    self.tutorialLabel2 = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
    self.tutorialLabel2.fontSize = 15;
    self.tutorialLabel2.fontColor = [SKColor blueColor];
    self.tutorialLabel2.text = [NSString stringWithFormat:@""];
    self.tutorialLabel2.position = CGPointMake(CGRectGetMidX(self.table), CGRectGetMidY(self.table)+50);
    [self addChild:self.tutorialLabel2];
    
    self.tutorialLabel3 = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
    self.tutorialLabel3.fontSize = 15;
    self.tutorialLabel3.fontColor = [SKColor blueColor];
    self.tutorialLabel3.text = [NSString stringWithFormat:@""];
    self.tutorialLabel3.position = CGPointMake(CGRectGetMidX(self.table), CGRectGetMidY(self.table)+30);
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
    [self increment:self.frameNumber];
    //}
}

@end

//@interface Tutorial()
//@property (nonatomic) SKSpriteNode * background;
//@property (nonatomic) SKSpriteNode * menu;
//@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
//
//@end
//
//@implementation Tutorial
//
//- (void)scaleSpriteNode:(SKSpriteNode *)sprite scaleRatio:(float)scale
//{
//    sprite.xScale = scale;
//    sprite.yScale = scale;
//}
//
//-(id)initWithSize:(CGSize)size{
//    if (self = [super initWithSize:size]) {
//        
//        //background
//        self.background =[SKSpriteNode spriteNodeWithImageNamed:@"tutorial.png"];
//        self.background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
//        [self scaleSpriteNode:self.background scaleRatio:0.5];
//        [self addChild:self.background];
//        
//        /*//return to menu button
//        self.menu = [SKSpriteNode spriteNodeWithImageNamed:@"return_menu.png"];
//        [self scaleSpriteNode:self.menu scaleRatio:0.5];
//        self.menu.position = CGPointMake(70, 280);
//        self.menu.name = @"menuButton";//how the node is identified later
//        [self addChild:self.menu];*/
//        
//        //for the background music
//        NSError *error;
//        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"Menu" withExtension:@"mp3"];
//        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
//        self.backgroundMusicPlayer.numberOfLoops = -1;
//        [self.backgroundMusicPlayer prepareToPlay];
//        [self.backgroundMusicPlayer play];
//        
//    }
//    return self;
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    //UITouch *touch = [touches anyObject];
//    //CGPoint location = [touch locationInNode:self];
//    //SKNode *node = [self nodeAtPoint:location];
//    
//    //pressed menu button
//    //if ([node.name isEqualToString:@"menuButton"]) {
//        [self.backgroundMusicPlayer stop];
//        SKScene * menu = [[Menu alloc] initWithSize:self.size];
//        [self.view presentScene:menu transition:[SKTransition fadeWithDuration:.5]];
//    //}
//}
//
//@end
