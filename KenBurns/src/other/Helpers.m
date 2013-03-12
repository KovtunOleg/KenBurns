//
//  Helpers.m
//  KenBurns
//
//  Created by Oleg Kovtun on 12.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "Helpers.h"

NSString* getIOSVersion() {
	return [[UIDevice currentDevice] systemVersion];
}

BOOL isIOSVersionAvailable(NSString* version) {
    return ([getIOSVersion() compare:version options:NSNumericSearch] != NSOrderedAscending);
}

BOOL isStringWithAnyText(NSString* s) {
	return nil!=s && [s length] > 0;
}

id firstOrNil(NSArray* arr) {
	if ([arr count]>0) {
		return [arr objectAtIndex:0];
	}
	return nil;
}

dispatch_queue_t backgroundQueue(void) {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

NSObject* objectFromNibForClass(NSString* nibName,Class class) {
    NSObject* neededObject = nil;
    for (NSObject*object in [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil]) {
        if ( [object isKindOfClass:[class class]] ) {
            neededObject = object;
            break;
        }
    }
    return neededObject;
}

NSString* documentFolderPath(void) {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

NSString* videoFolderPath(void) {
    return [documentFolderPath() stringByAppendingPathComponent:VIDEOS_FOLDER];
}

NSString* filePath(NSString* folder,NSString* name,NSString* format) {
    return [NSString stringWithFormat:@"%@/%@.%@",folder,name,format];
}

CGPoint P(CGFloat x,CGFloat y) {
    return CGPointMake(x, y);
}

NSValue* S(CGFloat s) {
    return [NSValue valueWithCATransform3D:CATransform3DMakeScale(s, s, 1.0)];
}

NSInteger plusOrMinus(void) {
    return ((arc4random() % 2) * 2 - 1);
}               