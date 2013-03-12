//
//  MovieMaker.h
//  KenBurns
//
//  Created by Oleg Kovtun on 06.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^onVideoCreatedBlock)(NSString* path, BOOL isOK);

@interface MovieMaker : NSObject {
    
}
@property (nonatomic,assign) CGSize frameSize;
@property (nonatomic,assign) CGFloat imageDuration;
- (void) startRecordingKenBurnsMovieWithCompletionBlock:(onVideoCreatedBlock)block images:(NSArray*)images;
@end
