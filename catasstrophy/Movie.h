//
//  Movie.h
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/26/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface Movie : SKScene {
    @public
    int highScore;
}

-(id)initWithSize:(CGSize)size;

-(IBAction)LoadData;


@end
