//
//  Logo.h
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/25/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Logo : SKScene{
@public
    int highScore;
    
}

-(id)initWithSize:(CGSize)size;

-(IBAction)LoadData;

@end
