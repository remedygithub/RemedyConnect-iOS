//
//  parserIYCS.m
//  Greenwood Pediatrics
//
//  Created by Adamek Zoltán on 2013.04.03..
//  Copyright (c) 2013 NewPush LLC. All rights reserved.
//

#import "parserIYCS.h"
#import "TBXML.h"
#import "FileHandling.h"

@implementation parserIYCS
{
    TBXML *xml;
}
    
-(id)init {
    self = [super init];
    if (self) {
        NSError *error;
        NSString *filePath = [FileHandling getFilePathWithComponent:@"iycs.xml"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        xml = [TBXML newTBXMLWithXMLData:data error:&error];
        if (error) {
            NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
            return nil;
        }
    }
    return self;
}

-(NSArray*)getCategories {
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    TBXMLElement *root = xml.rootXMLElement;
    TBXMLElement *categoryXML =
        [TBXML childElementNamed:@"pw_medical_category" parentElement:root];
    while (categoryXML != nil) {
        TBXMLElement *categoryName = [TBXML childElementNamed:@"categoryname" parentElement:categoryXML];
        [categories addObject:[TBXML textForElement:categoryName]];
        categoryXML = [TBXML nextSiblingNamed:@"pw_medical_category"  searchFromElement:categoryXML];
        
    }
    return [[NSArray alloc] initWithArray:categories];
}
@end
