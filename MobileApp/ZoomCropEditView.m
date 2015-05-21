//
//  ZoomCropEditView.m
//  MobileApp
//
//  Created by Darron Schall on 2/29/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//
//  Initial implementation based on BJImageCropper, available from
//  https://github.com/barrettj/BJImageCropper

#import "ZoomCropEditView.h"
#import "MathUtil.h"
#import "Three20UI/private/TTImageViewInternal.h"
#import "UIImage+Filtrr.h"

@interface ZoomCropEditView (Private)

- (void)applyTintToImage:(UIImage *)image;
- (void)setup;
- (UIView *)newEdgeView;
- (UIView *)newCornerView;
- (void)updateBounds;
@end

@implementation ZoomCropEditView

@synthesize photoView;
@synthesize tintType = _tintType;

#pragma mark init / dealloc

- (id)initWithImageElement:(ImageElement *)imageElement andFrameSize:(CGSize)frameSize
{
	self = [super init];
	if ( self )
	{
		CGRect frame = self.frame;
		frame.size.width = frameSize.width;
		frame.size.height = frameSize.height;
		self.frame = frame;

		_imageElement = imageElement;
		[_imageElement retain];

		tintTypeApplied = ImageElementTintTypeNone;
		_tintType = imageElement.tintType;

		CGSize imageSize = CGSizeMake( [_imageElement.photo.width floatValue], [_imageElement.photo.height floatValue] );
		// Preserve the aspect ratio of the image and make it fit within the maxSize so we know
		// what size to use for the photo view frame.
		CGSize scaledImageSize = fitSizeInSize( imageSize, frameSize );

		// The image scale is a multiplier to convert the crop coordinates to the pixel values of the photo
		imageScale = scaledImageSize.height / imageSize.height;

		photoView = [[TTPhotoView alloc] initWithFrame:CGRectMake( 0, 0, scaledImageSize.width, scaledImageSize.height )];
		photoView.center = self.center;

		photoView.hidesExtras = YES;
		photoView.hidesCaption = YES;
		photoView.autoresizesToImage = NO;
		photoView.autoresizingMask = UIViewAutoresizingNone;
		photoView.autoresizesSubviews = NO;
		photoView.clipsToBounds = NO;
		photoView.contentMode = UIViewContentModeScaleAspectFit;

		photoView.photo = _imageElement.photo;
		photoView.delegate = self;
		[photoView loadImage];

		[self addSubview:photoView];

		[self setup];
	}

	return self;
}

- (id)init
{
	self = [super init];
	if ( self )
	{
		[self setup];
	}

	return self;
}


- (void)setup
{
	self.userInteractionEnabled = YES;
	self.multipleTouchEnabled = YES;
	self.backgroundColor = [UIColor clearColor];

	cropView = [ZoomCropEditView initialCropViewForPhotoView:photoView withImageElement:_imageElement];
	[self.photoView addSubview:cropView];

	topView = [self newEdgeView];
	bottomView = [self newEdgeView];
	leftView = [self newEdgeView];
	rightView = [self newEdgeView];
	topLeftView = [self newCornerView];
	topRightView = [self newCornerView];
	bottomLeftView = [self newCornerView];
	bottomRightView = [self newCornerView];

	[cropView retain];

	[self updateBounds];
}


- (void)dealloc
{
	[photoView release];

	[cropView release];

	[topView release];
	[bottomView release];
	[leftView release];
	[rightView release];

	[topLeftView release];
	[topRightView release];
	[bottomLeftView release];
	[bottomRightView release];

    [_imageElement release];

	[super dealloc];
}

#pragma mark TTImageViewDelegate

- (void)imageView:(TTImageView *)imageView didLoadImage:(UIImage *)image
{
	[self applyTintToImage:image];
}

#pragma mark - Init helpers

- (UIView *)newEdgeView
{
	UIView *view = [[UIView alloc] init];
	view.backgroundColor = [UIColor blackColor];
	view.alpha = 0.5;

	[self.photoView addSubview:view];

	return view;
}

- (UIView *)newCornerView
{
	UIView *view = [self newEdgeView];
	view.alpha = 0.75;

	return view;
}

+ (UIView *)initialCropViewForPhotoView:(TTPhotoView *)photoView withImageElement:(ImageElement *)imageElement
{
	CGFloat photoWidth = photoView.frame.size.width;
	CGFloat photoHeight = photoView.frame.size.height;

	CGFloat x = photoWidth * imageElement.resolutionIndependentCrop.origin.x;
	CGFloat y = photoHeight * imageElement.resolutionIndependentCrop.origin.y;
	CGFloat width = photoWidth * imageElement.resolutionIndependentCrop.size.width;
	CGFloat height = photoHeight * imageElement.resolutionIndependentCrop.size.height;

	UIView *cropView = [[UIView alloc] initWithFrame:CGRectMake( x, y, width, height )];
	cropView.layer.borderColor = [[UIColor whiteColor] CGColor];
	cropView.layer.borderWidth = 2.0;
	cropView.backgroundColor = [UIColor clearColor];
	cropView.alpha = 0.4;

	return [cropView autorelease];
}

