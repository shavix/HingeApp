//
//  DPRCollectionVC.m
//  HingeApp
//
//  Created by David Richardson on 4/12/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRTableViewController.h"
#import "DPRTableViewCell.h"
#import "DPRImageDownload.h"
#import "DPRDetailViewController.h"

// AFNetworking
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

static NSString *dataFeedURL = @"https://hinge-homework.s3.amazonaws.com/client/services/homework.json";
static NSString *segueIdentifier = @"detailSegue";

@interface DPRTableViewController()

@property NSInteger currIndex;

@property (strong, nonatomic) NSMutableArray *imageDownloads;
@property (strong, nonatomic) NSURLSession *urlSession;

@end

@implementation DPRTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:54.f/255.f green:69.f/255.f blue:79.f/255.f alpha:1.f];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    [self fetchImages];
    
}


#pragma mark - Images

- (void)fetchImages {
    
    // array of downloads
    self.imageDownloads = [[NSMutableArray alloc] init];
    
    // create request
    NSURL *url = [NSURL URLWithString:dataFeedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    // on request success
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSDictionary *imageDict = (NSDictionary *)responseObject;
        NSInteger index = 0;
        for(NSDictionary *image in imageDict) {
            
            NSString *image_url = [image objectForKey:@"imageURL"];
            UIImage *loadingImage = [UIImage imageNamed:@"loading"];
            // add imageDownload object to array
            DPRImageDownload *imageDownload = [[DPRImageDownload alloc] initWithURL:image_url andIndex:index andImage:loadingImage];
            index++;
            [_imageDownloads addObject:imageDownload];
            [self downloadImage:imageDownload];
        }
        
        [self.tableView reloadData];

        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Error" message:@"error retrieving images" preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alertView animated:YES completion:nil];
        
    }];
    
    [operation start];
    
}

- (void)downloadImage:(DPRImageDownload *)imageDownload {
    
    NSURL *url = [NSURL URLWithString:imageDownload.image_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionTask *task = [_urlSession downloadTaskWithRequest:request];
    
    imageDownload.taskIdentifier = task.taskIdentifier;

    [task resume];
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{

    NSInteger imageIndex = 0;
    
    for(DPRImageDownload *imageDownload in _imageDownloads) {
        
        if(imageDownload.taskIdentifier == downloadTask.taskIdentifier) {
            
            imageIndex = imageDownload.index;
            
        }
    }
    
    DPRImageDownload *imageDownload = _imageDownloads[imageIndex];
    NSData *data = [NSData dataWithContentsOfURL:location];
    UIImage *image = [UIImage imageWithData:data];
    UIImage *noImage = [UIImage imageNamed:@"no_image"];
    if(image == nil) {
        imageDownload.image = noImage;
        imageDownload.cantLoad = YES;
    }
    else{
        imageDownload.image = image;
    }
    
    
    NSArray *paths = @[[NSIndexPath indexPathForRow:imageIndex inSection:0]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    });
    
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown transfer size");
    }
    else{
        
    }
}



#pragma mark - UITableView


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_imageDownloads count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 300.0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DPRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
    cell.contentMode = UIViewContentModeScaleToFill;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.backgroundColor = [UIColor whiteColor];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if(_imageDownloads){
        
        DPRImageDownload *imageDownload = _imageDownloads[indexPath.row];

        cell.imageView.image = imageDownload.image;
    }
    
    return cell;
    
}


#pragma mark - Segue


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.currIndex = indexPath.row;
    [self performSegueWithIdentifier:segueIdentifier sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:segueIdentifier]) {
        
        DPRDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.imageDownloads = _imageDownloads;
        detailViewController.currIndex = _currIndex;
        
    }
    
}

- (void)reloadImages:(NSMutableArray *)images {
    
    self.imageDownloads = images;
    
    [self.tableView reloadData];
    
}









@end
