//
//  MovieViewController.m
//  catasstrophy
//
//  Created by CSB313CignaFL13 on 3/21/14.
//  Copyright (c) 2014 nest. All rights reserved.
//

#import "MovieViewController.h"

@interface MovieViewController ()
@property (nonatomic) MPMoviePlayerController *moviePlayer;
@end

@implementation MovieViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *moviePath = [bundle pathForResource:@"introScene" ofType:@"mov"];
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    
    self.moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:movieURL];
    self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    self.moviePlayer.view.transform = CGAffineTransformConcat(self.moviePlayer.view.transform, CGAffineTransformMakeRotation(M_PI_2));
    UIWindow *backgroundWindow = [[UIApplication sharedApplication] keyWindow];
    [self.moviePlayer.view setFrame:backgroundWindow.frame];
    [backgroundWindow addSubview:self.moviePlayer.view];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    [self.moviePlayer play];
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
