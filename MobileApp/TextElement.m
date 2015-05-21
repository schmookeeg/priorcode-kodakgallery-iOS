//
//  TextElement.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "TextElement.h"
#import <CoreText/CoreText.h>
#import "FontStyle.h"

@interface TextElement (Private)

- (void)measureText;

@end

@implementation TextElement

@synthesize textBoxId = _textBoxId;

@synthesize availableFonts = _availableFonts;
@synthesize availableColors = _availableColors;

@synthesize defaultFont = _defaultFont;

@synthesize currentFont = _currentFont;

@synthesize text = _text;

@synthesize horizontalAlignment = _horizontalAlignment;
@synthesize verticalAlignment = _verticalAlignment;

@synthesize availableColorsCSV = _availableColorsCSV;
@synthesize horizontalJustification = _horizontalJustification;
@synthesize verticalJustification = _verticalJustification;

#pragma mark init / dealloc

- (id)init
{
	self = [super init];
	if ( self )
	{
		_currentFont = nil;
		_percentUsed = nil;
		_svg = nil;

		_horizontalAlignment = UITextAlignmentCenter;
		_verticalAlignment = TextElementVerticalAlignmentTop;
	}

	return self;
}

/**
 * Creates a copy of the text element so that callers can change
 * the "text" property in order to leverage the characterLimitReached
 * calculations.
 *
 * For background on why we set iVars to nil first, see
 * http://robnapier.net/blog/implementing-nscopying-439
 */
- (id)mutableCopyWithZone:(NSZone *)zone
{
    TextElement *copy = [super mutableCopyWithZone:zone];

    copy.horizontalAlignment = self.horizontalAlignment;
	copy.verticalAlignment = self.verticalAlignment;

	copy->_currentFont = nil;
	copy.currentFont = self.currentFont;

	copy->_text = nil;
	copy.text = self.text;

    return copy;
}

- (void)dealloc
{
	[_textBoxId release];

	[_availableFonts release];
	[_availableColors release];

	[_defaultFont release];
	[_currentFont release];

	[_text release];

	[_svg release];
	[_percentUsed release];

	[super dealloc];
}

#pragma mark -

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p \
            text: %@\n \
            height: %@\n \
            width: %@\n \
            x: %@\n \
            y: %@\n \
            rotation: %@\n \
            z: %@\n \
            Default Font: %@\n \
            Current Font: %@\n \
            horizontal Alignment: %d\n \
            vertical Alignment: %d\n \
            Available Fonts: %@\n \
            Available Colors: %@\n",
									  NSStringFromClass( [self class] ), self, self.text, self.height, self.width, self.x, self.y, self.rotation, self.z, self.defaultFont,
									  self.currentFont, self.horizontalAlignment, self.verticalAlignment,
									  self.availableFonts, self.availableColors];
}

#pragma mark RestKit setter conversion helpers

- (void)setAvailableColorsCSV:(NSString *)colors
{
	self.availableColors = [colors componentsSeparatedByString:@", "];
}

- (void)setHorizontalJustification:(NSString *)horizontalJustification
{
	if ( [horizontalJustification isEqualToString:@"CENTER"] )
	{
		_horizontalAlignment = UITextAlignmentCenter;
	}
	else if ( [horizontalJustification isEqualToString:@"LEFT"] )
	{
		_horizontalAlignment = UITextAlignmentLeft;
	}
	else if ( [horizontalJustification isEqualToString:@"RIGHT"] )
	{
		_horizontalAlignment = UITextAlignmentRight;
	}
}

- (void)setVerticalJustification:(NSString *)verticalJustification
{
	if ( [verticalJustification isEqualToString:@"MIDDLE"] )
	{
		_verticalAlignment = TextElementVerticalAlignmentMiddle;
	}
	else if ( [verticalJustification isEqualToString:@"BOTTOM"] )
	{
		_verticalAlignment = TextElementVerticalAlignmentBottom;
	}
	else if ( [verticalJustification isEqualToString:@"TOP"] )
	{
		_verticalAlignment = TextElementVerticalAlignmentTop;
	}
}

#pragma mark Text Measurement and SVG

- (void)setText:(NSString *)aText
{
	if ( ![_text isEqualToString:aText] )
	{
		[_text release];

		[self willChangeValueForKey:@"text"];
		[self willChangeValueForKey:@"percentUsed"];
		[self willChangeValueForKey:@"svg"];
		[self willChangeValueForKey:@"characterLimitReached"];

		_text = [aText copy];
		// FIXME: We only want to call this after RestKit has finished
		// setting all of the properties.  (it might be too early
		// to measure the text, otherwise we always want to measure the
		// text when the text changes)
		[self measureText];

		[self didChangeValueForKey:@"text"];
		[self didChangeValueForKey:@"percentUsed"];
		[self didChangeValueForKey:@"svg"];
		[self didChangeValueForKey:@"characterLimitReached"];
	}
}

/**
 * If no current font is defined, return the default font instance.
 */
- (FontInstance *)currentFont
{
	if ( _currentFont )
	{
		return _currentFont;
	}
	else
	{
		return _defaultFont;
	}
}

