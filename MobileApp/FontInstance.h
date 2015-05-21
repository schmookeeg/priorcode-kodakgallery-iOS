//
//  Created by darron on 3/13/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

/**
 * A single font family, style, size, and color value that can
 * be used to describe the select font values for a particular
 * piece of text or for the default font choices for a background.
 */
@interface FontInstance : NSObject


@property ( nonatomic, retain ) NSString *family;

/**
 * Possible values are those found in FontStyle.h
 */
@property ( nonatomic, retain ) NSString *style;

@property ( nonatomic, retain ) NSNumber *size;
@property ( nonatomic, retain ) NSString *color;

+ (NSString *)uiFontFamilyNameFromFamily:(NSString *)family andStyle:(NSString *)style;

/**
 * Inspects the family and style strings of the FontInstance and
 * generates the family name that should be passed to UIFont in
 * order to create a font representative of the properties.
 */
- (NSString *)uiFontFamilyName;

@end