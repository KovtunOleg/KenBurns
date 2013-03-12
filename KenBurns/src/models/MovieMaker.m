//
//  MovieMaker.m
//  KenBurns
//
//  Created by Oleg Kovtun on 06.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "MovieMaker.h"
#import "VideoMap.h"
#import "KenBurnsAnimation.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

@interface MovieMaker ()
@property (nonatomic,strong) AVMutableComposition* composition;
@property (nonatomic,strong) AVMutableVideoComposition* videoComposition;
@property (nonatomic,assign) NSUInteger imageCounter;
@end

@implementation MovieMaker

- (id) init {
    self = [super init];
    if ( self ) {
        self.frameSize = CGSizeMake(640, 360); // default video frame size
        self.imageDuration = 5; // default image duration
        [self createVideosFolder];
    }
    return self;
}

#pragma mark - Movie creation methods

- (void) startRecordingKenBurnsMovieWithCompletionBlock:(onVideoCreatedBlock)block {
    [self removeDeletedVideos];
    
    NSArray* lastAddedMaps = [[VideoMap instance] lastAddedMaps];
    self.imageCounter = [lastAddedMaps count];
    
    if ( self.imageCounter > 0 ) {
        __unsafe_unretained MovieMaker* safePointer = self;
        for ( NSMutableDictionary* map in lastAddedMaps ) {
            
            UIImage* image = map[kImage];
            [self createKenBurnsMovie:image];
            [self exportMovieWithCompletionBlock:^(NSString *path, BOOL isOK) {
                
                safePointer.imageCounter--;
                map[kPath] = path;
                if ( 0 == safePointer.imageCounter ) {
                    [VideoMap saveMaps];
                    [safePointer mergeVideos];
                    [safePointer exportMovieWithCompletionBlock:block path:filePath(documentFolderPath(),RESULT_VIDEO,EXT_MP4)];
                }
                
                
            } path:filePath(videoFolderPath(),image.description,EXT_MP4)];
        }
        
    } else {
        [self mergeVideos];
        [self exportMovieWithCompletionBlock:block path:filePath(documentFolderPath(),RESULT_VIDEO,EXT_MP4)];
    }
}

- (void) createKenBurnsMovie:(UIImage*)image {
    CMTimeRange videoRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(self.imageDuration, 1));
    CALayer *aLayer = [KenBurnsAnimation buildKenBurnsLayer:@[image] frameSize:self.frameSize duration:self.imageDuration];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:TEMP_VIDEO ofType:EXT_MP4]];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    self.composition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *track = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [track insertTimeRange:videoRange ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = videoLayer.frame = (CGRect){CGPointZero,self.frameSize};
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:aLayer];

    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = videoRange;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track];
    instruction.layerInstructions = @[layerInstruction];
    
    [self updateVideoCompositionWith:instruction
                       animationTool:[AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer]];
}

-(void) exportMovieWithCompletionBlock:(onVideoCreatedBlock)block path:(NSString*)path {
    [self removeFile:path];
    
    __block AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:self.composition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = [NSURL fileURLWithPath:path];
    exporter.videoComposition = self.videoComposition;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if ( block ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(path,exporter.status == AVAssetExportSessionStatusCompleted);
            });
        }
    }];
}

- (void) updateVideoCompositionWith:(AVMutableVideoCompositionInstruction*)instruction animationTool:(AVVideoCompositionCoreAnimationTool*)animationTool {
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    self.videoComposition.renderSize = self.frameSize;
    self.videoComposition.frameDuration = CMTimeMake(1,30);
    self.videoComposition.instructions = @[instruction];
    self.videoComposition.animationTool = animationTool;
}

- (void) mergeVideos {
    
    self.composition = [AVMutableComposition composition];
    NSMutableArray* layerInstructions = [NSMutableArray array];
    CMTime duration = kCMTimeZero;
    for (NSString* path in [[VideoMap instance] paths] ) {
        NSURL *urlVideo = [NSURL fileURLWithPath:path];
        AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:urlVideo options:nil];
        
        AVMutableCompositionTrack *track = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:duration error:nil];
        duration = CMTimeAdd(duration, CMTimeSubtract(videoAsset.duration, CMTimeMake(1, 1)));
        
        AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track];
        [layerInstruction setOpacityRampFromStartOpacity:1.0f toEndOpacity:0.0f timeRange:CMTimeRangeMake(duration, CMTimeMake(1, 1))];
        [layerInstructions addObject:layerInstruction];
    }
    
    AVMutableVideoCompositionInstruction * instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.composition.duration);
    instruction.layerInstructions = layerInstructions;
    
    [self updateVideoCompositionWith:instruction animationTool:nil];
}

#pragma mark - Directory manipulations

- (void) removeDeletedVideos {
    dispatch_async(backgroundQueue(), ^{
        for ( NSMutableDictionary* map in [[VideoMap instance] lastRemovedMaps] ) {
            [self removeFile:map[kPath]];
        }
    });
}

- (void) removeFile:(NSString*)path {
    if( [[NSFileManager defaultManager] fileExistsAtPath:path] ){
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (void) createVideosFolder {
    NSString* videosFolderPath = videoFolderPath();
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:videosFolderPath isDirectory:nil] ) {
        [[NSFileManager defaultManager] createDirectoryAtPath:videosFolderPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

@end
