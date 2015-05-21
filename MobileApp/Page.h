//
//  Page.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Layout.h"
#import "ImageElement.h"

@interface Page : NSObject

/**
 * The x coordinate of the page in relation to the printed press page (in page-coordinates).
 */
@property ( nonatomic, retain ) NSNumber *x;

/**
 * The y coordinate of the page in relation to the printed press page (in page-coordinates).
 */
@property ( nonatomic, retain ) NSNumber *y;

/**
 * The width of the printed press page (in page-coordinates).
 */
@property ( nonatomic, retain ) NSNumber *width;

/**
 * The height of the printed press page (in page-coordinates).
 */
@property ( nonatomic, retain ) NSNumber *height;

/**
 * The bounds for the finished page area.  This value is read by the service that
 * describes the page, and is most likely fed into the auto layout page parameters
 * to control the x/w/width/height values of the Layout objects that come from
 * the auto layout generator.
 */
@property ( nonatomic, assign ) CGRect finishedLayoutArea;

/**
 * The working area is a rectangle within the finished area. It represents the area of the page
 * that the user is restricted user also includes autoLayout area.
 */
@property ( nonatomic, assign ) CGRect workingArea;

@property ( nonatomic, retain ) Layout *layout;

@property ( nonatomic, retain ) ImageElement *background;

@end
