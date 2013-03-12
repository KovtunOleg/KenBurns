//
//  ImageCell.m
//  KenBurns
//
//  Created by Oleg Kovtun on 12.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "ImageCell.h"

@interface ImageCell ()
@property (nonatomic,strong) IBOutlet UIImageView* pictureView;
@end

@implementation ImageCell

+ (ImageCell*) imageCell {
    return (ImageCell*)objectFromNibForClass(@"ImageCell",[self class]);
}

- (void) setImageVideo:(UIImage *)image {
    [self.pictureView setImage:image];
}

+ (CGFloat) height {
    return 150.0f;
}

@end
