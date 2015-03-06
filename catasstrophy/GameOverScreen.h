//
//  GameOverScreen.h
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 2/25/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>

@interface GameOverScreen : SKScene  {
@public
    NSUInteger highScore;
} 

-(id)initWithSize:(CGSize)size score:(NSInteger)score;

-(IBAction)SaveData;
-(IBAction)LoadData;
-(void)authenticateLocalPlayer;


@end
