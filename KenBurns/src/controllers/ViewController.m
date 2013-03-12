//
//  ViewController.m
//  KenBurns
//
//  Created by Oleg Kovtun on 06.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "ViewController.h"
#import "ImageTableViewController.h"
#import "MovieMaker.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()
@property (nonatomic,strong) MPMoviePlayerController* videoPlayer;
@property (nonatomic,strong) MovieMaker* mMaker;
@property (nonatomic,strong) MBProgressHUD* progressHUD;
@end

@implementation ViewController

#pragma mark - Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setupEditButton];
    [self setupVideoPlayer];
    [self setupProgressHUD];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.progressHUD.center = self.view.center;
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
    [self.videoPlayer play];
    UISaveVideoAtPathToSavedPhotosAlbum(path,self,@selector(video:didFinishSavingWithError:contextInfo:),nil);
}

- (void) editButtonAction {
    ImageTableViewController* imageTableVC = [[ImageTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    imageTableVC.onDoneBlock = ^ {
        [self createMovie];
    };
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:imageTableVC];
    [self presentModalViewController:navController animated:YES];
}

#pragma mark - Setups

- (void) setupEditButton {
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void) setupProgressHUD {
    self.progressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.progressHUD.autoresizingMask = self.videoPlayer.view.autoresizingMask;
    [self.progressHUD setLabelText:@"Processing video..."];
    [self.view addSubview:self.progressHUD];
}

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
    [self.progressHUD show:YES];
    
    __unsafe_unretained ViewController* safePointer = self;
    self.mMaker = [[MovieMaker alloc] init];
    [self.mMaker setFrameSize:CGSizeMake(640, 360)];
    [self.mMaker setImageDuration:3];
    [self.mMaker startRecordingKenBurnsMovieWithCompletionBlock:^(NSString *path, NSUInteger index, BOOL isOK) {
        [self.progressHUD hide:YES];
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
