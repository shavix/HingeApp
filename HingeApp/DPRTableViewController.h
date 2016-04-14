//
//  DPRCollectionVC.h
//  HingeApp
//
//  Created by David Richardson on 4/12/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPRTableViewController : UITableViewController <NSURLSessionDelegate>

// on delete clicked in detailViewController: reload imageDownloads data
- (void)reloadImages:(NSMutableArray *)images;

@end
