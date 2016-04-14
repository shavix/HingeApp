//
//  DPRImageDownload.h
//  HingeApp
//
//  Created by David Richardson on 4/13/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DPRImageDownload : NSObject

// init
- (id)initWithURL:(NSString *)url andIndex:(NSInteger)index andImage:(UIImage *)image;

@property (strong, nonatomic) NSString *image_url;
@property (strong, nonatomic) UIImage *image;
@property NSInteger index;
// to identify NSURLSessionTask
@property NSInteger taskIdentifier;

@end
