//
//  FramedText.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "FramedText.h"
#import <CoreText/CoreText.h>

#define FONT_PPI 72

@interface FramedText (Private)

- (void)configureFontDisplay;

@end

@implementation FramedText

@synthesize textElement = _textElement;

#pragma mark Init / Dealloc

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		self.autoresizesSubviews = NO;
		self.autoresizingMask = UIViewAutoresizingNone;
		self.clipsToBounds = YES;

		_textLayer = [[CATextLayer alloc] init];
		_textLayer.contentsScale = [[UIScreen mainScreen] scale];
		_textLayer.frame = self.frame;
		[self.layer addSublayer:_textLayer];
	}
	return self;
}

- (void)dealloc
{
	[_textLayer release];

	[_textElement removeObserver:self forKeyPath:@"currentFont"];
	[_textElement removeObserver:self forKeyPath:@"text"];
	[_textElement release];

	[super dealloc];
}

#pragma mark -

- (void)setTextElement:(TextElement *)aTextElement
{
	if ( _textElement != aTextElement )
	{
		[_textElement removeObserver:self forKeyPath:@"currentFont"];
		[_textElement removeObserver:self forKeyPath:@"text"];
		[_textElement release];

		_textElement = [aTextElement retain];
		[_textElement addObserver:self forKeyPath:@"currentFont" options:NSKeyValueObservingOptionNew context:NULL];
		[_textElement addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];

		_textLayer.string = _textElement.text;

		[self setNeedsLayout];
	}
}

- (void)configureFontDisplay
{
	UIFont *font = _textElement.uiFontFromCurrentFont;
	UIColor *color = _textElement.uiColorFromCurrentFont;

	// Change the font size to reflect the scale at which the frame text is drawn at
	CGFloat xDPI = self.frame.size.width / [_textElement.width floatValue];
	CGFloat scaledFontSize = font.pointSize * (xDPI / FONT_PPI );

	// Convert the UIFont to a CTFont, using the scaledFontSize
	CTFontRef fontRef = CTFontCreateWithName( (CFStringRef) font.fontName, scaledFontSize, NULL );

	// Apply the CTFont to the Core Text layer
	_textLayer.font = fontRef;
	_textLayer.fontSize = CTFontGetSize( fontRef );
	_textLayer.foregroundColor = color.CGColor;

	// Configure the rest of the layer display properties
	_textLayer.wrapped = YES;

	// Figure out the horizontal alignment value
	NSString *alignmentMode = kCAAlignmentNatural;
	if ( _textElement.horizontalAlignment == UITextAlignmentLeft )
	{
		alignmentMode = kCAAlignmentLeft;
	}
	else if ( _textElement.horizontalAlignment == UITextAlignmentCenter )
	{
		alignmentMode = kCAAlignmentCenter;
	}

	else if ( _textElement.horizontalAlignment == UITextAlignmentRight )
	{
		alignmentMode = kCAAlignmentRight;
	}
	_textLayer.alignmentMode = alignmentMode;
}

- (void)layoutSubviews
{
	_textLayer.frame = self.frame;
	[self configureFontDisplay];

	[super layoutSubviews];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( object == _textElement )
	{
		if ( [keyPath isEqualToString:@"currentFont"] )
		{
			[self configureFontDisplay];
		}
		else if ( [keyPath isEqualToString:@"text"] )
		{
			_textLayer.string = _textElement.text;
		}
	}
}

@end
