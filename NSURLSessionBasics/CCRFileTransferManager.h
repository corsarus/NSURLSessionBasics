//
//  CCRFileTransferManager.h
//  NSURLSessionBasics
//
//  Created by admin on 11/12/14.
//  Copyright (c) 2014 corsarus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCRFileTransferManager : NSObject

+ (void)downloadFileFromURL:(NSURL *)fileURL inBackground:(BOOL)inBackground completionHandler:(void(^)(NSURL *downloadedFileLocation, BOOL filedUpdated))completionBlock;

@end