#pragma mark - Zooming and Panning

- (void)constrainCropToImage
{
	CGRect frame = cropView.frame;

	if ( CGRectEqualToRect( frame, CGRectZero ) )
	{
		return;
	}

	BOOL change = NO;

	do
	{
		change = NO;

		if ( frame.origin.x < 0 )
		{
			frame.origin.x = 0;
			change = YES;
		}

		if ( frame.size.width > cropView.superview.frame.size.width )
		{
			frame.size.width = cropView.superview.frame.size.width;
			change = YES;
		}

		if ( frame.size.width < 20 )
		{
			frame.size.width = 20;
			change = YES;
		}

		if ( frame.origin.x + frame.size.width > cropView.superview.frame.size.width )
		{
			frame.origin.x = cropView.superview.frame.size.width - frame.size.width;
			change = YES;
		}

		if ( frame.origin.y < 0 )
		{
			frame.origin.y = 0;
			change = YES;
		}

		if ( frame.size.height > cropView.superview.frame.size.height )
		{
			frame.size.height = cropView.superview.frame.size.height;
			change = YES;
		}

		if ( frame.size.height < 20 )
		{
			frame.size.height = 20;
			change = YES;
		}

		if ( frame.origin.y + frame.size.height > cropView.superview.frame.size.height )
		{
			frame.origin.y = cropView.superview.frame.size.height - frame.size.height;
			change = YES;
		}
	} while ( change );

	cropView.frame = frame;
}

- (void)updateBounds
{
	[self constrainCropToImage];

	CGRect frame = cropView.frame;
	CGFloat x = frame.origin.x;
	CGFloat y = frame.origin.y;
	CGFloat width = frame.size.width;
	CGFloat height = frame.size.height;

	CGFloat selfWidth = self.photoView.frame.size.width;
	CGFloat selfHeight = self.photoView.frame.size.height;

	topView.frame = CGRectMake( x, -1, width + 1, y );
	bottomView.frame = CGRectMake( x, y + height, width, selfHeight - y - height );
	leftView.frame = CGRectMake( -1, y, x + 1, height );
	rightView.frame = CGRectMake( x + width, y, selfWidth - x - width, height );

	topLeftView.frame = CGRectMake( -1, -1, x + 1, y + 1 );
	topRightView.frame = CGRectMake( x + width, -1, selfWidth - x - width, y + 1 );
	bottomLeftView.frame = CGRectMake( -1, y + height, x + 1, selfHeight - y - height );
	bottomRightView.frame = CGRectMake( x + width, y + height, selfWidth - x - width, selfHeight - y - height );

	[self didChangeValueForKey:@"crop"];
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
	float x = toPoint.x - fromPoint.x;
	float y = toPoint.y - fromPoint.y;

	return sqrt( x * x + y * y );
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self willChangeValueForKey:@"crop"];
	NSSet *allTouches = [event allTouches];

	switch ( [allTouches count] )
	{
		case 1:
		{
			currentTouches = 1;
			isPanning = NO;
			//CGFloat insetAmount = IMAGE_CROPPER_INSIDE_STILL_EDGE;
			CGFloat insetAmount = 0;

			CGPoint touch = [[allTouches anyObject] locationInView:self.photoView];
			if ( CGRectContainsPoint( CGRectInset( cropView.frame, insetAmount, insetAmount ), touch ) )
			{
				isPanning = YES;
				panTouch = touch;
				return;
			}
			break;

		}
		case 2:
		{
			CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.photoView];
			CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self.photoView];

			if ( currentTouches == 0 && CGRectContainsPoint( cropView.frame, touch1 ) && CGRectContainsPoint( cropView.frame, touch2 ) )
			{
				isPanning = YES;
			}

			currentTouches = [allTouches count];
			break;
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self willChangeValueForKey:@"crop"];
	NSSet *allTouches = [event allTouches];

	switch ( [allTouches count] )
	{
		case 1:
		{
			if ( isPanning )
			{
				CGPoint touchCurrent = [[allTouches anyObject] locationInView:self.photoView];
				CGFloat x = touchCurrent.x - panTouch.x;
				CGFloat y = touchCurrent.y - panTouch.y;

				cropView.center = CGPointMake( cropView.center.x + x, cropView.center.y + y );

				panTouch = touchCurrent;
			}
		}
			break;
		case 2:
		{
			CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.photoView];
			CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self.photoView];

			if ( isPanning )
			{
				CGFloat distance = [self distanceBetweenTwoPoints:touch1 toPoint:touch2];

				if ( scaleDistance != 0 )
				{
					CGFloat scale = 1.0f + ( ( distance - scaleDistance ) / scaleDistance );

					CGPoint originalCenter = cropView.center;
					CGSize originalSize = cropView.frame.size;

					CGSize newSize = CGSizeMake( originalSize.width * scale, originalSize.height * scale );

					if ( newSize.width >= 50 && newSize.height >= 50 && newSize.width <= cropView.superview.frame.size.width && newSize.height <= cropView.superview.frame.size.height )
					{
						cropView.frame = CGRectMake( 0, 0, newSize.width, newSize.height );
						cropView.center = originalCenter;
					}
				}

				scaleDistance = distance;
			}
			else if (
					currentDragView == topLeftView ||
							currentDragView == topRightView ||
							currentDragView == bottomLeftView ||
							currentDragView == bottomRightView
					)
			{
				CGFloat x = MIN(touch1.x, touch2.x);
				CGFloat y = MIN(touch1.y, touch2.y);

				CGFloat width = MAX(touch1.x, touch2.x) - x;
				CGFloat height = MAX(touch1.y, touch2.y) - y;

				cropView.frame = CGRectMake( x, y, width, height );
			}
			else if (
					currentDragView == topView ||
							currentDragView == bottomView
					)
			{
				CGFloat y = MIN(touch1.y, touch2.y);
				CGFloat height = MAX(touch1.y, touch2.y) - y;

				// sometimes the multi touch gets in the way and registers one finger as two quickly
				// this ensures the crop only shrinks a reasonable amount all at once
				if ( height > 30 || cropView.frame.size.height < 45 )
				{
					cropView.frame = CGRectMake( cropView.frame.origin.x, y, cropView.frame.size.width, height );
				}
			}
			else if (
					currentDragView == leftView ||
							currentDragView == rightView
					)
			{
				CGFloat x = MIN(touch1.x, touch2.x);
				CGFloat width = MAX(touch1.x, touch2.x) - x;

				// sometimes the multi touch gets in the way and registers one finger as two quickly
				// this ensures the crop only shrinks a reasonable amount all at once
				if ( width > 30 || cropView.frame.size.width < 45 )
				{
					cropView.frame = CGRectMake( x, cropView.frame.origin.y, width, cropView.frame.size.height );
				}
			}
		}
			break;
	}

	[self updateBounds];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( currentTouches == 1 )
    {
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Edit Photo:Pan"];
    }
    else if ( currentTouches == 2 )
    {
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Edit Photo:Scale"];
    }
    
    
	scaleDistance = 0;
	currentTouches = [[event allTouches] count];
}

