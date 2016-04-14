//
//  DPRDetailViewController.h
//  HingeApp
//
//  Created by David Richardson on 4/13/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPRDetailViewController : UIViewController

// array of imageDownloads
@property (strong, nonatomic) NSMutableArray *imageDownloads;
// index of currentImage
@property NSInteger currIndex;

@end
