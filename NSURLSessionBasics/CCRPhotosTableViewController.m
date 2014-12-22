//
//  CCRPhotosTableViewController.m
//  NSURLSessionBasics
//
//  Created by admin on 11/12/14.
//  Copyright (c) 2014 corsarus. All rights reserved.
//

#import "CCRPhotosTableViewController.h"
#import "CCRPhotoTableViewCell.h"
#import "CCRFileTransferManager.h"
#import "CCRPhotoXMLParser.h"

@interface CCRPhotosTableViewController ()

@property (nonatomic , strong) NSArray *photos;

@end

@implementation CCRPhotosTableViewController

static NSString * const kPhotoMetadataFileURL = @"http://corsarus.com/AppData/BlogSamples/201412/NSURLSession/photosmeta.xml";
static NSString * const kPhotoTableViewCellReuseId = @"photo table cell";

#pragma mark - View Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *photoCellNib = [UINib nibWithNibName:@"CCRPhotoTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:photoCellNib forCellReuseIdentifier:kPhotoTableViewCellReuseId];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updatePhotoData) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    
    [self updatePhotoData];
    
    // Register for background fetches
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundUpatePhotoData:) name:@"backgroundFetchNotification" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data fetching

// Download metadata from the remote server and update the table view
- (void)updatePhotoData
{
    NSURL *photoMetadataURL = [NSURL URLWithString:kPhotoMetadataFileURL];
    [CCRFileTransferManager downloadFileFromURL:photoMetadataURL inBackground:NO completionHandler:^(NSURL *downloadedFileLocation, BOOL filedUpdated) {
        
        CCRPhotoXMLParser *photoDataParser = [[CCRPhotoXMLParser alloc] init];
        [photoDataParser parseFileAtPath:downloadedFileLocation.path];
        self.photos = photoDataParser.photos;
        
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];
    }];
    
}

- (void)backgroundUpatePhotoData:(NSNotification *)notification
{
    // The completion handler block to call when the data fetching is finished
    NSDictionary *userInfo = notification.userInfo;
    void (^backgroundFetchCompletionHandler)(UIBackgroundFetchResult) = [userInfo objectForKey:@"backgroundFetchCompletionHandler"];
    
    
    NSURL *photoMetadataURL = [NSURL URLWithString:kPhotoMetadataFileURL];
    [CCRFileTransferManager downloadFileFromURL:photoMetadataURL inBackground:YES completionHandler:^(NSURL *downloadedFileLocation, BOOL filedUpdated) {
        
        CCRPhotoXMLParser *photoDataParser = [[CCRPhotoXMLParser alloc] init];
        [photoDataParser parseFileAtPath:downloadedFileLocation.path];
        self.photos = photoDataParser.photos;
        
        [self.tableView reloadData];
        
        if (filedUpdated) {
            backgroundFetchCompletionHandler(UIBackgroundFetchResultNewData);
        } else {
            backgroundFetchCompletionHandler(UIBackgroundFetchResultNoData);
        }
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCRPhotoTableViewCell *photoCell = [tableView dequeueReusableCellWithIdentifier:kPhotoTableViewCellReuseId forIndexPath:indexPath];
    
    PhotoData *photo = (PhotoData *)self.photos[indexPath.row];
    [photoCell updateWithPhotoId:photo.identifier title:photo.title imageURL:[@"http://corsarus.com/AppData/BlogSamples/201412/NSURLSession/" stringByAppendingString:photo.fileURL]];
    
    return photoCell;
}

#pragma mark - Table view delegates

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}


@end