- (void)setCurrentFont:(FontInstance *)aCurrentFont
{
	if ( aCurrentFont != _currentFont )
	{
		[_currentFont release];

		[self willChangeValueForKey:@"@currentFont"];
		[self willChangeValueForKey:@"percentUsed"];
		[self willChangeValueForKey:@"svg"];
		[self willChangeValueForKey:@"characterLimitReached"];

		_currentFont = [aCurrentFont retain];
		[self measureText];

		[self didChangeValueForKey:@"@currentFont"];
		[self didChangeValueForKey:@"percentUsed"];
		[self didChangeValueForKey:@"svg"];
		[self didChangeValueForKey:@"characterLimitReached"];
	}
}

- (void)measureText
{
	// We need the font and color to create the attributed string that we're going to measure.
	// We also need the font and color to populate the SVG output.

	UIFont *font = self.uiFontFromCurrentFont;

	// Bail out if no font to use
	if ( font == nil )
	{
		// Bail out
		return;
	}

	// Bail out if no text to measure
	if ( _text.length == 0 )
	{
		[_percentUsed release];
		_percentUsed = [[NSNumber alloc] initWithInt:0];

		[_svg release];
		_svg = nil;
		return;
	}

	// Convert the UIFont to a CTFont
	#define FONT_PPI 72
	CGFloat scaledFontSize = font.pointSize / FONT_PPI;
	CTFontRef fontRef = CTFontCreateWithName( (CFStringRef) font.fontName, scaledFontSize, NULL );

	UIColor *color = self.uiColorFromCurrentFont;

	// ----------------------------------------------
	// Initial SVG Font properties
	// ----------------------------------------------

	NSString *fontFamily = (NSString *) CTFontCopyFamilyName( fontRef );
	[fontFamily autorelease];

	CGFloat svgFontSize = font.pointSize / 72;

	// Convert the color into a hex string
	const CGFloat *components = CGColorGetComponents( color.CGColor );
	CGFloat r, g, b;
	switch ( CGColorSpaceGetModel( CGColorGetColorSpace( color.CGColor ) ) )
	{
		case kCGColorSpaceModelMonochrome:
			r = g = b = components[0];
			//			a = components[1];
			break;
		case kCGColorSpaceModelRGB:
			r = components[0];
			g = components[1];
			b = components[2];
			//			a = components[3];
			break;
		default:
			r = g = b = 0;
	}
	r = MIN(MAX( r, 0.0f ), 1.0f);
	g = MIN(MAX( g, 0.0f ), 1.0f);
	b = MIN(MAX( b, 0.0f ), 1.0f);
	int rgb = ( ( (int) roundf( r * 255 ) ) << 16 )
			| ( ( (int) roundf( g * 255 ) ) << 8 )
			| ( ( (int) roundf( b * 255 ) ) );
	NSString *rgbHex = [NSString stringWithFormat:@"%0.6X", rgb];
	NSString *fill = [NSString stringWithFormat:@"#%@", rgbHex];

	NSString *textAnchor = @"start";
	switch ( self.horizontalAlignment )
	{
		case UITextAlignmentLeft:
			break;

		case UITextAlignmentRight:
			textAnchor = @"end";
			break;

		case UITextAlignmentCenter:
			textAnchor = @"middle";
			break;
	}

	// http://www.w3.org/TR/SVG/text.html#FontStyleProperty

	NSString *fontStyle = ( [self.currentFont.style isEqualToString:FontStyleItalic]
			|| [self.currentFont.style isEqualToString:FontStyleBoldItalic] ) ? @"italic"
						  : @"normal"; // normal | italic | oblique | inherit

	//http://www.w3.org/TR/SVG/text.html#FontWeightProperty
	NSString *fontWeight = ( [self.currentFont.style isEqualToString:FontStyleBold]
			|| [self.currentFont.style isEqualToString:FontStyleBoldItalic] ) ? @"bold"
						   : @"normal"; // normal | bold | bolder | lighter | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | inherit

	NSMutableString *output = [[NSMutableString alloc] init];
	[output appendFormat:@"<svg font-family=\"%@\" font-size=\"%05.05f\" fill=\"%@\" text-anchor=\"%@\" font-style=\"%@\" font-weight=\"%@\">",
						 fontFamily, svgFontSize, fill, textAnchor, fontStyle, fontWeight];

	// ----------------------------------------------

	// Measure the text and figure out the line placement
	// Taken from ideas in: http://www.cocoanetics.com/2011/01/befriending-core-text/

	NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
			(id) fontRef, (NSString *) kCTFontAttributeName,
			(id) color.CGColor, (NSString *) kCTForegroundColorAttributeName, nil];
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:attributes];
	[attributedString setAttributes:attributes range:NSMakeRange(0, [attributedString length])];

	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFAttributedStringRef) attributedString );

	// path
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect( path, NULL,
			CGRectMake( 0, 0,
					[self.width floatValue],
					[self.height floatValue] ) );

	// frame
	CTFrameRef frame = CTFramesetterCreateFrame( framesetter,
			CFRangeMake( 0, 0 ),
			path, NULL );

	CGRect frameRect = CGPathGetBoundingBox( path );

	// get lines in frame
	CFArrayRef lines = CTFrameGetLines( frame );
	CFIndex numLines = CFArrayGetCount( lines );

	CFIndex lastLineIndex = numLines - 1;
	CGFloat lineHeight = 0;
	CGFloat totalHeight = 0;
	CGFloat lastLineWidth = 0;

	// This loop creates the SVG for each line
	for ( CFIndex index = 0; index < numLines; index++ )
	{
		CTLineRef line = (CTLineRef) CFArrayGetValueAtIndex( lines, index );

		CGFloat ascent, descent, leading, width;
		width = (CGFloat) CTLineGetTypographicBounds( (CTLineRef) line, &ascent, &descent, &leading );

		CGPoint origin;
		CTFrameGetLineOrigins( frame, CFRangeMake( index, 1 ), &origin );

		//height =  origin.y + descent;
		CGFloat y = CGRectGetMaxY( frameRect ) - origin.y;

		CFRange lineRange = CTLineGetStringRange( line );

		CFAttributedStringRef lineText = CFAttributedStringCreateWithSubstring( kCFAllocatorDefault,
				(CFAttributedStringRef) attributedString,
				lineRange );
		NSAttributedString *lineTextAttributeString = (NSAttributedString *) lineText;

		[output appendFormat:@"<textLine x=\"%0.f\" y=\"%0.f\">%@</textLine>\n",
							 origin.x,
							 y,
							 [lineTextAttributeString string]];
		CFRelease( lineText );

		// Incremenet the total height
		if (index != lastLineIndex) {
			totalHeight += ascent + leading;
			lineHeight = ascent + leading;
		}else {
			totalHeight += leading;
			lastLineWidth = width;
		}
	}

	[output appendString:@"</svg>"];

	[_svg release];
	_svg = [output copy]; // Convert to an immutable NSString
	[output release];

	// FIXME: // With the mock data: Futura, 18, white, center horizontal, top vertical, text = "enter text here some long text with wrap that spans multiple wrapping lines and wrapping yet again", x 0, y 0, width 3.3734583333333337, height 1.
	// Aiming for SVG: <text xml:space="preserve" x="1.6867291666666668" y="0" clip-path="url(#c74DD16B9-0525-F6E0-CD38-1D1BD4E7A6BF)" font-family="Futura" font-size="0.25" fill="#ffffff" text-anchor="middle" font-style="normal" font-weight="normal" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns="http://www.w3.org/2000/svg"><tspan x="1.6867291666666668" y="0.20625">enter text here some long text</tspan><tspan x="1.6867291666666668" y="0.50625">with wrap that spans multiple</tspan><tspan x="1.6867291666666668" y="0.8062499999999999">wrapping lines and wrapping</tspan><tspan x="1.6867291666666668" y="1.10625">yet again</tspan></text>

	NSLog( @"SVG: %@", _svg );

	// This portion creates the used %

	CGFloat numLinesAvailable = ([self.height floatValue] / lineHeight ); // (lineHeight * scaledFontSize));
	CGFloat consumedWidth = ( lastLineIndex * [self.width floatValue] ) + lastLineWidth;
	CGFloat maxConsumableWidth = [self.width floatValue] * floorf( numLinesAvailable );
	CGFloat pixelsUsed = consumedWidth + ( scaledFontSize * 1.5 );
	CGFloat percentUsed = ( pixelsUsed / maxConsumableWidth ) * 100;

	[_percentUsed release];
	_percentUsed = [[NSNumber alloc] initWithFloat:percentUsed];

	NSLog( @"Percent used: %@", _percentUsed );

	// cleanup
	CFRelease( frame );
	CGPathRelease( path );

	[attributes release];
	[attributedString release];
}

- (NSNumber *)percentUsed
{
	return _percentUsed;
}

- (BOOL)characterLimitReached
{
	return [_percentUsed floatValue] > 100;
}

- (NSString *)svg
{
	return _svg;
}

#pragma mark UI helpers

- (UIFont *)uiFontFromCurrentFont
{
	FontInstance *font = self.currentFont;
	CGFloat fontSize = [font.size floatValue];
	return [UIFont fontWithName:font.uiFontFamilyName size:fontSize];
}

// Color macros
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB(r, g, b) RGBA(r, g, b, 1)

- (UIColor *)uiColorFromCurrentFont
{
	FontInstance *font = self.currentFont;

	// Converts the rgb(r,g,b) into an array of three values corresponding to r g and b

	NSString *content = [font.color substringFromIndex:4]; // Remove the front rgb(
	content = [content substringToIndex:content.length - 1]; // Remove the trailining )
	NSArray *components = [content componentsSeparatedByString:@","]; // Split the string by ,

	int r = [( (NSString *) [components objectAtIndex:0] ) intValue];
	int g = [( (NSString *) [components objectAtIndex:1] ) intValue];
	int b = [( (NSString *) [components objectAtIndex:2] ) intValue];

	return RGB( r, g, b );
}

@end
