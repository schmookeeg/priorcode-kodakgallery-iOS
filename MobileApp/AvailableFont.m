//
//  AvailableFont.m
//  MobileApp
//
//  Created by Amit Chauhan on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AvailableFont.h"

@implementation AvailableFont

@synthesize fontId = _fontId;
@synthesize family = _family;
@synthesize styles = _styles;
@synthesize sizes = _sizes;

@synthesize stylesCSV = _stylesCSV;
@synthesize sizesCSV = _sizesCSV;

#pragma mark init / dealloc

- (void)dealloc
{
	[_fontId release];
	[_family release];
	[_styles release];
	[_sizes release];

	[super dealloc];
}

- (NSString *)description 
{
	return [NSString stringWithFormat:@"<%@:%p \
            fontId: %@\n \
            family: %@\n \
            styles: %@\n \
            sizes: %@\n"
            , NSStringFromClass([self class]), self, _fontId, _family,
					_styles, _sizes];
}

#pragma mark RestKit setter conversion helpers

- (void)setStylesCSV:(NSString *)styles
{
	self.styles = [styles componentsSeparatedByString:@","];
}

- (void)setSizesCSV:(NSString *)sizes
{
	NSMutableArray *tmp = [[NSMutableArray alloc] init];

	// Break apart the CSV string into an array
	for ( NSString *size in [sizes componentsSeparatedByString:@","] )
	{
		// Convert NSString elements to NSNumber elements
		[tmp addObject:[NSNumber numberWithFloat:[size floatValue]]];
	}

	self.sizes = tmp;
	[tmp release];
}

@end
