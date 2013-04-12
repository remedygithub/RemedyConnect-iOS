//
//  parserPracticeNews.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.12..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "parserPracticeNews.h"
#import "TBXML.h"
#import "FileHandling.h"

@implementation parserPracticeNews
{
    TBXML *xml;
}

-(id)init {
    self = [super init];
    if (self) {
        NSError *error;
        NSString *filePath = [FileHandling getFilePathWithComponent:@"news.xml"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        xml = [TBXML newTBXMLWithXMLData:data error:&error];
        if (error) {
            NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
            return nil;
        }
    }
    return self;
}

- (NSArray *)getNews {
    NSMutableArray *news = [[NSMutableArray alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *newsXML =
        [TBXML childElementNamed:@"CMS_News" parentElement:root];
    while (newsXML != nil) {
        TBXMLElement *title = [TBXML childElementNamed:@"NewsTitle"
                                                parentElement:newsXML];
        /*
        NSMutableDictionary *newsItem =
            [[NSMutableDictionary alloc] init];
        [newsItem setObject:[TBXML textForElement:title]
                         forKey:@"NewsTitle"];
        [news addObject:newsItem];*/
        [news addObject:[TBXML textForElement:title]];
        
        newsXML = [TBXML nextSiblingNamed:@"CMS_News"
                            searchFromElement:newsXML];
        
    }
    return [[NSArray alloc] initWithArray:news];
}

@end
