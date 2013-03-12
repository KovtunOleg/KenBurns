//
//  Macroses.h
//  LoveItApp
//
//  Created by Alex Antonyuk on 7/2/12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import	<objc/message.h>

#ifndef LoveItApp_Macroses_h
#define LoveItApp_Macroses_h

#define __(str, desc) NSLocalizedString(str, desc)
#define _(str) __(str,@"")

#define __IOS(version) ([getIOSVersion() compare:version options:NSNumericSearch] != NSOrderedAscending)
#define __IOS5		__IOS(IOS_VERSION_5)
#define __IOS6		__IOS(IOS_VERSION_6)

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define __iPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define __iPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define __isRetina [UIScreen mainScreen].scale > 1.0

#define SCREEN_FRAME	[[UIScreen mainScreen] bounds]

#define RAND_IN_RANGE(x, y)	(arc4random() % y) + x

#define HL(x) (x.backgroundColor = [UIColor yellowColor]);

// RESOURCES
#define PATH_FOR_RESOURCE_OF_TYPE(fname, type) [[NSBundle mainBundle] pathForResource:fname ofType:type]
#define PATH_FOR_PNG_RESOURCE(rname) PATH_FOR_RESOURCE_OF_TYPE(rname, PNG)
#define PATH_FOR_JPG_RESOURCE(rname) PATH_FOR_RESOURCE_OF_TYPE(rname, JPG)

#define PNG_IMAGE_WITH_NAME(iname) [UIImage imageWithContentsOfFile: PATH_FOR_PNG_RESOURCE(iname)]
#define JPG_IMAGE_WITH_NAME(iname) [UIImage imageWithContentsOfFile: PATH_FOR_JPG_RESOURCE(iname)]
#define IMAGE_WITH_NAME(iname) [UIImage imageNamed:iname]

// CONVENIENCE
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )

// SHADERS
#define CODE_STRING(code)     @#code

#define SAFE_STRING(s) (s ? s : @"")
#endif

#define CAV(t) [NSValue valueWithCATransform3D:t]
