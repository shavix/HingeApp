//
//  HingeAppTests.m
//  HingeAppTests
//
//  Created by David Richardson on 4/12/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AFNetworking.h"
#import "DPRImageDownload.h"

static NSString *dataFeedURL = @"https://hinge-homework.s3.amazonaws.com/client/services/homework.json";

@interface HingeAppTests : XCTestCase <NSURLSessionDelegate>

@property (strong, nonatomic) NSMutableArray *imageDownloads;
@property (strong, nonatomic) NSURLSession *urlSession;

@end

@implementation HingeAppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDownloads {
    
    [self fetchImages];
    
}

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
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error retrieving images");
        
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
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


@end
