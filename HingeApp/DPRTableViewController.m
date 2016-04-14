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


#pragma mark - TableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
   
    [self setupUI];
    
    [self fetchImages];
    
}

- (void)setupUI {
    
    self.navigationItem.title = [NSString stringWithFormat:@"Images"];
    self.view.backgroundColor = [UIColor colorWithRed:54.f/255.f green:69.f/255.f blue:79.f/255.f alpha:1.f];

}


#pragma mark - Images

- (void)fetchImages {
    
    // initialize urlSession
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];

    // array of downloads
    self.imageDownloads = [[NSMutableArray alloc] init];
    
    // create request (AFNetworking)
    NSURL *url = [NSURL URLWithString:dataFeedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    // on request success
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSDictionary *imageDict = (NSDictionary *)responseObject;
        NSInteger index = 0;
        
        // initialize with loading image
        UIImage *loadingImage = [UIImage imageNamed:@"loading"];

        // iterate over JSON data
        for(NSDictionary *image in imageDict) {
            
            NSString *image_url = [image objectForKey:@"imageURL"];
            
            // add imageDownload object to array
            DPRImageDownload *imageDownload = [[DPRImageDownload alloc] initWithURL:image_url andIndex:index andImage:loadingImage];
            [_imageDownloads addObject:imageDownload];
            index++;

            // begin image download
            [self downloadImage:imageDownload];
        }
        
        // reload tableView data after all images have begun downloading
        [self.tableView reloadData];

        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // show alert on file download failure
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Error" message:@"error retrieving images" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertView animated:YES completion:nil];
        
    }];
    
    [operation start];
    
}

- (void)downloadImage:(DPRImageDownload *)imageDownload {
    
    // create urlSessionTask with urlSession and image_url
    NSURL *url = [NSURL URLWithString:imageDownload.image_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionTask *task = [_urlSession downloadTaskWithRequest:request];
    
    // to identify imageDownload in the future
    imageDownload.taskIdentifier = task.taskIdentifier;

    [task resume];
    
}

// once image download has complete
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{

    NSInteger imageIndex = 0;
    
    // identify complete imageDownload
    for(DPRImageDownload *imageDownload in _imageDownloads) {
        
        if(imageDownload.taskIdentifier == downloadTask.taskIdentifier) {
            
            imageIndex = imageDownload.index;
            
        }
    }
    DPRImageDownload *imageDownload = _imageDownloads[imageIndex];
    
    // retrieve data from url
    NSData *data = [NSData dataWithContentsOfURL:location];
    UIImage *image = [UIImage imageWithData:data];
    UIImage *noImage = [UIImage imageNamed:@"no_image"];
    
    // no image available
    if(image == nil) {
        imageDownload.image = noImage;
    }
    
    else{
        imageDownload.image = image;
    }
    
    
    NSArray *paths = @[[NSIndexPath indexPathForRow:imageIndex inSection:0]];
    // retrieve main queue to update UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    });
    
}


#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_imageDownloads count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // fix row height at 300
    return 300.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // custom UITableViewCell
    DPRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
    cell.contentMode = UIViewContentModeScaleToFill;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.backgroundColor = [UIColor colorWithRed:54.f/255.f green:69.f/255.f blue:79.f/255.f alpha:1.f];
    
    // if imageDownloads has been initialized, retrieve the image loaded into the imageDownload at
        // the appropriate index
    if(_imageDownloads){
        
        DPRImageDownload *imageDownload = _imageDownloads[indexPath.row];
        cell.imageView.image = imageDownload.image;
        
    }
    
    return cell;
    
}


#pragma mark - Segue


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // used to identify initial image in detailViewController
    self.currIndex = indexPath.row;
    [self performSegueWithIdentifier:segueIdentifier sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:segueIdentifier]) {
        
        // pass image data to detailViewController
        DPRDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.imageDownloads = _imageDownloads;
        detailViewController.currIndex = _currIndex;
        
    }
    
}

// on delete clicked in detailViewController
- (void)reloadImages:(NSMutableArray *)images {
    
    // reload imageDownloads data
    self.imageDownloads = images;
    [self.tableView reloadData];
    
}









@end
