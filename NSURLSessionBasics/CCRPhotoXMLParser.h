//
//  CCRXMLParser
//
//  Created by Catalin (iMac) on 10/06/14.
//  Copyright (c) 2014 Tapsarena. All rights reserved.
//



#import <Foundation/Foundation.h>


@interface PhotoData : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *fileURL;

@end

@interface CCRPhotoXMLParser : NSObject <NSXMLParserDelegate>

- (void)parseFileAtPath:(NSString *)path;

@property (nonatomic, strong) NSArray *photos;

@end


