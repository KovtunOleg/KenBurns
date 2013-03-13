//
//  MovieMaker.h
//  KenBurns
//
//  Created by Oleg Kovtun on 06.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^onVideoCreatedBlock)(NSString* path, BOOL isOK);

enum {
    kProgressStatus_Processing = 0,
    kProgressStatus_Merging
} typedef kProgressStatus;

@interface MovieMaker : NSObject {
    
}
@property (nonatomic,assign) CGFloat imageDuration;
@property (nonatomic,copy) void(^onProgressUpdateBlock)(CGFloat progress,kProgressStatus status);
- (void) startRecordingKenBurnsMovieWithCompletionBlock:(onVideoCreatedBlock)block;
@end
