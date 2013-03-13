//
//  ViewController.m
//  KenBurns
//
//  Created by Oleg Kovtun on 06.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "ViewController.h"
#import "VideoMap.h"
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
    self.title = @"Result Movie";
    [self setupNavigationButtons];
    [self setupVideoPlayer];
    [self setupMovieMaker];
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
    [self.videoPlayer.view setHidden:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.videoPlayer setContentURL:[NSURL fileURLWithPath:path]];
    [self.videoPlayer play];
}

- (void) stopVideo {
    [self.progressHUD show:YES];
    [self.videoPlayer.view setHidden:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.videoPlayer stop];
}

- (void) editButtonAction {
    ImageTableViewController* imageTableVC = [[ImageTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    imageTableVC.onDoneBlock = ^ {
        if ( [[VideoMap instance] hasChanges] ) {
            [self createMovie];
        }
    };
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:imageTableVC];
    [self presentModalViewController:navController animated:YES];
}

- (void) saveButtonAction {
    NSURL *url = self.videoPlayer.contentURL;
    UISaveVideoAtPathToSavedPhotosAlbum(url.absoluteString,self,@selector(video:didFinishSavingWithError:contextInfo:),nil);
}

#pragma mark - Setups

- (void) setupMovieMaker {
    self.mMaker = [[MovieMaker alloc] init];
    [self.mMaker setFrameSize:__iPhone?CGSizeMake(640, 360):CGSizeMake(1280, 720)];
    [self.mMaker setImageDuration:5];
}

- (void) setupNavigationButtons {
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction)];
    self.navigationItem.leftBarButtonItem = editButton;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonAction)];
    self.navigationItem.rightBarButtonItem = saveButton;
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
    [self.videoPlayer.view setHidden:YES];
    
    NSString* path = filePath(documentFolderPath(),RESULT_VIDEO,EXT_MP4);
    if( [[NSFileManager defaultManager] fileExistsAtPath:path] ){
        [self playVideo:path];
    }
}

- (void) createMovie {
    [self stopVideo];
    
    __unsafe_unretained ViewController* safePointer = self;
    [self.mMaker startRecordingKenBurnsMovieWithCompletionBlock:^(NSString *path, BOOL isOK) {
        [self.progressHUD hide:YES];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];

        if ( isOK ) {
            [safePointer playVideo:path];
        } else {
            if( [[NSFileManager defaultManager] fileExistsAtPath:path] ){
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
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
