//
//  CCRPhotoTableViewCell.m
//  NSURLSessionBasics
//
//  Created by admin on 11/12/14.
//  Copyright (c) 2014 corsarus. All rights reserved.
//

#import "CCRPhotoTableViewCell.h"
#import "CCRFileTransferManager.h"

@interface CCRPhotoTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSString *photoId;
@property (nonatomic, strong) NSURL *imageURL;

@end

@implementation CCRPhotoTableViewCell

- (void)updateWithPhotoId:(NSString *)photoId title:(NSString *)photoTitle imageURL:(NSString *)imageURL
{
    self.photoId = photoId;
    self.title.text = photoTitle;
    self.imageURL = [NSURL URLWithString:imageURL];
    
    
    if (imageURL.length) {
        [self.loadingIndicator startAnimating];
        [CCRFileTransferManager downloadFileFromURL:self.imageURL inBackground:NO completionHandler:^(NSURL *downloadedFileLocation, BOOL filedUpdated) {
            
            // Always update the UI on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                // Load the image in the thumbnail image view
                self.imageView.image = [UIImage imageWithContentsOfFile:downloadedFileLocation.path];
                
                [self.loadingIndicator stopAnimating];
                [self setNeedsLayout];
            });
            
        }];
    }
}



@end
