//
//  ViewController.m
//  KenBurns
//
//  Created by Oleg Kovtun on 06.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "ViewController.h"
#import "MovieMaker.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()
@property (nonatomic,strong) MPMoviePlayerController* videoPlayer;
@property (nonatomic,strong) MovieMaker* mMaker;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView* activityView;
@end

@implementation ViewController

#pragma mark - Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setupVideoPlayer];
    [self createMovie];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.activityView.center = self.view.center;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (BOOL) shouldAutorotate {
    return YES;
}

#pragma mark - Actions

- (void) playVideo:(NSString*)path {
    [self.videoPlayer setContentURL:[NSURL fileURLWithPath:path]];
    [self.videoPlayer prepareToPlay];
    [self.activityView stopAnimating];
    UISaveVideoAtPathToSavedPhotosAlbum(path,self,@selector(video:didFinishSavingWithError:contextInfo:),nil);
}

#pragma mark - Setups

- (void) setupVideoPlayer {
    self.videoPlayer = [[MPMoviePlayerController alloc] init];
    [self.videoPlayer.view setFrame:self.view.frame];
    self.videoPlayer.repeatMode = MPMovieRepeatModeOne;
    self.videoPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |
                                             UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |
                                             UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.videoPlayer.view];
    [self.view sendSubviewToBack:self.videoPlayer.view];
}

- (void) createMovie {
    NSMutableArray* imagesForVideo = [NSMutableArray array];
    for (NSUInteger i = 1; i <= 5; i++) {
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"Photo_%d.jpg",i]];
        [imagesForVideo addObject:(id)image.CGImage];
    }
    
    __unsafe_unretained ViewController* safePointer = self;
    self.mMaker = [[MovieMaker alloc] init];
    [self.mMaker setImageArray:imagesForVideo];
    [self.mMaker setFrameSize:CGSizeMake(1920, 1080)];
    [self.mMaker setDuration:25];
    [self.mMaker startRecordingKenBurnsMovieWithCompletionBlock:^(NSString *path, BOOL isOK) {
        if ( isOK ) {
            NSLog(@"Succcess!");
            [safePointer playVideo:path];
        } else {
            NSLog(@"Fail!");
        }
    }];
}

#pragma mark - Video saving delegate

- (void) video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( !error ) {
        NSLog(@"Video saved to album!");
    } else {
        NSLog(@"%@",error.description);
    }
}

@end
