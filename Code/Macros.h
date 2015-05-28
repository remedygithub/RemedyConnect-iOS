//
//  Macros.h
//  DroidCon
//
//  Created by Ravindra Kishan on 19/03/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

#ifndef DroidCon_Macros_h
#define DroidCon_Macros_h

#define apiKey   @"SSB3aWxsIG1ha2UgbXkgQVBJIHNlY3VyZQ=="
#define tokenKey @"j2w+jHHs+F8fkvr7Vj5DlPuYg8VqXvOhbtaG4WaOqxA="

#define APNS_TOKEN      @"remedyconnect.pushtoken"


#define WIDTH_IPHONE_4 480
#define IS_IPHONE_4 ( [ [ UIScreen mainScreen ] bounds ].size.height == WIDTH_IPHONE_4 )

#define WIDTH_IPHONE_5 568
#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height == WIDTH_IPHONE_5 )

#define WIDTH_IPHONE_6 667
#define IS_IPHONE_6 ( [ [ UIScreen mainScreen ] bounds ].size.height == WIDTH_IPHONE_6 )


#define WIDTH_IPHONE_5H 320
#define IS_IPHONE_5H ( [ [ UIScreen mainScreen ] bounds ].size.height == WIDTH_IPHONE_5H )

#define WIDTH_IPHONE_6H 375
#define IS_IPHONE_6H ( [ [ UIScreen mainScreen ] bounds ].size.height == WIDTH_IPHONE_6H )


#define navBar_BackgroundColor   [UIColor colorWithRed:0.50 green:0.75 blue:0.19 alpha:1]
#define navBar_textColor         [UIColor colorWithRed:0.22 green:0.22 blue:0.23 alpha:1]
#define about_Us_textColor       [UIFont fontWithName:@"Avenir Next Medium" size:16.0];
#define ButtonborderColor              [UIColor colorWithRed:0.15 green:0.46 blue:0.72 alpha:1].CGColor;


#define kPath @"Path"
#define kPatient @"Patient"
#define kProvider @"Provider"
#define kCreatePin @"CreatePin"


#define kResetPinNotification @"ResetPinNotification"

#endif
