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
    
    DPRImageDownload *imageDownload = _imageDownloads[_currIndex];
    
    // imageView
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    _imageView.image = imageDownload.image;
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
    
    
    // animation
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(nextImage:) userInfo:Nil repeats:YES];
    
}


#pragma mark - Animation

// animate next image
- (void)nextImage:(id)sender {
    
    _currIndex++;
    
    // start again
    if(_currIndex == [_imageDownloads count]){
        _currIndex = 0;
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld", _currIndex + 1, [_imageDownloads count]];

    DPRImageDownload *imageDownload = _imageDownloads[_currIndex];
    _imageView.image = imageDownload.image;
    
}

- (void)deleteImage:(id)sender {
    
    [self.timer invalidate];
    
    [_imageDownloads removeObjectAtIndex:_currIndex];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    DPRTableViewController *tableViewController = (DPRTableViewController *)[viewControllers objectAtIndex:0];
    
    [tableViewController reloadImages:_imageDownloads];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}












@end
