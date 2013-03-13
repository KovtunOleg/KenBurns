//
//  Contsants.h
//  KenBurns
//
//  Created by Oleg Kovtun on 06.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#include <stdlib.h>

#define __iPhone                        isCurrentDevice(UIUserInterfaceIdiomPhone)
#define __iPad                          isCurrentDevice(UIUserInterfaceIdiomPad)

#define __IOS5                          isIOSVersionAvailable(@"5.0")
#define __IOS6                          isIOSVersionAvailable(@"6.0")

#define TEMP_VIDEO                      @"temp"
#define RESULT_VIDEO                    @"result"
#define VIDEOS_FOLDER                   @"videos"
#define MAPS                            @"maps"

#define EXT_MP4                         @"mp4"
#define EXT_PLIST                       @"plist"

#define RESULT_VIDEO_PATH               filePath(documentFolderPath(),RESULT_VIDEO,EXT_MP4)
#define MAP_PATH                        filePath(videoFolderPath(),MAPS,EXT_PLIST)