//
//  AvailableFont.h
//  MobileApp
//
//  Created by Amit Chauhan on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvailableFont : NSObject

@property ( nonatomic, retain ) NSString *fontId;
@property ( nonatomic, retain ) NSString *family;

/**
 * Possible values are those found in FontStyle.h
 */
@property ( nonatomic, retain ) NSArray *styles; // of NSString*, see FontStyle.h

@property ( nonatomic, retain ) NSArray *sizes; // of NSNumber*

#pragma mark RestKit conversion helper properties

/**
 * Set method that RestKit can call to map a CSV string of string style
 * values to an actual array of string style values.
 */
@property ( nonatomic, assign ) NSString *stylesCSV;

/**
 * Set method that RestKit can call to map a CSV string of string style
 * values to an actual array of string style values.
 */
@property ( nonatomic, assign ) NSString *sizesCSV;

@end
