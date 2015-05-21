//
//  LayoutElement.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayoutElement : NSObject <NSMutableCopying>

@property ( nonatomic, retain ) NSNumber *x;
@property ( nonatomic, retain ) NSNumber *y;

/**
 * This value is only required because the server sends us data as an array
 * of photo holes and array of text holes.  Internally, we treat all of the
 * elements as a single array, so we read the "z" value from the server and
 * then use that value as the sort to combine photo and text into a single
 * array.
 */
@property ( nonatomic, retain ) NSNumber *z;

@property ( nonatomic, retain ) NSNumber *width;
@property ( nonatomic, retain ) NSNumber *height;

/**
 * The rotation that the display components should have when displaying
 * this image element.  This is the rotation of the entire element itself
 * (which, for the case of images, would rotate both the border and the photo).
 *
 * This rotation value can be anything.  Whimsical layouts will rotate
 * the photo and text hole by random amounts in any direction.
 */
@property ( nonatomic, retain ) NSNumber *rotation;

@end
