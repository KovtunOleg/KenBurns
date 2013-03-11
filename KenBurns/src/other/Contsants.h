//
//  Contsants.h
//  KenBurns
//
//  Created by Oleg Kovtun on 06.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#define __IOS_VERSION                   [[UIDevice currentDevice] systemVersion]
#define __IOS(version)                  ([__IOS_VERSION compare:version options:NSNumericSearch] != NSOrderedAscending)
#define __IOS5                          __IOS(@"5.0")
#define __IOS6                          __IOS(@"6.0")

#define BACKGROUND_QUEUE                dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define DOCUMENT_FOLDER_PATH            NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define DOCUMENT_FILE_PATH(name,format) [NSString stringWithFormat:@"%@/%@.%@",DOCUMENT_FOLDER_PATH,name,format]

#define P(x,y)                          CGPointMake(x, y)
#define SCALE(s)                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(s, s, 1.0)]
#define PLUS_OR_MINUS                   ((arc4random() % 2) * 2 - 1)

#define TEMP_VIDEO                      @"temp"
#define RESULT_VIDEO                    @"result"

#define EXT_MP4                         @"mp4"