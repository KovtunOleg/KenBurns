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

- (void) addImage:(UIImage*)image forKey:(NSString*)key;
- (void) addPath:(NSString*)path forKey:(NSString*)key;
- (void) removeImageAtIndex:(NSUInteger)index;
- (void) moveImageFromIndex:(NSUInteger)fromIndex atIndex:(NSUInteger)atIndex;

- (NSArray*) images;
- (NSArray*) paths;
@end
