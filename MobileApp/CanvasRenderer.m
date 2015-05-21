//
//  CanvasRenderer.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "CanvasRenderer.h"
#import "FramedPhoto.h"
#import "FramedText.h"
#import "MathUtil.h"

@interface CanvasRenderer (Private)

- (void)processViewUpdateForLayoutChangeByTearDownAndSetUp;

- (void)processBackground;

- (FramedPhoto *)backgroundView;

- (void)createViewForLayoutElement:(LayoutElement *)layoutElement;

- (void)createFramedPhotoForImageElement:(ImageElement *)imageElement;

- (void)createFramedPhotoForImageElement:(ImageElement *)imageElement atIndex:(NSUInteger)index;

- (void)createFramedTextForTextElement:(TextElement *)textElement;

- (void)positionAndSizeSubview:(UIView *)subview;

- (void)positionAndSizeFramedPhoto:(FramedPhoto *)framedPhoto;

- (void)positionAndSizeFramedText:(FramedText *)framedText;

@end

@implementation CanvasRenderer

@synthesize page = _page;

#pragma Init / Dealloc

- (void)commonInit
{
	self.autoresizesSubviews = NO;
	self.autoresizingMask = UIViewAutoresizingNone;
	self.clipsToBounds = YES;

	_pointTranslator = [[PointTranslator alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		[self commonInit];
	}
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	[self commonInit];
}

- (void)dealloc
{
	[_page release];
	_page = nil;

	[_pointTranslator release];
	_pointTranslator = nil;

	[super dealloc];
}

#pragma mark Page Processing

- (void)setPage:(Page *)page
{
	if ( _page != page )
	{
		[_page release];
		_page = [page retain];

		Layout *layout = _page.layout;
		CGRect originalSpace = CGRectMake( [layout.x floatValue], [layout.y floatValue], [layout.x floatValue] + [layout.width floatValue], [layout.y floatValue] + [layout.height floatValue] );
		[_pointTranslator setOriginalSpaceRectangle:originalSpace];

		[self processViewUpdateForLayoutChangeByTearDownAndSetUp];
		[self processBackground];

		[self setNeedsLayout];
	}
}

- (void)processViewUpdateForLayoutChangeByTearDownAndSetUp
{
	// Tear down the entire view hierarchy
	for ( UIView *view in self.subviews )
	{
		[view removeFromSuperview];
	}

	// Set up views for all of the layout elements
	for ( LayoutElement *layoutElement in self.page.layout.elements )
	{
		[self createViewForLayoutElement:layoutElement];
	}
}

/**
 * Creates a background for the page.  If a background image already exists,
 * updates the photo to point to the new location.
 */
- (void)processBackground
{
	FramedPhoto *backgroundView = [self backgroundView];

	ImageElement *backgroundImageElement = self.page.background;

	// Check for now background and clear any background reference we might have
	if ( backgroundImageElement == nil )
	{
		// TODO: Anything special to uncache the image?  Just let Three20 handle it for now...

		[backgroundView removeFromSuperview];
	}
	else // We have a background to display
	{
		// If no current background, we need to create one
		if ( !backgroundView )
		{
			// Force background as the bottom layer
			[self createFramedPhotoForImageElement:backgroundImageElement atIndex:0];
		}
		else // We can just replacing the existing background element with the new one
		{
			backgroundView.imageElement = backgroundImageElement;
		}
	}

}

- (FramedPhoto *)backgroundView
{
	for ( UIView *view in self.subviews )
	{
		if ( [view isKindOfClass:[FramedPhoto class]] )
		{
			FramedPhoto *framedPhoto = (FramedPhoto *) view;
			if ( framedPhoto.imageElement.type == ImageElementTypeBackground )
			{
				return framedPhoto;
			}
		}
	}

	return nil;
}

- (void)createViewForLayoutElement:(LayoutElement *)layoutElement
{
	if ( [layoutElement isKindOfClass:[ImageElement class]] )
	{
		ImageElement *imageElement = (ImageElement *) layoutElement;

		if ( imageElement.type == ImageElementTypeBackground )
		{
			// Error, not expecting background type in layout elements.  This should
			// be set as page.background instead.
			return;
		}

		[self createFramedPhotoForImageElement:imageElement];
	}
	else if ( [layoutElement isKindOfClass:[TextElement class]] )
	{
		[self createFramedTextForTextElement:(TextElement *) layoutElement];
	}
}

- (void)createFramedPhotoForImageElement:(ImageElement *)imageElement
{
	// Place framed photo at the top of the view layering order
	[self createFramedPhotoForImageElement:imageElement atIndex:[self.subviews count]];
}

- (void)createFramedPhotoForImageElement:(ImageElement *)imageElement atIndex:(NSUInteger)index
{
	FramedPhoto *framedPhoto = [[FramedPhoto alloc] init];
	framedPhoto.imageElement = imageElement;

	[self insertSubview:framedPhoto atIndex:index];
	[framedPhoto release];
}

- (void)createFramedTextForTextElement:(TextElement *)textElement
{
	FramedText *framedText = [[FramedText alloc] init];
	framedText.textElement = textElement;

	[self addSubview:framedText];
	[framedText release];
}

#pragma mark Layout

- (void)layoutSubviews
{
	[super layoutSubviews];

	// Get the aspect ratio (pixel dimensions) of the page that will fit within the canvas bounds
	pageAreaInPixels = fitSizeInSize( self.page.finishedLayoutArea.size, self.frame.size );
	self.bounds = CGRectMake( 0, 0, pageAreaInPixels.width, pageAreaInPixels.height );
	[_pointTranslator setTargetSpaceRectangle:CGRectMake( 0, 0, pageAreaInPixels.width, pageAreaInPixels.height )];

	// Adjust all of the subviews
	for ( UIView *view in self.subviews )
	{
		[self positionAndSizeSubview:view];
	}
}

- (void)positionAndSizeSubview:(UIView *)subview
{
	if ( [subview isKindOfClass:[FramedPhoto class]] )
	{
		[self positionAndSizeFramedPhoto:(FramedPhoto *) subview];
	}
	else if ( [subview isKindOfClass:[FramedText class]] )
	{
		[self positionAndSizeFramedText:(FramedText *) subview];
	}
}

- (void)positionAndSizeFramedPhoto:(FramedPhoto *)framedPhoto
{
	ImageElement *imageElement = framedPhoto.imageElement;

	CGPoint pointToTransform = CGPointMake( [imageElement.x floatValue], [imageElement.y floatValue] );

	CGRect frame = framedPhoto.frame;
	frame.origin = [_pointTranslator transformPoint:pointToTransform];
	frame.size = CGSizeMake( [imageElement.width floatValue] * _pointTranslator.scaleX, [imageElement.height floatValue] * _pointTranslator.scaleY );
	framedPhoto.frame = frame;

	// TODO Visible clip area - We can't set bounds here because that affects how the framed photo
	// draws, so if we need to know the visible area (in bleed situations), well need to make a
	// visibleRect property of framed photo and set it.  See B2: updateFramedPhotoVisibleRectangle
	//framedPhoto.bounds...

	framedPhoto.transform = CGAffineTransformMakeRotation( (CGFloat) DEGREES_TO_RADIANS( [imageElement.rotation floatValue] ) );
}

- (void)positionAndSizeFramedText:(FramedText *)framedText
{
	TextElement *textElement = framedText.textElement;

	CGPoint pointToTransform = CGPointMake( [textElement.x floatValue], [textElement.y floatValue] );

	CGRect frame = framedText.frame;
	frame.origin = [_pointTranslator transformPoint:pointToTransform];
	frame.size = CGSizeMake( [textElement.width floatValue] * _pointTranslator.scaleX,
			[textElement.height floatValue] * _pointTranslator.scaleY );
	framedText.frame = frame;

	framedText.transform = CGAffineTransformMakeRotation( (CGFloat) DEGREES_TO_RADIANS( [textElement.rotation floatValue] ) );
}


@end
