//
//  FramedPhoto.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "FramedPhoto.h"
#import "MathUtil.h"
#import "UIImage+Filtrr.h"
#import "Three20UI/private/TTImageViewInternal.h"


@interface FramedPhoto (Private)
- (void)applyTint;
@end

@implementation FramedPhoto

@synthesize imageElement = _imageElement;

#pragma Init / Dealloc

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		self.autoresizesSubviews = NO;
		self.autoresizingMask = UIViewAutoresizingNone;
		self.clipsToBounds = YES;

		_imageElementView = [[TTPhotoView alloc] init];
		_imageElementView.hidesExtras = YES;
		_imageElementView.hidesCaption = YES;
		_imageElementView.autoresizesToImage = NO;
		_imageElementView.autoresizingMask = UIViewAutoresizingNone;
		_imageElementView.autoresizesSubviews = NO;
		_imageElementView.clipsToBounds = NO;
		_imageElementView.delegate = self;

		[self addSubview:_imageElementView];
	}
	return self;
}

- (void)dealloc
{
	[_imageElement removeObserver:self forKeyPath:@"photo"];
	[_imageElement removeObserver:self forKeyPath:@"resolutionIndependentCrop"];
    [_imageElement removeObserver:self forKeyPath:@"tintType"];
	[_imageElement release];
	_imageElement = nil;

	[_imageElementView release];
	_imageElementView = nil;

	[super dealloc];
}

#pragma mark -

- (void)setImageElement:(ImageElement *)anImageElement
{
	if ( _imageElement != anImageElement )
	{
		[_imageElement removeObserver:self forKeyPath:@"photo"];
		[_imageElement removeObserver:self forKeyPath:@"resolutionIndependentCrop"];
		[_imageElement removeObserver:self forKeyPath:@"tintType"];
		[_imageElement release];

		_imageElement = [anImageElement retain];

		[_imageElement addObserver:self forKeyPath:@"resolutionIndependentCrop" options:NSKeyValueObservingOptionNew context:NULL];
		[_imageElement addObserver:self forKeyPath:@"photo" options:NSKeyValueObservingOptionNew context:NULL];

		tintTypeApplied = ImageElementTintTypeNone;
		[_imageElement addObserver:self forKeyPath:@"tintType" options:NSKeyValueObservingOptionNew context:NULL];

		_imageElementView.photo = _imageElement.photo;
		[_imageElementView loadImage];

		// The _imageElementView imageViewDidLoadImage method will send the
		// setNeedsLayout message to us when it's time to display the image.
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	_imageElementView.contentMode = UIViewContentModeScaleAspectFit;

	CGFloat photoWidth = _imageElementView.image.size.width;
	CGFloat photoHeight = _imageElementView.image.size.height;

	CGFloat cropBoxXInPixels = photoWidth * _imageElement.resolutionIndependentCrop.origin.x;
	CGFloat cropBoxYInPixels = photoHeight * _imageElement.resolutionIndependentCrop.origin.y;
	CGFloat cropBoxWidthInPixels = photoWidth * _imageElement.resolutionIndependentCrop.size.width;
	CGFloat cropBoxHeightInPixels = photoHeight * _imageElement.resolutionIndependentCrop.size.height;
    
    // We can't proceed to layout the photo view if there is no width or height
    if ( cropBoxWidthInPixels == 0 || cropBoxHeightInPixels == 0 )
    {
        return;
    }

	// Find the ratio between the crop box and the framed photo view area
	CGFloat sideToCompare = ABS( _imageElement.photoRotation ) == 90 ? cropBoxHeightInPixels : cropBoxWidthInPixels;
	CGFloat ratio = self.frame.size.width / sideToCompare;

	// Calculate the new width/height for the image based on the display ratio
	CGRect imageElementFrame = _imageElementView.frame;
	imageElementFrame.size.width = photoWidth * ratio;
	imageElementFrame.size.height = photoHeight * ratio;

	// Get the center of the crop box
	CGFloat cropBoxCenterX = cropBoxXInPixels + ( cropBoxWidthInPixels / 2 );
	CGFloat cropBoxCenterY = cropBoxYInPixels + ( cropBoxHeightInPixels / 2 );

	// Get the scaled center of the crop box
	CGPoint center = CGPointMake( cropBoxCenterX * ratio, cropBoxCenterY * ratio );

	// Rotate the center based on the photo rotation
// We don't need to calculate the new center because iOS rotates view around the center (as opposed
// to Flash, which rotates around the top-left).
//	CGAffineTransform transform = CGAffineTransformMakeRotation( DEGREES_TO_RADIANS( _imageElement.photoRotation ) );
//	CGPoint newCenter = CGPointApplyAffineTransform( center, transform );

	// Offset/translate the image based on the new found center
	imageElementFrame.origin.x = ( 0 - center.x ) + ( self.frame.size.width / 2 );
	imageElementFrame.origin.y = ( 0 - center.y ) + ( self.frame.size.height / 2 );

	// Apply the new size and position to the image
	_imageElementView.frame = imageElementFrame;

	// Rotate the image to match the photo rotation value
	_imageElementView.transform = CGAffineTransformMakeRotation( (CGFloat)DEGREES_TO_RADIANS( _imageElement.photoRotation ) );

	// TODO Check for pixelation - Skipped for now because we'll get a 640x480 image, which is
	// good enough for display on the iPhone
}

#pragma mark TTImageViewDelegate

- (void)imageView:(TTImageView *)imageView didLoadImage:(UIImage *)image
{
	[self applyTint];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( object == _imageElement )
	{
		if ( [keyPath isEqualToString:@"tintType"] )
		{
			[self applyTint];
		}
		else if ( [keyPath isEqualToString:@"resolutionIndependentCrop"] )
		{
			[self setNeedsLayout];
		}
		else if ( [keyPath isEqualToString:@"photo"] )
		{
			tintTypeApplied = ImageElementTintTypeNone;
			_imageElementView.photo = _imageElement.photo;
			[_imageElementView loadImage];

			// The _imageElementView imageViewDidLoadImage method will send the
			// setNeedsLayout message to us when it's time to display the image.
		}
	}
}

- (void)applyTint
{
	// Only apply the tint if there is an image loaded
	if ( tintTypeApplied != _imageElement.tintType && _imageElementView.image )
	{
		tintTypeApplied = _imageElement.tintType;

		if ( _imageElement.tintType == ImageElementTintTypeNone )
        {
            [_imageElementView reload];
        }
        else if ( _imageElement.tintType == ImageElementTintTypeSepia )
		{
			[_imageElementView setImage:[_imageElementView.image sepia]];
		}
		else if ( _imageElement.tintType == ImageElementTintTypeBlackWhite )
		{
			[_imageElementView setImage:[_imageElementView.image grayScale]];
		}

	}
}

@end