#pragma mark Crop and Resolution properties

- (CGRect)crop
{
	CGRect frame = cropView.frame;

	if ( frame.origin.x <= 0 )
	{
		frame.origin.x = 0;
	}

	if ( frame.origin.y <= 0 )
	{
		frame.origin.y = 0;
	}


	return CGRectMake( frame.origin.x / imageScale, frame.origin.y / imageScale, frame.size.width / imageScale, frame.size.height / imageScale );;
}

- (void)setCrop:(CGRect)crop
{
	cropView.frame = CGRectMake( crop.origin.x * imageScale, crop.origin.y * imageScale, crop.size.width * imageScale, crop.size.height * imageScale );
	[self updateBounds];
}

- (CGRect)resolutionIndependentCrop
{
	CGFloat photoWidth = photoView.frame.size.width;
	CGFloat photoHeight = photoView.frame.size.height;

	return CGRectMake( cropView.frame.origin.x / photoWidth, cropView.frame.origin.y / photoHeight, cropView.frame.size.width / photoWidth, cropView.frame.size.height / photoHeight );
}

- (BOOL)isLowResolution
{
	ImageElement *imageElement = [[[ImageElement alloc] init] autorelease];

	// Set the values that we need on the image element in order to get the isLowResolution
	// calculation.
	// This is a little brittle - if the isLowResolution method ever changes its dependencies
	// then this code will break.  Probably better to refactor into a helper method that takes
	// the values as parameters.
	imageElement.width = _imageElement.width;
	imageElement.height = _imageElement.height;
	imageElement.photo = _imageElement.photo;
	imageElement.photoRotation = _imageElement.photoRotation;
	imageElement.resolutionIndependentCrop = self.resolutionIndependentCrop;

	return [imageElement isLowResolution];
}


#pragma mark Tint

- (void)setTintType:(ImageElementTintType)aTintType
{
	_tintType = aTintType;
	[self applyTintToImage:photoView.image];
}

- (void)applyTintToImage:(UIImage *)image
{
	// Only apply tint if we have an image available
	if ( tintTypeApplied != _tintType && image )
	{
		tintTypeApplied = _tintType;

		// FIXME: If we're displaying sepia or black and white and we
		// switch to sepia or black and white, the call to [image sepia]
		// will wash out the photo some (because it applies the filter
		// on the *already filtered* image, vs. the original image.  So
		// in that case we have to reload to get the original bitmap data
		// and then tint after that.
		//
		// The workaround is to set the tintType to None first (in the external
		// caller) before setting the tint type to sepia or black and white again.

		if ( _tintType == ImageElementTintTypeNone )
		{
			[photoView reload];
		}
		else if ( _tintType == ImageElementTintTypeSepia )
		{
			[photoView setImage:[image sepia]];
		}
		else if ( _tintType == ImageElementTintTypeBlackWhite )
		{
			[photoView setImage:[image grayScale]];
		}
	}
}

@end