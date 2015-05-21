//
//  Layout.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	LayoutStyleMargins = 0,
    // TODO: More.. but not necessary right now for our SPM needs
    
    LayoutStyleTemplate = 24
} LayoutStyle;

@interface Layout : NSObject

/**
 * The x position on the finished page area (in page-coordinates).
 */
@property ( nonatomic, retain ) NSNumber *x;

/**
 * The y position on the finished page area (in page-coordinates).
 */
@property ( nonatomic, retain ) NSNumber *y;

/**
 * The width on the finished page area (in page-coordinates).
 */
@property ( nonatomic, retain ) NSNumber *width;

/**
 * The height position on the finished page area (in page-coordinates).
 */
@property ( nonatomic, retain ) NSNumber *height;

/**
 * The Text and Image layout element children that make up the canvas (photo and text holes,
 * vector graphics, background/foreground images).
 *
 * This DOES NOT include the page background, which is defined via the separate page.background
 * property.
 */
@property ( nonatomic, readonly ) NSMutableArray *elements;

/**
 * The style of the layout.  The primary use of this setting is to keep track of which
 * type of layout is generated (so that modifying the layout by adding or removing
 * new elements will preserve the same style in the auto layout generator).
 */
@property ( nonatomic, assign ) LayoutStyle layoutSyle;

@end
