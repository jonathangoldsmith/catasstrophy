//
//  GameOverScreen.h
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 2/25/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface GameOverScreen : SKScene{
@public
    int highScore;
    BOOL played;
}

-(id)initWithSize:(CGSize)size score:(NSInteger)score;

-(IBAction)SaveData;
-(IBAction)LoadData;

@end
