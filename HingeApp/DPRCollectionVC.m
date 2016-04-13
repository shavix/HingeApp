//
//  DPRCollectionVC.m
//  HingeApp
//
//  Created by David Richardson on 4/12/16.
//  Copyright © 2016 David Richardson. All rights reserved.
//

#import "DPRCollectionVC.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

static NSString *dataFeedURL = @"https://hinge-homework.s3.amazonaws.com/client/services/homework.json";

@interface DPRCollectionVC()

@property (strong, nonatomic) NSMutableArray *imageDownloads;

@end

@implementation DPRCollectionVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self fetchImages];
    
}


#pragma mark - Images

- (void)fetchImages {
    
    self.imageDownloads = [[NSMutableArray alloc] init];
    
    NSURL *url = [NSURL URLWithString:dataFeedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSDictionary *imageDict = (NSDictionary *)responseObject;
        for(NSDictionary *image in imageDict) {
            NSString *image_url = [image objectForKey:@"imageURL"];
            [_imageDownloads addObject:image_url];
        }
        
        [self.tableView reloadData];

        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Error" message:@"error retrieving images" preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alertView animated:YES completion:nil];
        
    }];
    
    [operation start];
    
}


#pragma mark - UITableView


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_imageDownloads count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
    cell.contentMode = UIViewContentModeScaleToFill;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    
    if(_imageDownloads){
        NSURL *url = [NSURL URLWithString:_imageDownloads[indexPath.row]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        __weak UITableViewCell *weakCell = cell;
        
        [cell.imageView setImageWithURLRequest:request
                              placeholderImage:placeholderImage
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           weakCell.imageView.image = image;
                                           [weakCell setNeedsLayout];
                                           
                                       }
                                       failure:^(NSURLRequest *urlRequest, NSHTTPURLResponse *response, NSError *error){

                                       }];
    }
    else {
        cell.imageView.image = placeholderImage;
    }
    
    return cell;
    
}














@end
