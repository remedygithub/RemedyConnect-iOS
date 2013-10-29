//
//  mainParser.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.07.05..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "mainParser.h"
#import "TBXML.h"
#import "FileHandling.h"
#import "Data.h"

@implementation mainParser
{
    TBXML *xml;
}

- (id)initWithXML:(NSString *)path {
    if (self = [super init]) {
        NSError *error;
        NSData *data = [NSData dataWithContentsOfFile:path];
        xml = [TBXML newTBXMLWithXMLData:data error:&error];
        if (error) {
            NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
            return nil;
        }
    }
    return self;
}

- (Boolean)hasElements:(NSString *)elements {
    NSArray *listOfElements = [elements componentsSeparatedByString:@" "];
    TBXMLElement *nextParent = xml.rootXMLElement;
    // "mobilefeed" is the root element, so we will have to start from 1 instead
    // of 0:
    NSUInteger currentElement = 1;
    TBXMLElement *actualPoint;
    Boolean notFound = false;
    while (currentElement < [listOfElements count] && !notFound) {
        actualPoint =
            [TBXML
                childElementNamed:[listOfElements objectAtIndex:currentElement]
                parentElement:nextParent];
        notFound = (actualPoint == nil);
        nextParent = actualPoint;
        ++currentElement;
    }
    return !notFound;
}

- (Boolean)isRoot {
    return [self hasElements:@"mobilefeed practices Practice"];
}

- (Boolean)isPage {
    return [self hasElements:@"mobilefeed PageText"];
}

- (Boolean)isMenu {
    return [self hasElements:@"mobilefeed buttons Button"];
}

- (Boolean)isArticleSet {
    return [self hasElements:@"mobilefeed articles article"];
}

- (NSDictionary*)getPage {
    NSMutableDictionary *pageData = [[NSMutableDictionary alloc] init];
    TBXMLElement *feed = [TBXML childElementNamed:@"mobilefeed"
                                        parentElement:xml.rootXMLElement];
    TBXMLElement *pageModified = [TBXML childElementNamed:@"PageModified"
                                        parentElement:feed];
    TBXMLElement *pageTitle = [TBXML childElementNamed: @"PageTitle"
                                        parentElement:feed];
    TBXMLElement *pageText = [TBXML childElementNamed: @"PageText"
                                       parentElement:feed];
    [pageData setObject:[TBXML textForElement:pageModified] forKey:@"modified"];
    [pageData setObject:[TBXML textForElement:pageTitle] forKey:@"title"];
    [pageData setObject:[TBXML textForElement:pageText] forKey:@"text"];
    return [[NSDictionary alloc] initWithDictionary:pageData];
}

- (NSArray*)getMenu {
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *buttonsElement = [TBXML childElementNamed:@"buttons" parentElement:root];
    TBXMLElement *currentButton =
            [TBXML childElementNamed:@"Button" parentElement:buttonsElement];
    TBXMLElement *name, *nextFeed, *externalLink;
    NSMutableDictionary *button;
    while (currentButton != nil) {
        name = [TBXML childElementNamed:@"ButtonName"
                                         parentElement:currentButton];
        nextFeed = [TBXML childElementNamed:@"NextFeed"
                                        parentElement:currentButton];
        externalLink = [TBXML childElementNamed:@"ExternalLink"
                                        parentElement:currentButton];
        button = [[NSMutableDictionary alloc] init];
        [button setObject:[TBXML textForElement:name]
                     forKey:@"name"];
        [button setObject:[TBXML textForElement:nextFeed]
                     forKey:@"feed"];
        [button setObject:[TBXML textForElement:externalLink]
                     forKey:@"externalLink"];
        [buttons addObject:button];
        
        currentButton = [TBXML nextSiblingNamed:@"Button"
                        searchFromElement:currentButton];
    }
    return [[NSArray alloc] initWithArray:buttons];
}

- (NSArray*)getArticleSet {
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *currentArticle =
            [TBXML childElementNamed:@"Article" parentElement:root];
    TBXMLElement *modified, *title, *text;
    NSMutableDictionary *article;
    while (currentArticle != nil) {
        modified = [TBXML childElementNamed:@"dateModified"
                                        parentElement:currentArticle];
        title = [TBXML childElementNamed:@"articleTitle"
                                            parentElement:currentArticle];
        text = [TBXML childElementNamed:@"articleText"
                                         parentElement:currentArticle];
        article = [[NSMutableDictionary alloc] init];
        [article setObject:[TBXML textForElement:modified]
                   forKey:@"modified"];
        [article setObject:[TBXML textForElement:title]
                   forKey:@"title"];
        [article setObject:[TBXML textForElement:text]
                    forKey:@"text"];
        [articles addObject:article];
        
        currentArticle = [TBXML nextSiblingNamed:@"Article"
                              searchFromElement:currentArticle];
    }
    return [[NSArray alloc] initWithArray:articles];
}

