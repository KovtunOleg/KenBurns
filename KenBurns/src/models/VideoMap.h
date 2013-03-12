//
//  VideoMap.h
//  KenBurns
//
//  Created by Oleg Kovtun on 12.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoMap : NSObject {
    
}
+ (VideoMap*) instance;
+ (void) updateWithVideoMap:(VideoMap*)videoMap;

- (void) addMapWithImage:(UIImage*)image info:(NSString*)info;

- (void) addPath:(NSString*)path atIndex:(NSUInteger)index;
- (void) removeMapAtIndex:(NSUInteger)index;
- (void) moveMapFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (NSArray*) images;
- (NSArray*) paths;
- (NSArray*) infos;

- (BOOL) containsInfo:(NSString*)info;
@end
