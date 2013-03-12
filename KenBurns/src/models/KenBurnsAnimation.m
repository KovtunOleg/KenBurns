//
//  KenBurnsAnimation.m
//  KenBurns
//
//  Created by Oleg Kovtun on 12.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "KenBurnsAnimation.h"
#import <QuartzCore/QuartzCore.h>

#define MIN_SCALE       1.1 // must be more then 1.0
#define MAX_SCALE       2.0

@interface KenBurnsAnimation ()
@property (nonatomic,strong) NSArray* images;
@property (nonatomic,assign) CGSize frameSize;
@property (nonatomic,assign) CGFloat duration;
@end

@implementation KenBurnsAnimation

KenBurnsAnimation* gKenBurnsAnimation = nil;
+ (KenBurnsAnimation*) instance {
    if ( !gKenBurnsAnimation ) {
        gKenBurnsAnimation = [[KenBurnsAnimation alloc] init];
    }
    return gKenBurnsAnimation;
}

+ (CALayer*) buildKenBurnsLayer:(NSArray*)images frameSize:(CGSize)frameSize duration:(CGFloat)duration {
    KenBurnsAnimation* kenBurnsAnimation = [KenBurnsAnimation instance];
    [kenBurnsAnimation setImages:images];
    [kenBurnsAnimation setFrameSize:frameSize];
    [kenBurnsAnimation setDuration:duration];
    return [kenBurnsAnimation buildKenBurnsLayer];
}

- (void) setImages:(NSArray *)images {
    NSMutableArray* cgImages = [NSMutableArray arrayWithCapacity:images.count];
    for (UIImage* image in images) {
        [cgImages addObject:(id)image.CGImage];
    }
    _images = [NSArray arrayWithArray:cgImages];
}

#pragma mark - Ken Berns Animation

- (CALayer*) buildKenBurnsLayer {
    
    CALayer* imageLayer    = [CALayer layer];
    imageLayer.bounds      = (CGRect){CGPointZero,self.frameSize};
    imageLayer.contentsGravity = kCAGravityResizeAspect;
    
    [imageLayer addAnimation:[self kenBurnsAnimation] forKey:@"KenBurns"];
    
    return imageLayer;
}

- (CAAnimationGroup*) kenBurnsAnimation {
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    anim.values = self.images;
    anim.keyTimes = [self keyTimes];
    
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = [self trackPath].CGPath;
    moveAnim.additive = YES;
    moveAnim.removedOnCompletion = NO;
    
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnim.values = [self scaleArray];
    scaleAnim.removedOnCompletion = NO;
    scaleAnim.additive = YES;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = @[anim,moveAnim,scaleAnim];
    animGroup.beginTime = 1e-100;
    animGroup.duration = self.duration;
    animGroup.removedOnCompletion = NO;
    return animGroup;
}

- (NSArray*) keyTimes {
    NSMutableArray* keyTimes = [NSMutableArray arrayWithCapacity:[self.images count]];
    CGFloat step = 1./[self.images count];
    CGFloat keyTime = step;
    for (UIImage* image in self.images) {
        [keyTimes addObject:@(keyTime)];
        keyTime += step;
    }
    return keyTimes;
}

- (UIBezierPath*) trackPath {
    UIBezierPath *trackPath = [UIBezierPath bezierPath];
    CGPoint startPoint = P(self.frameSize.width/2,self.frameSize.height/2);
    int maxDeviation = MIN(self.frameSize.width,self.frameSize.height)*(MIN_SCALE-1);
	[trackPath moveToPoint:startPoint];
    for (UIImage* image in self.images) {
        NSInteger dx = (arc4random()%maxDeviation)*PLUS_OR_MINUS;
        NSInteger dy = (arc4random()%maxDeviation)*PLUS_OR_MINUS;
        [trackPath addLineToPoint:P(startPoint.x+dx, startPoint.y+dy)];
    }
    return trackPath;
}

- (NSArray*) scaleArray {
    NSMutableArray* scaleArray = [NSMutableArray arrayWithCapacity:[self.images count]];
    for (UIImage* image in self.images) {
        float scale = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * MAX_SCALE) + MIN_SCALE;
        [scaleArray addObject:SCALE(scale)];
    }
    return scaleArray;
}

@end
