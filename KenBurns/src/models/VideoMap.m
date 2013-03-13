//
//  VideoMap.m
//  KenBurns
//
//  Created by Oleg Kovtun on 12.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "VideoMap.h"

@interface VideoMap () <NSCopying>
@property (nonatomic,strong) NSMutableArray* maps;
@end

@implementation VideoMap
@synthesize hasChanges = _hasChanges;

VideoMap* gVideoMap = nil;
+ (VideoMap*) instance {
    if ( !gVideoMap ) {
        gVideoMap = [[VideoMap alloc] init];
        gVideoMap.maps = [VideoMap readMaps];
    }
    return gVideoMap;
}

- (void) updateWithVideoMap:(VideoMap*)videoMap {
    [self setMaps:[NSMutableArray arrayWithArray:videoMap.maps]];
}

#pragma mark - Accessors

+ (NSMutableArray*) readMaps {
    NSMutableArray* maps = [NSMutableArray array];
    if( [[NSFileManager defaultManager] fileExistsAtPath:MAP_PATH] ){
        NSData * data = [NSData dataWithContentsOfFile:MAP_PATH];
        maps = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return maps;
}

+ (void) saveMaps {
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:[VideoMap instance].maps];
    [data writeToFile:MAP_PATH atomically:YES];
}

- (void) setMaps:(NSMutableArray *)maps {
    _hasChanges = ![maps isEqualToArray:_maps];
    _lastAddedMaps = [NSMutableArray arrayWithArray:maps];
    [_lastAddedMaps removeObjectsInArray:_maps];
    _lastRemovedMaps = [NSMutableArray arrayWithArray:_maps];
    [_lastRemovedMaps removeObjectsInArray:maps];
    
    _maps = maps;
}

- (NSArray*) images {
    return [self objectsForKey:kImage];
}

- (NSArray*) paths {
    return [self objectsForKey:kPath];
}

- (NSArray*) infos {
    return [self objectsForKey:kInfo];
}

#pragma mark - Manipulation

- (void) addMapWithImage:(UIImage*)image info:(NSString*)info {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjects:@[image,info] forKeys:@[kImage,kInfo]];
    [self.maps addObject:dict];
}

- (void) addPath:(NSString*)path atIndex:(NSUInteger)index {
    NSMutableDictionary* mutDict = self.maps[index];
    mutDict[kPath] = path;
}

- (void) removeMapAtIndex:(NSUInteger)index {
    [self.maps removeObjectAtIndex:index];
}

- (void) removeMaps:(NSArray*)maps {
    [self.maps removeObjectsInArray:maps];
}

- (void) moveMapFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    NSDictionary* dict = [self.maps objectAtIndex:fromIndex];
    [self.maps removeObjectAtIndex:fromIndex];
    if ( toIndex >= self.maps.count ) {
        [self.maps addObject:dict];
    } else {
        [self.maps insertObject:dict atIndex:toIndex];
    }
}

- (NSDictionary*) mapAtIndex:(NSUInteger)index {
    NSDictionary* map = nil;
    if ( [self.maps count] > 0 ) {
        map = [self.maps objectAtIndex:index];
    }
    return map;
}

#pragma mark - Convenience

- (BOOL) containsInfo:(NSString*)info {
    return [[self infos] containsObject:info];
}

- (NSArray*) objectsForKey:(NSString*)key {
    NSMutableArray* images = [NSMutableArray array];
    for (NSDictionary* dict in self.maps) {
        if ( dict[key] ) {
            [images addObject:dict[key]];
        }
    }
    return images;
}

#pragma mark - NSCopying

- (id) copyWithZone:(NSZone *)zone {
    VideoMap* copy = [[[self class] alloc] init];
    if (copy) {
        [copy setMaps:[NSMutableArray arrayWithArray:self.maps]];
    }
    return copy;
}

@end
