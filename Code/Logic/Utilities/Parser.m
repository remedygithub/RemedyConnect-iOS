//
//  mainParser.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.07.05..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "Parser.h"
#import "TBXML.h"
#import "FileHandling.h"
#import "Data.h"

@implementation Parser
{
    TBXML *xml;
}

#pragma mark - Initializing

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

#pragma mark - Internal utilities

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

#pragma mark - Feed type checks

- (Boolean)isRoot {
    return [self hasElements:@"mobilefeed practices Practice"];
}

- (Boolean)isFileFeed {
    return [self hasElements:@"mobilefeed buttons filefeed feed"];
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

#pragma mark - Getters

- (NSArray*)getRootPractices {
    NSMutableArray *rootPractices = [[NSMutableArray alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *practices = [TBXML childElementNamed:@"practices" parentElement:root];
    TBXMLElement *currentPractice =
                    [TBXML childElementNamed:@"Practice" parentElement:practices];
    TBXMLElement *name, *feed, *filefeed, *designPack;
    NSString *location;
    NSMutableDictionary *practice;
    while (currentPractice != nil) {
        name = [TBXML childElementNamed:@"PracticeName"
                          parentElement:currentPractice];
        location = [self getRootPracticesLocation:currentPractice];
        feed = [TBXML childElementNamed:@"PracticeFeed"
                          parentElement:currentPractice];
        filefeed = [TBXML childElementNamed:@"FileFeed"
                            parentElement:currentPractice];
        designPack = [TBXML childElementNamed:@"PracticeDesignPack"
                            parentElement:currentPractice];
        practice = [[NSMutableDictionary alloc] init];
        [practice setObject:[TBXML textForElement:name]
                     forKey:@"name"];
        [practice setObject:location forKey:@"location"];
        [practice setObject:[TBXML textForElement:feed]
                     forKey:@"feed"];
        [practice setObject:[TBXML textForElement:filefeed]
                     forKey:@"filefeed"];
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

- (NSDictionary*)getPage {
    NSMutableDictionary *pageData = [[NSMutableDictionary alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *pageModified = [TBXML childElementNamed:@"PageModified"
                                        parentElement:root];
    TBXMLElement *pageTitle = [TBXML childElementNamed: @"PageTitle"
                                        parentElement:root];
    TBXMLElement *pageText = [TBXML childElementNamed: @"PageText"
                                       parentElement:root];
    if (nil != pageModified) {
        [pageData setObject:[TBXML textForElement:pageModified] forKey:@"modified"];
    }
    if (nil != pageTitle) {
        [pageData setObject:[TBXML textForElement:pageTitle] forKey:@"title"];
    }
    if (nil != pageText) {
        [pageData setObject:[TBXML textForElement:pageText] forKey:@"text"];
    }
    return [[NSDictionary alloc] initWithDictionary:pageData];
}

// This returns a string, empty if the element is NULL
+ (NSString*)stringForElement:(TBXMLElement *)element {
    NSString *result = [[NSString alloc] init];
    if (nil != element) {
        result = [TBXML textForElement:element];
    }
    else {
        result = @"";
    }
    return result;
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
        [button setObject:[Parser stringForElement:nextFeed] forKey:@"feed"];
        [button setObject:[Parser stringForElement:externalLink] forKey:@"externalLink"];

        [buttons addObject:button];
        
        currentButton = [TBXML nextSiblingNamed:@"Button"
                        searchFromElement:currentButton];
    }
    return [[NSArray alloc] initWithArray:buttons];
}

- (NSArray*)getFileFeed {
    NSMutableArray *filefeeds = [[NSMutableArray alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *feedsElement = [TBXML childElementNamed:@"buttons" parentElement:root];
    TBXMLElement *currentFeed =
                [TBXML childElementNamed:@"filefeed" parentElement:feedsElement];
    TBXMLElement *name, *feedURL, *dateModified;
    NSMutableDictionary *feed;
    while (currentFeed != nil) {
        name = [TBXML childElementNamed:@"buttonName"
                          parentElement:currentFeed];
        
        if (![[TBXML textForElement:name] isEqual:@"Design Pack"]) {
            feedURL = [TBXML childElementNamed:@"feed"
                                  parentElement:currentFeed];
            dateModified = [TBXML childElementNamed:@"dateModified"
                                      parentElement:currentFeed];
            feed = [[NSMutableDictionary alloc] init];
            [feed setObject:[TBXML textForElement:name]
                       forKey:@"name"];
            [feed setObject:[Parser stringForElement:feedURL] forKey:@"feed"];
            [feed setObject:[Parser stringForElement:dateModified] forKey:@"dateModified"];
            
            [filefeeds addObject:feed];
        }
        
        currentFeed = [TBXML nextSiblingNamed:@"filefeed"
                              searchFromElement:currentFeed];
    }
    return [[NSArray alloc] initWithArray:filefeeds];
}

- (NSArray*)getArticleSet {
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *articlesElement = [TBXML childElementNamed:@"articles" parentElement:root];
    TBXMLElement *currentArticle =
            [TBXML childElementNamed:@"article" parentElement:articlesElement];
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
        
        currentArticle = [TBXML nextSiblingNamed:@"article"
                              searchFromElement:currentArticle];
    }
    return [[NSArray alloc] initWithArray:articles];
}

- (NSArray*)getArticleSetTitles {
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *articles = [TBXML childElementNamed:@"articles" parentElement:root];
    TBXMLElement *currentArticle =
            [TBXML childElementNamed:@"article" parentElement:articles];
    TBXMLElement *title;
    while (currentArticle != nil) {
        title = [TBXML childElementNamed:@"articleTitle"
                                         parentElement:currentArticle];
        [titles addObject:[TBXML textForElement:title]];
        currentArticle = [TBXML nextSiblingNamed:@"article"
                               searchFromElement:currentArticle];
    }
    return [[NSArray alloc] initWithArray:titles];
}

- (NSDictionary*)getArticleFromSet:(NSUInteger)index {
    NSDictionary *article = [[NSMutableDictionary alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *articles = [TBXML childElementNamed:@"articles" parentElement:root];
    TBXMLElement *currentArticle =
            [TBXML childElementNamed:@"article" parentElement:articles];
    NSUInteger currentIndex = 0;
    TBXMLElement *text = nil, *title = nil;
    while (currentArticle != nil) {
        if (currentIndex == index) {
            text = [TBXML childElementNamed:@"articleText"
                                             parentElement:currentArticle];
            title = [TBXML childElementNamed:@"articleTitle"
                               parentElement:currentArticle];
        }
        currentArticle = [TBXML nextSiblingNamed:@"article"
                               searchFromElement:currentArticle];
        ++currentIndex;
    }
    [article setValue:[TBXML textForElement:text] forKey:@"text"];
    [article setValue:[TBXML textForElement:title] forKey:@"title"];
    return [[NSDictionary alloc] initWithDictionary:article];
}

#pragma mark - Subfeed URL handling

- (NSArray*)getSubFeedURLs {
    NSMutableArray *subFeedURLs = [[NSMutableArray alloc] init];
    NSArray *menu = [self getMenu];
    for (NSDictionary *menuItem in menu) {
        [subFeedURLs addObject:[menuItem objectForKey:@"feed"]];
    }
    return [[NSArray alloc] initWithArray:subFeedURLs];
}

- (NSArray*)getSubFeedURLsFromFileFeed {
    NSMutableArray *subFeedURLs = [[NSMutableArray alloc] init];
    NSArray *menu = [self getFileFeed];
    for (NSDictionary *menuItem in menu) {
        [subFeedURLs addObject:[menuItem objectForKey:@"feed"]];
    }
    return [[NSArray alloc] initWithArray:subFeedURLs];
}

+ (NSString*)subFeedURLToLocal:(NSString*)subFeedURL withFeedRoot:(NSString*)feedRoot inTemp:(BOOL)temp {
    NSError *regexError;
    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:@"^http(s)?"
                                                  options:NSRegularExpressionCaseInsensitive error:&regexError];
    NSString *URLwithoutProtocol =
        [regex stringByReplacingMatchesInString:subFeedURL
                                        options:0
                                          range:NSMakeRange(0, [subFeedURL length])
                                   withTemplate:@""];
    NSString *feedRootWithoutProtocol =
        [regex stringByReplacingMatchesInString:feedRoot
                                        options:0
                                          range:NSMakeRange(0, [feedRoot length])
                                   withTemplate:@""];
    
    NSString *result = [URLwithoutProtocol stringByReplacingOccurrencesOfString:feedRootWithoutProtocol
                                                                     withString:@""];
    if (nil == result) {
        result = @"";
    }
    NSString *resultPath = [FileHandling getFilePathWithComponent:result inTemp:temp];
    return resultPath;
}

@end
