//
//  KenBurnsAnimation.h
//  KenBurns
//
//  Created by Oleg Kovtun on 12.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KenBurnsAnimation : NSObject {
    
}
+ (CALayer*) buildKenBurnsLayer:(NSArray*)images frameSize:(CGSize)frameSize duration:(CGFloat)duration;
@end
