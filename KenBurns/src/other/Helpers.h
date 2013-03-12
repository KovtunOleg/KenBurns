//
//  Helpers.h
//  KenBurns
//
//  Created by Oleg Kovtun on 12.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* getIOSVersion();
BOOL isIOSVersionAvailable(NSString* version);

BOOL isStringWithAnyText(NSString* s);
NSObject* firstOrNil(NSArray* arr);

dispatch_queue_t backgroundQueue();

NSObject* objectFromNibForClass(NSString* nibName, Class class);

NSString* documentFolderPath(void);
NSString* videoFolderPath(void);
NSString* filePath(NSString* folder,NSString* name,NSString* format);

CGPoint P(CGFloat x,CGFloat y);
NSValue* S(CGFloat s);
NSInteger plusOrMinus(void);