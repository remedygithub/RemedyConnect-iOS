
//
//  FileDownloader.m
//  demoROC
//
//  Created by Ravindra Kishan on 30/03/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#import "FileDownloader.h"
#import "SSZipArchive.h"

static FileDownloader * sharedInstance = nil;

@interface FileDownloader ()
{
    NSXMLParser *parser;
    Practice *mPractice;
    NSMutableArray *fullArray;
    
    NSMutableString *title;
    NSMutableString *address;
    NSMutableString *officeName;
    NSMutableString *city;
    NSMutableString *state;
    NSMutableString *zipCode;
    NSMutableString *zipFileUrl;
    NSString *element;
}

@end


@implementation FileDownloader
@synthesize delegate;

+(FileDownloader *)SharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[FileDownloader alloc]init];
    }
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        feedArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)downloadFileAndParseFrom:(NSString *)lExtension
{
    //stapleton+pediatrics
    NSString *urlString = [NSString stringWithFormat:@"http://cms.pediatricweb.com/mobile-app?%@",lExtension];
    NSString *xmlString = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:NULL];
    NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLString:xmlString];
    NSLog(@"dictionary: %@", xmlDoc);
    [self getDataFromXmlResponse:xmlDoc];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}


-(void)downloadFileAndParseFromLocation:(float)latitude locationLongitude:(float)longitude
{
    NSString *urlString = [NSString stringWithFormat:@"http://cms.pediatricweb.com/mobile-app?lat=%f&lon=%f",latitude,longitude];
   //NSString *urlString = [NSString stringWithFormat:@"http://cms.pediatricweb.com/mobile-app?lat=%f&lon=%f",39.559888,-105.116497];
    NSString *xmlString = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:NULL];
    NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLString:xmlString];
    NSLog(@"dictionary: %@", xmlDoc);
    [self getDataFromXmlResponse:xmlDoc];
    
    NSURL *url = [NSURL URLWithString:urlString];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}





- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
   
    if ([element isEqualToString:@"Practice"])
    {
        mPractice    = [[Practice alloc] init];
        title   = [[NSMutableString alloc] init];
        address    = [[NSMutableString alloc] init];
        officeName = [[NSMutableString alloc] init];
        city = [[NSMutableString alloc] init];
        state = [[NSMutableString alloc] init];
        zipCode = [[NSMutableString alloc] init];
        zipFileUrl = [[NSMutableString alloc] init];
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"PracticeName"])
    {
        [title appendString:string];
    }
    else if ([element isEqualToString:@"officename"])
    {
        [officeName appendString:string];
    }
    else if ([element isEqualToString:@"address"])
    {
        [address appendString:string];
    }
    else if ([element isEqualToString:@"city"])
    {
        [city appendString:string];
    }
    else if ([element isEqualToString:@"state"])
    {
        [state appendString:string];
    }
    else if ([element isEqualToString:@"zipcode"])
    {
        [zipCode appendString:string];
    }
    else if ([element isEqualToString:@"PracticeDesignPack"])
    {
        [zipFileUrl appendString:string];
    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"Practice"])
    {
        mPractice.PracticeName = title;
        mPractice.Officename = officeName;
        mPractice.address = address;
        mPractice.city = city;
        mPractice.state = state;
        mPractice.zipcode = zipCode;
        mPractice.PracticeDesignPackUrl = zipFileUrl;
 
    }
    NSLog(@"%@",mPractice.PracticeName);
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(successfullyParsedFiles:modelData:)])
        {
            NSLog(@"feed array %ld",(unsigned long)[feedArray count]);
            
            if ([feedArray count] == 0)
            {
                [self.delegate practiceNotFound];
            }
            else
            {
                [self.delegate successfullyParsedFiles:feedArray modelData:mPractice];
            }
        }
    }
}


