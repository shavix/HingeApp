//
//  DPRTableViewCell.m
//  HingeApp
//
//  Created by David Richardson on 4/13/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRTableViewCell.h"

@implementation DPRTableViewCell


// update cell UI
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // UI work
    self.imageView.frame = CGRectMake(10,10,self.contentView.frame.size.width - 20,280);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.autoresizingMask =
    ( UIViewAutoresizingFlexibleBottomMargin
     | UIViewAutoresizingFlexibleHeight
     | UIViewAutoresizingFlexibleLeftMargin
     | UIViewAutoresizingFlexibleRightMargin
     | UIViewAutoresizingFlexibleTopMargin
     | UIViewAutoresizingFlexibleWidth );
    //self.imageView.clipsToBounds = YES;
    [self.contentView.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.contentView.layer setBorderWidth:1.0f];
    self.backgroundColor = [UIColor colorWithRed:54.f/255.f green:69.f/255.f blue:79.f/255.f alpha:1.f];
    
}

@end
