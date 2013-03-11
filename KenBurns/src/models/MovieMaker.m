//
//  MovieMaker.m
//  KenBurns
//
//  Created by Oleg Kovtun on 06.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "MovieMaker.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#include <stdlib.h>

#define MIN_SCALE       1.1 // must be more then 1.0
#define MAX_SCALE       2.0

@interface MovieMaker ()
@property (nonatomic,strong) AVMutableComposition* cmp;
@property (nonatomic,strong) AVMutableVideoComposition* animComp;
@end

@implementation MovieMaker

- (id) init {
    self = [super init];
    if ( self ) {
        self.frameSize = CGSizeMake(320, 480); // default video frame size
        self.duration = 15; // default video duration
    }
    return self;
}

#pragma mark - Movie creation methods

- (void) startRecordingKenBurnsMovieWithCompletionBlock:(onVideoCreatedBlock)block {
    [self createKenBurnsMovie];
    [self exportMovieWithCompletionBlock:block];
}

- (void) createKenBurnsMovie {
    CMTimeRange videoRange =  CMTimeRangeMake(kCMTimeZero, CMTimeMake(self.duration, 1));
    CALayer *aLayer = [self buildKenBurnsLayer];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:TEMP_VIDEO ofType:EXT_MP4]];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    self.cmp = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *trackA = [self.cmp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *sourceVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [trackA insertTimeRange:videoRange ofTrack:sourceVideoTrack atTime:kCMTimeZero error:nil];
    
    self.animComp = [AVMutableVideoComposition videoComposition];
    self.animComp.renderSize = self.frameSize;
    self.animComp.frameDuration = CMTimeMake(1,30);
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = videoLayer.frame = (CGRect){CGPointZero,self.frameSize};
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:aLayer];
    self.animComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = videoRange;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:trackA];
    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
    instruction.layerInstructions = @[layerInstruction];
    self.animComp.instructions = @[instruction];
}

-(void) exportMovieWithCompletionBlock:(onVideoCreatedBlock)block {
    NSString *fileName = DOCUMENT_FILE_PATH(RESULT_VIDEO,EXT_MP4);
    if( [[NSFileManager defaultManager] fileExistsAtPath:fileName] ){
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    }
    
    __block AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:self.cmp presetName:AVAssetExportPreset640x480];
    exporter.outputURL = [NSURL fileURLWithPath:fileName];
    exporter.videoComposition = self.animComp;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    [exporter exportAsynchronouslyWithCompletionHandler:^(void){
        if ( block ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(fileName,exporter.status == AVAssetExportSessionStatusCompleted);
            });
        }
    }];
}

#pragma mark - Ken Berns Animation

- (CALayer*) buildKenBurnsLayer {
    
    CALayer* imageLayer    = [CALayer layer];
    imageLayer.bounds      = (CGRect){CGPointZero,self.frameSize};
    imageLayer.contentsGravity = kCAGravityResizeAspect;
    
    [imageLayer addAnimation:[self KenBurnsAnimation] forKey:@"KenBurns"];
    
    return imageLayer;
}

- (CAAnimationGroup*) KenBurnsAnimation {
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    anim.values = self.imageArray;
    anim.keyTimes = [self keyTimes];
    
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = [self trackPath].CGPath;
    moveAnim.additive = YES;
    moveAnim.removedOnCompletion = NO;
    
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnim.values = [self scaleArray];
    scaleAnim.removedOnCompletion = NO;
    scaleAnim.additive = YES;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = @[anim,moveAnim,scaleAnim];
    animGroup.beginTime = 1e-100;
    animGroup.duration = self.duration;
    animGroup.removedOnCompletion = NO;
    return animGroup;
}

- (NSArray*) keyTimes {
    NSMutableArray* keyTimes = [NSMutableArray arrayWithCapacity:[self.imageArray count]];
    CGFloat step = 1./[self.imageArray count];
    CGFloat keyTime = step;
    for (UIImage* image in self.imageArray) {
        [keyTimes addObject:@(keyTime)];
        keyTime += step;
    }
    return keyTimes;
}

- (UIBezierPath*) trackPath {
    UIBezierPath *trackPath = [UIBezierPath bezierPath];
    CGPoint startPoint = P(self.frameSize.width/2,self.frameSize.height/2);
    int maxDeviation = MIN(self.frameSize.width,self.frameSize.height)*(MIN_SCALE-1);
	[trackPath moveToPoint:startPoint];
    for (UIImage* image in self.imageArray) {
        NSInteger dx = (arc4random()%maxDeviation)*PLUS_OR_MINUS;
        NSInteger dy = (arc4random()%maxDeviation)*PLUS_OR_MINUS;
        [trackPath addLineToPoint:P(startPoint.x+dx, startPoint.y+dy)];
    }
    return trackPath;
}

- (NSArray*) scaleArray {
    NSMutableArray* scaleArray = [NSMutableArray arrayWithCapacity:[self.imageArray count]];
    for (UIImage* image in self.imageArray) {
        float scale = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * MAX_SCALE) + MIN_SCALE;
        [scaleArray addObject:SCALE(scale)];
    }
    return scaleArray;
}

@end