-(BOOL)SaveFileToResourseFromUrl:(NSString *)zipUrl
{
    //NSURL *url = [[NSURL alloc] initWithString:zipUrl];
    NSURL *url = [[NSURL alloc] initWithString:[zipUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",url);
    NSError *error = nil;
    NSData *data = [NSData  dataWithContentsOfURL:url options:0 error:&error];
    if (!error) {
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *zipPath = [path stringByAppendingPathComponent:@"zipfile.zip"];
        NSString *unzipPath = [path stringByAppendingPathComponent:@"unzipPath"];
        
        [data writeToFile:zipPath options:0 error:&error];
        
        if(!error)
        {
            // TODO: Unzip
            [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath];
            NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzipPath error:&error];
            NSLog(@"the array %@", directoryContents);
            return YES;
            
        }
        else
        {
            NSLog(@"Error saving file %@",error);
            return NO;
        }
    }
    else
    {
        NSLog(@"Error downloading zip file: %@", error);
        return NO;
    }
}



//Parsing Data
-(void)getDataFromXmlResponse:(NSDictionary *)dict
{
    if ([dict count] == 4)
    {
        NSLog(@"No Data");
        if ([RCHelper SharedHelper].fromLocation)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Couldn't find any practices!" message:@"It Seems there are no practices near you.Please try searching by name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            
        }
    }
    else if ([[[dict objectForKey:@"practices"]objectForKey:@"Practice"] isKindOfClass:[NSArray class]])
    {
        NSMutableArray *dataArray = [[NSMutableArray alloc]init];        
        for (int i =0; i < [[[dict objectForKey:@"practices"]objectForKey:@"Practice"] count]; i++)
        {
            helperClass = [[RCHelper alloc]init];
            helperClass.zipUrl = [[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectAtIndex:i]objectForKey:@"PracticeDesignPack"];
            NSLog(@"%@",helperClass.zipUrl);
            if ([[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] isKindOfClass:[NSDictionary class]])
            {
                helperClass.addressData = [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectForKey:@"address"];
                NSLog(@"%@", helperClass.addressData);
                helperClass.officenameData = [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectForKey:@"officename"];
                NSLog(@"%@",helperClass.officenameData);
                helperClass.cityData = [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectForKey:@"city"];
                helperClass.stateData = [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectForKey:@"state"];
                helperClass.zipcodeData = [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectForKey:@"zipcode"];
                helperClass.practiceName = [[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectAtIndex:i] objectForKey:@"PracticeName"];
                [dataArray addObject:helperClass];
            }
            else
            {
                
                for (int j = 0 ; j < [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] count]; j++)
                {
                    helperClass = [[RCHelper alloc]init];
                    helperClass.addressData = [[[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectAtIndex:j] objectForKey:@"address"];
                    NSLog(@"%@", helperClass.addressData);
                    
                    helperClass.officenameData = [[[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectAtIndex:j] objectForKey:@"officename"];
                    NSLog(@"%@",helperClass.officenameData);
                    
                    helperClass.cityData = [[[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectAtIndex:j] objectForKey:@"city"];
                    helperClass.stateData = [[[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectAtIndex:j] objectForKey:@"state"];
                    helperClass.zipcodeData = [[[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectAtIndex:i]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectAtIndex:j] objectForKey:@"zipcode"];
                    helperClass.practiceName = [[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectAtIndex:i] objectForKey:@"PracticeName"];
                    [dataArray addObject:helperClass];
                }
                
            }
            feedArray = dataArray;
            NSLog(@"Data Present %@",feedArray);
            NSLog(@"Data Count%ld",(unsigned long)[feedArray count]);
        }
        
    }
    else if ([[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] isKindOfClass:[NSArray class]])
    {
        NSMutableArray *dataArray = [[NSMutableArray alloc]init];
        for (int i = 0 ; i < [[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] count]; i ++)
        {
            helperClass = [[RCHelper alloc]init];
            //Practice Feeds
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeFeed"] forKey:@"practiceFeedUrl"];
            [defaults synchronize];
            
            helperClass.zipUrl = [[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeDesignPack"];
            NSLog(@"%@", helperClass.zipUrl);
            helperClass.practiceName = [[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectForKey:@"PracticeName"];
            helperClass.addressData = [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectAtIndex:i] objectForKey:@"address"];
            NSLog(@"%@", helperClass.addressData);
            
            helperClass.officenameData = [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectAtIndex:i] objectForKey:@"officename"];
            
            
            helperClass.cityData = [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectAtIndex:i] objectForKey:@"city"];
            helperClass.stateData = [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectAtIndex:i] objectForKey:@"state"];
            helperClass.zipcodeData = [[[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectAtIndex:i] objectForKey:@"zipcode"];
            [dataArray addObject:helperClass];
        }
        feedArray = dataArray;
        NSLog(@"Data Present %@",feedArray);
        NSLog(@"Data Count%ld",(unsigned long)[feedArray count]);
    }
    else
    {
        NSMutableArray *dataArray = [[NSMutableArray alloc]init];
        if ([[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] isKindOfClass:[NSDictionary class]])
        {
            helperClass = [[RCHelper alloc]init];
            NSLog(@"Dict with out Array");
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeFeed"] forKey:@"practiceFeedUrl"];
            [defaults synchronize];
            helperClass.zipUrl = [[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeDesignPack"];
            NSLog(@"%@", helperClass.zipUrl);
            helperClass.practiceName =[[[dict objectForKey:@"practices"]objectForKey:@"Practice"] objectForKey:@"PracticeName"];
            
            helperClass.addressData = [[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"]  objectForKey:@"address"];
            helperClass.officenameData = [[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"] objectForKey:@"officename"];
            helperClass.cityData = [[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"]  objectForKey:@"city"];
            helperClass.stateData = [[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"]  objectForKey:@"state"];
            helperClass.zipcodeData = [[[[[dict objectForKey:@"practices"]objectForKey:@"Practice"]objectForKey:@"PracticeLocations"] objectForKey:@"practicelocation"]objectForKey:@"zipcode"];
            [dataArray addObject:helperClass];
        }
        feedArray = dataArray;
        NSLog(@"Data Present %@",feedArray);
        NSLog(@"Data Count%ld",(unsigned long)[feedArray count]);
    }
    
}

@end
