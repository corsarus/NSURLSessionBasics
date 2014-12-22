//
//  CCRPhotoTableViewCell.h
//  NSURLSessionBasics
//
//  Created by admin on 11/12/14.
//  Copyright (c) 2014 corsarus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCRPhotoTableViewCell : UITableViewCell

- (void)updateWithPhotoId:(NSString *)photoId title:(NSString *)photoTitle imageURL:(NSString *)imageURL;

@end
