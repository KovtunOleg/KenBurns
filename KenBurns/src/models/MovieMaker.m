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
@property (nonatomic,assign) CGSize frameSize;
@property (nonatomic,strong) NSString* presetName;
@property (nonatomic,assign) NSUInteger imageCounter;
@end

@implementation MovieMaker

- (id) init {
    self = [super init];
    if ( self ) {
        self.presetName = [[AVAssetExportSession allExportPresets] containsObject:AVAssetExportPreset1280x720] ? AVAssetExportPreset1280x720 : AVAssetExportPreset640x480;
        self.frameSize =  [self.presetName isEqualToString:AVAssetExportPreset1280x720] ? CGSizeMake(1280, 720) : CGSizeMake(640, 480);
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
    [self updateProgress:0 status:kProgressStatus_Processing];
    
    if ( self.imageCounter > 0 ) {
        __unsafe_unretained MovieMaker* safePointer = self;
        for ( NSMutableDictionary* map in lastAddedMaps ) {
            
            UIImage* image = map[kImage];
            [self createKenBurnsMovie:image];
            [self exportMovieWithCompletionBlock:^(NSString *path, BOOL isOK) {
                
                safePointer.imageCounter--;
                map[kPath] = path;
                [self updateProgress:(float)(lastAddedMaps.count-safePointer.imageCounter)/lastAddedMaps.count status:kProgressStatus_Processing];
                
                if ( 0 == safePointer.imageCounter ) {
                    [safePointer mergeVideosWithCompletionBlock:block];
                }
                
            } path:filePath(videoFolderPath(),image.description,EXT_MP4)];
        }
        
    } else {
        [self mergeVideosWithCompletionBlock:block];
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
    
    __block AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:self.composition presetName:self.presetName];
    exporter.outputURL = [NSURL fileURLWithPath:path];
    exporter.videoComposition = self.videoComposition;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
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

- (void) mergeVideosWithCompletionBlock:(onVideoCreatedBlock)block {
    [self updateProgress:0 status:kProgressStatus_Merging];
    
    self.composition = [AVMutableComposition composition];
    NSMutableArray* layerInstructions = [NSMutableArray array];
    NSMutableArray* brokenMaps = [NSMutableArray array];
    CMTime duration = kCMTimeZero;
    NSArray* paths = [[VideoMap instance] paths];
    
    for (NSString* path in paths ) {
        NSURL *urlVideo = [NSURL fileURLWithPath:path];
        AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:urlVideo options:nil];
        
        if ( [videoAsset tracksWithMediaType:AVMediaTypeVideo].count > 0 ) {
            AVMutableCompositionTrack *track = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeVideo][0] atTime:duration error:nil];
            duration = CMTimeAdd(duration, CMTimeSubtract(videoAsset.duration, CMTimeMake(1, 1)));
            
            AVMutableVideoCompositionLayerInstruction * layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track];
            [layerInstruction setOpacityRampFromStartOpacity:1.0f toEndOpacity:0.0f timeRange:CMTimeRangeMake(duration, CMTimeMake(1, 1))];
            [layerInstructions addObject:layerInstruction];
        } else {
            [brokenMaps addObject:[[VideoMap instance] mapAtIndex:[paths indexOfObject:path]]];
        }
    }
    [self checkBrokenMapsAndSave:brokenMaps];
    
    AVMutableVideoCompositionInstruction * instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.composition.duration);
    instruction.layerInstructions = layerInstructions;
    
    [self updateVideoCompositionWith:instruction animationTool:nil];
    [self exportMovieWithCompletionBlock:block path:RESULT_VIDEO_PATH];
}

- (void) updateProgress:(CGFloat)progress status:(kProgressStatus)status {
    if ( self.onProgressUpdateBlock ) {
        self.onProgressUpdateBlock(progress,status);
    }
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

#pragma mark - UIAlertView

- (void) checkBrokenMapsAndSave:(NSArray*)brokenMaps {
    if ( [brokenMaps count] > 0 ) {
        [[VideoMap instance] removeMaps:brokenMaps];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Some of images are failed to render. Try to re add them." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    [VideoMap saveMaps];
}

@end
