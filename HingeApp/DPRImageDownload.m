//
//  DPRImageDownload.m
//  HingeApp
//
//  Created by David Richardson on 4/13/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRImageDownload.h"

@implementation DPRImageDownload

- (id)initWithURL:(NSString *)image_url andIndex:(NSInteger)index andImage:(UIImage *)image {
    
    self = [super init];
    
    if(self) {
        
        self.image_url = image_url;
        self.index = index;
        self.image = image;
        
    }
    
    return self;
    
}

@end
