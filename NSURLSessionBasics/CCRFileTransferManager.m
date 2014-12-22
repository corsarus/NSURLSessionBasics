//
//  CCRFileTransferManager.m
//  NSURLSessionBasics
//
//  Created by admin on 11/12/14.
//  Copyright (c) 2014 corsarus. All rights reserved.
//

#import "CCRFileTransferManager.h"
#import <objc/runtime.h>

#define CCRHTTPResponseStatusCodeOK 200
#define CCRHTTPResponseStatusCodeNotModified 304

const char kTaskAssociatedBlock;

@interface CCRFileTransferManager () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSMutableDictionary *cachedData;

@end

@implementation CCRFileTransferManager

static NSString * const kUserDefaultsCacheData = @"kUserDefaultsCacheData";
static NSString * const kBackgroundSessionConfigurationId = @"com.corsarus.nsurlsession.backgroundfetch";

#pragma mark - Initializer
+ (instancetype)sharedManager
{
    static CCRFileTransferManager *transferManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        transferManager = [[self alloc] init];
        
    });
    
    return transferManager;

}

- (instancetype)init
{
    if (! (self = [super init])) return nil;
    
    self.cachedData = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheData] mutableCopy];
    if (!self.cachedData) {
        self.cachedData = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Data transfer operations

+ (void)downloadFileFromURL:(NSURL *)fileURL inBackground:(BOOL)inBackground completionHandler:(void(^)(NSURL *downloadedFileLocation, BOOL filedUpdated))completionBlock
{
    
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    NSURL *cacheDirectoryURL = [[[defaultFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"Caches" isDirectory:YES];
    if (![defaultFileManager fileExistsAtPath:cacheDirectoryURL.path]) {
        [defaultFileManager createDirectoryAtPath:cacheDirectoryURL.path withIntermediateDirectories:NO attributes:nil error:nil];
    }

    NSURL *downloadedFileURL = [cacheDirectoryURL URLByAppendingPathComponent:fileURL.lastPathComponent];
    
    NSString *cachedDateForFile = [[[self sharedManager] cachedData] objectForKey:fileURL.path];
    NSMutableURLRequest *fileRequest = [NSMutableURLRequest requestWithURL:fileURL];
    
    // Download the file only if it doesn't exist in the cache directory and wasn't modified since the previous request
    if ([defaultFileManager fileExistsAtPath:downloadedFileURL.path] && cachedDateForFile) {
        [fileRequest addValue:cachedDateForFile forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    NSURLSessionDownloadTask *downloadTask;
    NSURLSession *downloadSession;
    if (inBackground) {
        NSURLSessionConfiguration *backgroundSessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBackgroundSessionConfigurationId];
        downloadSession = [NSURLSession sessionWithConfiguration:backgroundSessionConfiguration delegate:[self sharedManager] delegateQueue:nil];
        downloadTask = [downloadSession downloadTaskWithRequest:fileRequest];
        
        // Attach the completion block for UI updating to the download task object
        objc_setAssociatedObject(downloadTask, &kTaskAssociatedBlock, completionBlock, OBJC_ASSOCIATION_COPY);
    } else {
        downloadSession = [NSURLSession sharedSession];
        downloadTask = [downloadSession downloadTaskWithRequest:fileRequest
                                              completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                  
                                                  if (!error) {
                                                      
                                                      NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
                                                      NSInteger responseStatusCode = [httpURLResponse statusCode];
                                                      
                                                      // Update the cache only if the file was actually downloaded (status code = 200)
                                                      if (responseStatusCode == CCRHTTPResponseStatusCodeOK) {
                                                          
                                                          [[self sharedManager] updateCacheDataWithDate:[[httpURLResponse allHeaderFields] valueForKey:@"Last-Modified"] forFileURL:fileURL];
                                                          
                                                          // If there already is a file with the same name, remove it first
                                                          [defaultFileManager removeItemAtPath:downloadedFileURL.path error:nil];
                                                          [defaultFileManager moveItemAtPath:location.path toPath:downloadedFileURL.path error:nil];
                                                          
                                                          completionBlock(downloadedFileURL, YES);
                                                      } else {
                                                          completionBlock(downloadedFileURL, NO);
                                                      }
                                                      
                                                  }
                                              }];
    }
    
    
    [downloadTask resume];

    
}

- (void)updateCacheDataWithDate:(NSString *)lastModificationDate forFileURL:(NSURL *)fileURL
{
    if (fileURL && lastModificationDate) {
        [self.cachedData setObject:lastModificationDate forKey:fileURL.path];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.cachedData forKey:kUserDefaultsCacheData];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if ([session.configuration.identifier isEqualToString:kBackgroundSessionConfigurationId]) {
 
        // Get the completion block for the UI updating
        void(^completionBlock)(NSURL *, BOOL) = objc_getAssociatedObject(downloadTask, &kTaskAssociatedBlock);
        
        NSFileManager *defaultFileManager = [NSFileManager defaultManager];
        NSURL *cacheDirectoryURL = [[[defaultFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"Cache" isDirectory:YES];
        if (![defaultFileManager fileExistsAtPath:cacheDirectoryURL.path]) {
            [defaultFileManager createDirectoryAtPath:cacheDirectoryURL.path withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        NSURL *downloadedFileURL = [cacheDirectoryURL URLByAppendingPathComponent:downloadTask.originalRequest.URL.lastPathComponent];
        
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)downloadTask.response;
        NSInteger responseStatusCode = [httpURLResponse statusCode];
        
        if (responseStatusCode == CCRHTTPResponseStatusCodeOK) {
            
            [self updateCacheDataWithDate:[[httpURLResponse allHeaderFields] valueForKey:@"Last-Modified"] forFileURL:downloadTask.originalRequest.URL];
            
            // If there already is a file with the same name, remove it first
            [defaultFileManager removeItemAtPath:downloadedFileURL.path error:nil];
            [defaultFileManager moveItemAtPath:location.path toPath:downloadedFileURL.path error:nil];
            
            completionBlock(downloadedFileURL, YES);
        } else {
            completionBlock(downloadedFileURL, NO);
        }

    }
}


@end
