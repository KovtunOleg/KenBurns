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
@property (nonatomic,strong) ImageTableViewController* imageTableVC;
@end

@implementation ViewController

#pragma mark - Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setupImageTableViewController];
    [self setupEditButton];
    [self setupVideoPlayer];
    [self createMovie];
    [self setupProgressHUD];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.progressHUD.center = self.view.center;
    self.progressHUD.autoresizingMask = self.videoPlayer.view.autoresizingMask;
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
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:self.imageTableVC];
    [self presentModalViewController:navController animated:YES];
}

#pragma mark - Setups

- (void) setupImageTableViewController {
    self.imageTableVC = [[ImageTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
}

- (void) setupEditButton {
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void) setupProgressHUD {
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.progressHUD setLabelText:@"Please wait..."];
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
    NSMutableArray* imagesForVideo = [NSMutableArray array];
    for (NSUInteger i = 1; i <= 5; i++) {
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"Photo_%d.jpg",i]];
        [imagesForVideo addObject:image];
    }
    
    __unsafe_unretained ViewController* safePointer = self;
    self.mMaker = [[MovieMaker alloc] init];
    [self.mMaker setFrameSize:CGSizeMake(640, 360)];
    [self.mMaker setImageDuration:3];
    [self.mMaker startRecordingKenBurnsMovieWithCompletionBlock:^(NSString *path, BOOL isOK) {
        [self.progressHUD hide:YES];
        if ( isOK ) {
            NSLog(@"Succcess!");
            [safePointer playVideo:path];
        } else {
            NSLog(@"Fail!");
        }
    } images:imagesForVideo];
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
