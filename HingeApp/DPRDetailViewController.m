//
//  DPRDetailViewController.m
//  HingeApp
//
//  Created by David Richardson on 4/13/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRDetailViewController.h"
#import "DPRImageDownload.h"
#import "DPRTableViewController.h"

@interface DPRDetailViewController()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation DPRDetailViewController


#pragma mark - ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupUI];
    
}

- (void)setupUI {
    
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld", _currIndex + 1, [_imageDownloads count]];
    self.view.backgroundColor = [UIColor blackColor];
    
    // get initial imageDownload
    DPRImageDownload *firstImageDownload = _imageDownloads[_currIndex];
    
    // create imageView (with firstImageDownload.image as image)
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    _imageView.image = firstImageDownload.image;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.autoresizingMask =
    ( UIViewAutoresizingFlexibleBottomMargin
     | UIViewAutoresizingFlexibleHeight
     | UIViewAutoresizingFlexibleLeftMargin
     | UIViewAutoresizingFlexibleRightMargin
     | UIViewAutoresizingFlexibleTopMargin
     | UIViewAutoresizingFlexibleWidth );
    _imageView.clipsToBounds = YES;
    [self.view addSubview:_imageView];
    
    // delete button
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Delete"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(deleteImage:)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    
    
    // animation: next image every 2 seconds
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(nextImage:) userInfo:Nil repeats:YES];
    
}


#pragma mark - Images

// animate next image
- (void)nextImage:(id)sender {
    
    _currIndex++;
    
    // restart loop
    if(_currIndex == [_imageDownloads count]){
        _currIndex = 0;
    }
    // update navigationBar status
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld", _currIndex + 1, [_imageDownloads count]];

    // update imageView image
    DPRImageDownload *imageDownload = _imageDownloads[_currIndex];
    _imageView.image = imageDownload.image;
    
}

- (void)deleteImage:(id)sender {
    
    // stop timer operations
    [self.timer invalidate];
    
    // delete image
    [_imageDownloads removeObjectAtIndex:_currIndex];
    
    // update tableViewController data
    NSArray *viewControllers = self.navigationController.viewControllers;
    DPRTableViewController *tableViewController = (DPRTableViewController *)[viewControllers objectAtIndex:0];
    [tableViewController reloadImages:_imageDownloads];
    
    // return to tableViewController
    [self.navigationController popViewControllerAnimated:YES];
    
}












@end
