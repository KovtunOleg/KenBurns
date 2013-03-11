//
//  MovieMaker.h
//  KenBern
//
//  Created by Oleg Kovtun on 06.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^onVideoCreatedBlock)(NSString* path, BOOL isOK);

@interface MovieMaker : NSObject {
    
}
@property (nonatomic,unsafe_unretained) NSArray* imageArray; // array of CGImages
@property (nonatomic,assign) CGSize frameSize;
@property (nonatomic,assign) CGFloat duration;
- (void) startRecordingKenBernsMovieWithCompletionBlock:(onVideoCreatedBlock)block;
@end