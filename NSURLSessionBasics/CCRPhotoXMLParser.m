//
//  CCRXMLParser.m
//
//  Created by Catalin (iMac) on 10/06/14.
//  Copyright (c) 2014 Tapsarena. All rights reserved.
//

#define kPhoto @"photo"
#define kAttrPhotoId @"id"
#define kAttrPhotoTitle @"title"
#define kAttrPhotoURL @"relurl"

#import "CCRPhotoXMLParser.h"


@implementation PhotoData

@end

@interface CCRPhotoXMLParser ()

@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSMutableArray *mutablePhotos;
@property (nonatomic, strong) PhotoData *currentPhoto;

@end

@implementation CCRPhotoXMLParser

- (NSMutableArray *)mutablePhotos
{
    if (!_mutablePhotos) {
        _mutablePhotos = [[NSMutableArray alloc] init];
    }
    
    return _mutablePhotos;
}


- (NSArray *)photos
{
    return self.mutablePhotos;
}

- (void)parseFileAtPath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *xmlURL = [NSURL fileURLWithPath:path];
        self.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
        self.xmlParser.delegate = self;
        [self.xmlParser parse];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
   
    if ([elementName isEqualToString:kPhoto]) {
        self.currentPhoto = [[PhotoData alloc] init];
        self.currentPhoto.identifier = [attributeDict valueForKey:kAttrPhotoId];
        self.currentPhoto.title = [attributeDict valueForKey:kAttrPhotoTitle];
        self.currentPhoto.fileURL = [attributeDict valueForKey:kAttrPhotoURL];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:kPhoto]) {
        [self.mutablePhotos addObject:self.currentPhoto];
    }
}

@end