- (NSArray*)getArticleSetTitles {
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *currentArticle =
            [TBXML childElementNamed:@"Article" parentElement:root];
    TBXMLElement *title;
    while (currentArticle != nil) {
        title = [TBXML childElementNamed:@"articleTitle"
                                         parentElement:currentArticle];
        [titles addObject:[TBXML textForElement:title]];
        currentArticle = [TBXML nextSiblingNamed:@"Article"
                               searchFromElement:currentArticle];
    }
    return [[NSArray alloc] initWithArray:titles];
}

- (NSString*)getArticleFromSet:(NSUInteger)index {
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *currentArticle =
            [TBXML childElementNamed:@"Article" parentElement:root];
    NSUInteger currentIndex = 0;
    TBXMLElement *text = nil;
    while (currentArticle != nil) {
        if (currentIndex == index) {
            text = [TBXML childElementNamed:@"articleText"
                                             parentElement:currentArticle];
        }
        currentArticle = [TBXML nextSiblingNamed:@"Article"
                               searchFromElement:currentArticle];
        ++currentIndex;
    }
    return [TBXML textForElement:text];
}

- (NSArray*)getSubFeedURLs {
    NSMutableArray *subFeedURLs = [[NSMutableArray alloc] init];
    NSArray *menu = [self getMenu];
    for (NSDictionary *menuItem in menu) {
        [subFeedURLs addObject:[menuItem objectForKey:@"feed"]];
    }
    return [[NSArray alloc] initWithArray:subFeedURLs];
}

+ (NSString*)subFeedURLToLocal:(NSString*)subFeedURL {
    return [FileHandling  getFilePathWithComponent:
                [subFeedURL stringByReplacingOccurrencesOfString:FEED_ROOT
                                                    withString:@""]];
}

- (NSArray*)getRootPractices {
    NSMutableArray *rootPractices = [[NSMutableArray alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *practices = [TBXML childElementNamed:@"practices" parentElement:root];
    TBXMLElement *currentPractice =
        [TBXML childElementNamed:@"Practice" parentElement:practices];
    TBXMLElement *name, *feed, *designPack;
    NSString *location;
    NSMutableDictionary *practice;
    while (currentPractice != nil) {
        name = [TBXML childElementNamed:@"PracticeName"
                              parentElement:currentPractice];
        // @TODO: for this, an additional method is necessary.
        location = [self getRootPracticesLocation:currentPractice];
        feed = [TBXML childElementNamed:@"PracticeFeed"
                          parentElement:currentPractice];
        designPack = [TBXML childElementNamed:@"PracticeDesignPack"
                          parentElement:currentPractice];
        practice = [[NSMutableDictionary alloc] init];
        [practice setObject:[TBXML textForElement:name]
                    forKey:@"name"];
        [practice setObject:location forKey:@"location"];
        [practice setObject:[TBXML textForElement:feed]
                     forKey:@"feed"];
        [practice setObject:[TBXML textForElement:designPack]
                     forKey:@"designPack"];
        [rootPractices addObject:practice];
        
        currentPractice = [TBXML nextSiblingNamed:@"Practice"
                               searchFromElement:currentPractice];
    }
    return [[NSArray alloc] initWithArray:rootPractices];
}

- (NSString*)getRootPracticesLocation:(TBXMLElement *)practiceElement {
    NSString *locations = @"";
    NSString *location = @"";
    TBXMLElement *practiceLocations = [TBXML childElementNamed:@"PracticeLocations"
                                                 parentElement:practiceElement];
    if (practiceElement->firstChild) {
        TBXMLElement *currentLocation = [TBXML childElementNamed:@"practicelocation"
                                               parentElement:practiceLocations];
        while (currentLocation != nil) {
            location =
                [NSString stringWithFormat:@"%@, %@",
                    [TBXML textForElement:[TBXML childElementNamed:@"city" parentElement:currentLocation]],
                    [TBXML textForElement:[TBXML childElementNamed:@"state" parentElement:currentLocation]]];
            if ([locations  isEqual: @""]) {
                locations = [[NSString alloc] initWithString:location];
            }
            else {
                locations = [NSString stringWithFormat:@"%@ | %@", locations, location];
            }
            currentLocation =
                [TBXML nextSiblingNamed:@"practicelocation" searchFromElement:currentLocation];
        }
    }
    return locations;
}

@end
