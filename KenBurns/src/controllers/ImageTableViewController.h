//
//  ImageTableViewController.h
//  KenBurns
//
//  Created by Oleg Kovtun on 12.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTableViewController : UITableViewController {
    
}
@property (nonatomic,copy) void(^onDoneBlock)(void);
@end
