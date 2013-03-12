//
//  VideoMap.m
//  KenBurns
//
//  Created by Oleg Kovtun on 12.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "VideoMap.h"

@interface VideoMap () <NSCopying>
@property (nonatomic,strong) NSMutableArray* videos;
@end

@implementation VideoMap

VideoMap* gVideoMap = nil;
+ (VideoMap*) instance {
    if ( !gVideoMap ) {
        gVideoMap = [[VideoMap alloc] init];
        gVideoMap.videos = [NSMutableArray array];
    }
    return gVideoMap;
}

+ (void) updateWithVideoMap:(VideoMap*)videoMap {
    NSLog(@"%@",videoMap.videos);
    [[VideoMap instance] setVideos:[NSMutableArray arrayWithArray:videoMap.videos]];
}

- (void) addImage:(UIImage*)image forKey:(NSString*)key {
    NSDictionary* dict = @{key:[NSMutableDictionary dictionaryWithObject:image forKey:@"image"]};
    [self.videos addObject:dict];
}

- (void) addPath:(NSString*)path forKey:(NSString*)key {
    for (NSDictionary* dict in self.videos) {
        NSMutableDictionary* mutDict = [dict objectForKey:key];
        if ( mutDict ) {
            [mutDict setObject:path forKey:@"path"];
            break;
        }
    }
}

- (void) removeImageAtIndex:(NSUInteger)index {
    [self.videos removeObjectAtIndex:index];
}

- (void) moveImageFromIndex:(NSUInteger)fromIndex atIndex:(NSUInteger)atIndex {
    NSDictionary* dict = [self.videos objectAtIndex:fromIndex];
    [self.videos removeObjectAtIndex:fromIndex];
    if ( atIndex >= self.videos.count ) {
        [self.videos addObject:dict];
    } else {
        [self.videos insertObject:dict atIndex:atIndex];
    }
}

- (NSArray*) images {
    NSMutableArray* images = [NSMutableArray array];
    for (NSDictionary* dict in self.videos) {
        NSDictionary* mutDict = dict.allValues[0];
        [images addObject:mutDict[@"image"]];
    }
    return images;
}

- (NSArray*) paths {
    NSMutableArray* images = [NSMutableArray array];
    for (NSDictionary* dict in self.videos) {
        NSDictionary* mutDict = dict.allValues[0];
        NSString* path = mutDict[@"path"];
        if ( path ) {
            [images addObject:mutDict[path]];
        }
    }
    return images;
}

#pragma mark - NSCopying

- (id) copyWithZone:(NSZone *)zone {
    VideoMap* copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setVideos:[NSMutableArray arrayWithArray:self.videos]];
    }
    
    return copy;
}

@end
