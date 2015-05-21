//
//  TextElement.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "LayoutElement.h"
#import "FontInstance.h"

typedef enum
{
	TextElementVerticalAlignmentTop,
	TextElementVerticalAlignmentMiddle,
	TextElementVerticalAlignmentBottom
} TextElementVerticalAlignment;

@interface TextElement : LayoutElement
{
	NSNumber *_percentUsed;
	NSString *_svg;
}

/**
 * For template-based layouts, this is the id of the text box so that
 * it can be matched to a particular id in the layout.
 */
@property ( nonatomic, copy ) NSString *textBoxId;

@property ( nonatomic, retain ) NSArray *availableFonts; // of AvailableFont
@property ( nonatomic, retain ) NSArray *availableColors; // of NSString (of format rgb(255,255,255))

@property ( nonatomic, retain ) FontInstance *defaultFont;

@property ( nonatomic, retain ) FontInstance *currentFont;

@property ( nonatomic, retain ) NSString *text;

@property ( nonatomic, assign ) UITextAlignment horizontalAlignment;
@property ( nonatomic, assign ) TextElementVerticalAlignment verticalAlignment;

#pragma mark RestKit conversion helper properties

/**
 * Set method that RestKit can call to map a CSV string of rgb(r,g,b) color
 * values to an actual array of rgb(r,g,b) color values.
 */
@property ( nonatomic, assign ) NSString *availableColorsCSV;

/**
 * Set method that RestKit can call to map a string horizontal justification to
 * populate the UITextAlignment horizontalAlignment value.
 */
@property ( nonatomic, assign ) NSString *horizontalJustification;

/**
 * Set method that RestKit can call to map a string vertical justification to
 * populate the TextElementVerticalAlignment verticalAlignment value.
 */
@property ( nonatomic, assign ) NSString *verticalJustification;

#pragma mark Text Measurement

- (NSNumber *)percentUsed;
- (NSString *)svg;
- (BOOL)characterLimitReached;

#pragma mark UI helpers

- (UIFont *)uiFontFromCurrentFont;

- (UIColor *)uiColorFromCurrentFont;

@end
