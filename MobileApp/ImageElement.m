//
//  ImageElement.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "ImageElement.h"
#import "MathUtil.h"

@interface ImageElement (Private)

/**
 * Gets the displayed width of the photo, taking into account the photoRotation.
 *
 * This value is in pixel coordinates.
 */
- (CGFloat)rotatedPhotoWidth;

/**
 * Gets the displayed width of the photo, taking into account the photoRotation.
 *
 * This value is in pixel coordinates.
 */
- (CGFloat)rotatedPhotoHeight;

- (CGRect)adjustCropBoxWithAngle:(CGFloat)angle;

- (CGRect)rotateFullImageUsingAngle:(CGFloat)angle aroundPoint:(CGPoint)midPoint;

- (void)adjustZoomCrop:(CGFloat)zoomFactor;

- (void)adjustPanCropWithX:(CGFloat)dx andY:(CGFloat)dy;

- (void)calculateCropToFillCropBox;

@end

@implementation ImageElement

@synthesize type = _type;

@synthesize assetUri = _assetUri;

@synthesize photoHoleId = _photoHoleId;

@synthesize resolutionIndependentCrop = _resolutionIndependentCrop;

@synthesize photo = _photo;

@synthesize photoRotation = _photoRotation;

@synthesize tintType = _tintType;

#pragma mark Lifecycle

- (id)initWithType:(ImageElementType)type
{
	self = [super init];
	if ( self )
	{
		self.type = type;
		self.resolutionIndependentCrop = CGRectMake( 0, 0, 1, 1 );
		self.tintType = ImageElementTintTypeNone;
	}
	return self;
}

- (id)init
{
	return [self initWithType:ImageElementTypePhotoHole];
}

- (void)dealloc
{
	[_photoHoleId release];
    _photoHoleId = nil;
    
    [_photo release];
	_photo = nil;
    
	[super dealloc];
}

/**
 * For background on why we set iVars to nil first, see
 * http://robnapier.net/blog/implementing-nscopying-439
 */
-(id)mutableCopyWithZone:(NSZone *)zone
{
	ImageElement *copy = [super mutableCopyWithZone:zone];
    
	copy->_photo = nil;
    copy.photo = self.photo;
    
    copy.tintType = self.tintType;
    copy.resolutionIndependentCrop = self.resolutionIndependentCrop;
    copy.photoRotation = self.photoRotation;
    
	return copy;
}

/**
 * This is for RestKit so that we can convert an assert URI into a Photo for
 * Canvas Asset elements.
 *
 * We'll create photoModel object from assetUri here
 */
- (void)setAssetUri:(NSString *)assetUri
{
    self.type = ImageElementTypeCanvasAsset;

	if (![assetUri hasPrefix:@"http"])
    {
        _assetUri = [kRestKitBaseUrl stringByAppendingString:assetUri];
    }
    else
    {
        _assetUri = assetUri;
    }
    
    NSArray *splits = [_assetUri componentsSeparatedByString:@"."]; // Extracting the file extension from filename
    if ([splits count] < 2) // something's wrong in the URI, so we'll just return from here
    {
        NSLog(@"Invalid Canvas AssetURI: %@", assetUri);
        return;
    }
    NSString *uriWithoutExtension = [_assetUri stringByDeletingPathExtension];
    NSString *fileExtension = [_assetUri pathExtension];
    
    NSString *smallUri = [[uriWithoutExtension stringByAppendingString:@"_low."] stringByAppendingString:fileExtension];
    
    PhotoModel *photoModel = [[[PhotoModel alloc] init] autorelease];
    photoModel.smUrl = smallUri;
    photoModel.albUrl = smallUri;
    photoModel.sumoUrl = _assetUri;
    photoModel.bgUrl = _assetUri;
    photoModel.fullResUrl = _assetUri;
    
    self.photo = photoModel;
}

- (NSString *)tintStringValue
{
    if (self.tintType == ImageElementTintTypeNone)
        return TINT_NONE;
    if (self.tintType == ImageElementTintTypeSepia)
        return TINT_SEPIA;
    if (self.tintType == ImageElementTintTypeBlackWhite)
        return TINT_GRAY;
    
    return nil;
}

#pragma mark Photo Rotation

- (CGFloat)rotatedPhotoWidth
{
	if ( _photo == nil )
	{
		return 0;
	}

	// Normal display
	if ( _photoRotation == 0 || _photoRotation == 180 )
	{
		return [_photo.width floatValue];
	}

	// Rotated on its side with rotation of either 90 or -90
	return [_photo.height floatValue];
}

- (CGFloat)rotatedPhotoHeight
{
	if ( _photo == nil )
	{
		return 0;
	}

	// Normal display
	if ( _photoRotation == 0 || _photoRotation == 180 )
	{
		return [_photo.height floatValue];
	}

	// Rotated on its side with rotation of either 90 or -90
	return [_photo.width floatValue];
}

- (void)setPhotoRotation:(CGFloat)photoRotation
{
	if ( _photoRotation != photoRotation )
	{
		CGRect r1;

		if ( photoRotation == 0 )
		{
			r1 = [self adjustCropBoxWithAngle:_photoRotation * -1];
		}
		else
		{
			if ( _photoRotation == 0 )
			{
				r1 = [self adjustCropBoxWithAngle:photoRotation];
			}
			else
			{
				r1 = [self adjustCropBoxWithAngle:-90];
			}
		}

		_photoRotation = photoRotation;


		// Make sure value is one of 0, 90, 180, or -90.  This value
		// is usually += 90 or -= 90, so catch the two corner cases
		// and wrap around.
		if ( _photoRotation == 270 )
		{
			_photoRotation = -90;
		}
		else if ( _photoRotation == -180 )
		{
			_photoRotation = 180;
		}

		self.resolutionIndependentCrop = r1;
	}
}

- (CGRect)adjustCropBoxWithAngle:(CGFloat)angle
{
	// If there is no photo, there is nothing to do
	if ( _photo == nil )
	{
		return _resolutionIndependentCrop;
	}

	CGFloat photoWidth = [self rotatedPhotoWidth];
	CGFloat photoHeight = [self rotatedPhotoHeight];

	CGFloat midX = _resolutionIndependentCrop.origin.x * photoWidth + ( _resolutionIndependentCrop.size.width * photoWidth ) / 2;
	CGFloat midY = _resolutionIndependentCrop.origin.y * photoHeight + ( _resolutionIndependentCrop.size.height * photoHeight ) / 2;

	CGPoint midPoint = CGPointMake( midX, midY );

	CGPoint vertex1 = CGPointMake( _resolutionIndependentCrop.origin.x * photoWidth, _resolutionIndependentCrop.origin.y * photoHeight );
	CGPoint vertex2 = CGPointMake( vertex1.x + ( _resolutionIndependentCrop.size.width * photoWidth ), vertex1.y + ( _resolutionIndependentCrop.size.height * photoHeight ) );

	CGPoint point1 = rotatePoint( vertex1, midPoint, angle );
	CGPoint point2 = rotatePoint( vertex2, midPoint, angle );

	CGFloat rotatedCropX = 0;
	CGFloat rotatedCropY = 0;
	CGFloat rotatedWidth = 0;
	CGFloat rotatedHeight = 0;

	if ( point1.x < point2.x )
	{
		rotatedCropX = point1.x;
		rotatedWidth = ABS( point2.x - point1.x );
	}
	else
	{
		rotatedCropX = point2.x;
		rotatedWidth = ABS( point1.x - point2.x );
	}

	if ( point1.y < point2.y )
	{
		rotatedCropY = point1.y;
		rotatedHeight = ABS( point2.y - point1.y );
	}
	else
	{
		rotatedCropY = point2.y;
		rotatedHeight = ABS( point1.y - point2.y );
	}

//	CGFloat midX1 = rotatedCropX + rotatedWidth / 2;
//	CGFloat midY1 = rotatedCropY + rotatedHeight / 2;

	CGRect rotatedImageRect = [self rotateFullImageUsingAngle:angle aroundPoint:midPoint];

	CGFloat rWidth;
	CGFloat rHeight;
	if ( ( angle == 0 ) && ( ABS( _photoRotation ) == 180 ) )
	{
		rWidth = [_photo.width floatValue];
		rHeight = [_photo.height floatValue];
	}
	else
	{
		if ( ABS( angle ) == 90 )
		{
			rWidth = photoHeight;
			rHeight = photoWidth;
		}
		else
		{
			rWidth = [_photo.width floatValue];
			rHeight = [_photo.height floatValue];
		}
	}

	CGRect cropBoxRect;
	cropBoxRect.origin.x = ABS( rotatedCropX - rotatedImageRect.origin.x ) / rWidth;
	cropBoxRect.origin.y = ABS( rotatedCropY - rotatedImageRect.origin.y ) / rHeight;
	cropBoxRect.size.width = rotatedWidth / rWidth;
	cropBoxRect.size.height = rotatedHeight / rHeight;

	return cropBoxRect;
}

- (CGRect)rotateFullImageUsingAngle:(CGFloat)angle aroundPoint:(CGPoint)midPoint
{
	CGRect pr;

	CGPoint vertex1 = CGPointMake( 0, 0 );
	CGPoint vertex2;

	if ( ABS( _photoRotation ) == 90 )
	{
		vertex2.x = [_photo.height floatValue];
		vertex2.y = [_photo.width floatValue];
	}
	else
	{
		vertex2.x = [_photo.width floatValue];
		vertex2.y = [_photo.height floatValue];
	}

	CGPoint pt1 = rotatePoint( vertex1, midPoint, angle );
	CGPoint pt2 = rotatePoint( vertex2, midPoint, angle );

	if ( pt1.x < pt2.x )
	{
		pr.origin.x = pt1.x;
		pr.size.width = ABS( pt2.x - pt1.x );
	}
	else
	{
		pr.origin.x = pt2.x;
		pr.size.width = ABS( pt1.x - pt2.x );
	}

	if ( pt1.y < pt2.y )
	{
		pr.origin.y = pt1.y;
		pr.size.height = ABS( pt2.y - pt1.y );
	}
	else
	{
		pr.origin.y = pt2.y;
		pr.size.height = ABS( pt1.y - pt2.y );
	}

	return pr;
}

#pragma mark Photo Scale

- (CGFloat)photoScale
{
	return 1 / _resolutionIndependentCrop.size.width;
}

- (void)setPhotoScale:(CGFloat)photoScale
{
	// Constrain: MIN_PHOTO_SCALE <= _photoScale <= MAX_PHOTO_SCALE
	photoScale = MAX( photoScale, MIN_PHOTO_SCALE );
	photoScale = MIN( photoScale, MAX_PHOTO_SCALE );

	[self adjustZoomCrop:(1 / photoScale)];
}

- (void)adjustZoomCrop:(CGFloat)zoomFactor
{
	CGFloat photoWidth = [self rotatedPhotoWidth];
	CGFloat photoHeight = [self rotatedPhotoHeight];

	CGFloat zx = photoWidth * _resolutionIndependentCrop.origin.x;
	CGFloat zy = photoHeight * _resolutionIndependentCrop.origin.y;

	CGFloat wx = photoWidth * _resolutionIndependentCrop.size.width;
	CGFloat wy = photoHeight * _resolutionIndependentCrop.size.height;

	CGFloat nw = photoWidth * zoomFactor;
	CGFloat nh = nw / ( [self.width floatValue] / [self.height floatValue] );

	if ( nh > photoHeight )
	{
		nh = photoHeight;
		nw = nh * ( [self.width floatValue] / [self.height floatValue] );
		//NSLog( @"zoom crop correcting height" );
	}

	CGFloat centerX = zx + wx / 2;
	CGFloat centerY = zy + wy / 2;

	CGFloat lx = centerX - nw / 2;
	CGFloat ly = centerY - nh / 2;

	if ( lx < 0 )
	{
		lx = 0;
	}
	if ( ly < 0 )
	{
		ly = 0;
	}

	if ( ( lx + nw ) > photoWidth )
	{
		lx = photoWidth - nw;
	}

	if ( ( ly + nh ) > photoHeight )
	{
		ly = photoHeight - nh;
	}

	// fix zoom window so it's always in view.
	CGFloat cx = lx / photoWidth;
	CGFloat cy = ly / photoHeight;
	CGFloat cw = nw / photoWidth;
	CGFloat ch = nh / photoHeight;

	self.resolutionIndependentCrop = CGRectMake( cx, cy, cw, ch );
}

- (CGFloat)lowDpiPhotoScale
{
	// Find the low DPI scale in both directions
	CGFloat lowDpiPhotoScaleWidth = [self rotatedPhotoWidth] / ( [self.width floatValue] * LOW_DPI );
	CGFloat lowDpiPhotoScaleHeight = [self rotatedPhotoHeight] / ( [self.height floatValue] * LOW_DPI );

	// The low DPI scale is the smallest of the two scale values.
	return MIN( lowDpiPhotoScaleWidth, lowDpiPhotoScaleHeight );
}

- (BOOL)isLowResolution
{
	CGFloat curPrintedWidth = _resolutionIndependentCrop.size.width * [self rotatedPhotoWidth];
	CGFloat curPrintedHeight = _resolutionIndependentCrop.size.height * [self rotatedPhotoHeight];

	CGFloat curDpiWidth = curPrintedWidth / [self.width floatValue];
	CGFloat curDpiHeight = curPrintedHeight / [self.height floatValue];

	if ( ( curDpiWidth < LOW_DPI ) || ( curDpiHeight < LOW_DPI ) )
	{
		return YES;
	}

	return NO;
}

// FIXME: Ignoring rotation currently, assuming rotatation will be 0
- (CGFloat)outputScale
{
    CGFloat scale;
    /*
    if ( ( _photoRotation == 90 ) || ( _photoRotation == -90 ) )
    {
        sideToCompare = _resolutionIndependentCrop.size.width * photo.width;
        scale = ( height * 300 ) / sideToCompare;
        
        var resultHeight:Number = scale * ( photo.height / 300 );
        if ( Math.abs( resultHeight - width ) > .01 )
        {
            scale2 = ( width * 300 ) / ( photo.height * _resolutionIndependentCrop.size.height );
            if (scale2 > scale) scale = scale2;
        }
    }
    else
    {
     */
    CGFloat sideToCompare = _resolutionIndependentCrop.size.width * [self.photo.width floatValue];
    CGFloat oppSide = _resolutionIndependentCrop.size.height * [self.photo.height floatValue];
    scale = ( [self.width floatValue] * PRINT_DPI ) / sideToCompare;
    if ( ( fabs( oppSide / PRINT_DPI ) * scale - [self.height floatValue] ) > .01 )
    {
        CGFloat scale2 = fabs( ( [self.height floatValue] * PRINT_DPI ) / oppSide );
        if (scale2 > scale) scale = scale2;
    }
    return scale;
}

#pragma mark Translate / Pan

- (void)adjustTranslationUsingPageDeltaX:(CGFloat)pageDeltaX andPageDeltaY:(CGFloat)pageDeltaY
{
	double rotation = [self.rotation doubleValue];
	if ( rotation != 0 )
	{

		double radians = DEGREES_TO_RADIANS( rotation );
		double tanResult = tan( radians );
		if ( ( tanResult < -1 ) || ( tanResult > 1 ) )
		{
			CGFloat tmp = pageDeltaX;
			pageDeltaX = pageDeltaY;
			pageDeltaY = tmp;
			if ( rotation < 0 )
			{
				pageDeltaX = pageDeltaX * -1;
			}
			else
			{
				pageDeltaY = pageDeltaY * -1;
			}
		}
		else
		{
			if ( ( ABS( rotation ) > 135 ) && ( ABS( rotation ) < 225 ) )
			{
				pageDeltaX = pageDeltaX * -1;
				pageDeltaY = pageDeltaY * -1;
			}
		}
	}

	if ( _photoRotation == 0 )
	{
		// No rotation, we can just apply the values
		[self adjustPanCropWithX:( pageDeltaX * PRINT_DPI * -1 ) andY:( pageDeltaY * PRINT_DPI * -1 )];
	}
	else if ( _photoRotation == 90 )
	{
		// Swap X and Y
		[self adjustPanCropWithX:( pageDeltaX * PRINT_DPI ) andY:( pageDeltaY * PRINT_DPI )];
	}
	else if ( _photoRotation == 180 )
	{
		// Apply the values in the opposite direction
		[self adjustPanCropWithX:( pageDeltaX * PRINT_DPI * -1 ) andY:( pageDeltaY * PRINT_DPI * -1 )];
	}
	else if ( _photoRotation == -90 )
	{
		// Swap X and Y and invert the X direction
		[self adjustPanCropWithX:( pageDeltaX * PRINT_DPI ) andY:( pageDeltaY * PRINT_DPI )];
	}
}

- (void)adjustPanCropWithX:(CGFloat)dx andY:(CGFloat)dy
{
	CGFloat photoWidth = [self rotatedPhotoWidth];
	CGFloat photoHeight = [self rotatedPhotoHeight];

	CGFloat zx = photoWidth * _resolutionIndependentCrop.origin.x + dx;
	CGFloat zy = photoHeight * _resolutionIndependentCrop.origin.y + dy;

	CGFloat zw = photoWidth * _resolutionIndependentCrop.size.width;
	CGFloat zh = photoHeight * _resolutionIndependentCrop.size.height;

	if ( zx < 0 )
	{
		zx = 0;
	}

	if ( zy < 0 )
	{
		zy = 0;
	}

	if ( ( zx + zw ) > photoWidth )
	{
		zx = photoWidth - zw;
	}

	if ( ( zy + zh ) > photoHeight )
	{
		zy = photoHeight - zh;
	}

	_resolutionIndependentCrop.origin.x = zx / photoWidth;
	_resolutionIndependentCrop.origin.y = zy / photoHeight;

//	NSLog( @"Pan Op (x, y) = (%f, %f)", _resolutionIndependentCrop.origin.x, _resolutionIndependentCrop.origin.y );
}

// FIXME: Ignoring rotation currently, assuming rotatation will be 0
- (CGPoint)outputTranslation
{
    CGPoint pt;
    pt.x = -1 * ( [self.photo.width floatValue] * _resolutionIndependentCrop.origin.x ) / PRINT_DPI;
    pt.y = -1 * ( [self.photo.height floatValue] * _resolutionIndependentCrop.origin.y ) / PRINT_DPI;
    return ( pt );
}

#pragma mark Crop

- (void)centerCropToFillUsingRotation:(CGFloat)photoRotation
{
	self.photoRotation = photoRotation;

	[self calculateCropToFillCropBox];
}

- (void)calculateCropToFillCropBox
{
	CGFloat photoWidth = [self rotatedPhotoWidth];
	CGFloat photoHeight = [self rotatedPhotoHeight];

	CGFloat width = [self.width floatValue];
	CGFloat height = [self.height floatValue];

	// Figure out the aspect ratio of the image vs. the aspect ratio of the photo hole
	CGFloat photoAspectRatio = photoWidth / photoHeight;
	CGFloat photoHoleAspectRatio = width / height;

#define TOLERANCE .0001
#define PRINT_DPI 300

	if ( ABS( photoHoleAspectRatio - photoAspectRatio ) < TOLERANCE )
	{
		// Aspect ratio is identical, which means we don't need to translate
		self.resolutionIndependentCrop = CGRectMake( 0, 0, 1, 1 );
		return;
	}
	else if ( photoHoleAspectRatio > photoAspectRatio )
	{
		CGFloat sideToCompare = ABS( _photoRotation ) == 90 ? [_photo.height floatValue] : [_photo.width floatValue];
		CGFloat scale = ( width * PRINT_DPI ) / sideToCompare;

		CGFloat tx = ABS( width * PRINT_DPI - photoWidth * scale ) / 2;
		CGFloat ty = ABS( height * PRINT_DPI - photoHeight * scale ) / 2;

		CGFloat cw = 1;
		CGFloat ch = ( photoWidth / photoHoleAspectRatio ) / photoHeight;
		CGFloat cx = tx / ( photoWidth * scale );
		if ( cx < 0 )
		{
			cx = 0;
		}
		CGFloat cy = ty / ( photoHeight * scale );
		if ( cy < 0 )
		{
			cy = 0;
		}

		self.resolutionIndependentCrop = CGRectMake( cx, cy, cw, ch );
		return;
	}
	else if ( photoHoleAspectRatio < photoAspectRatio )
	{
		CGFloat sideToCompare = ABS( _photoRotation ) == 90 ? [_photo.width floatValue] : [_photo.height floatValue];
		CGFloat scale = ( height * PRINT_DPI ) / sideToCompare;

		CGFloat tx = ABS( width * PRINT_DPI - photoWidth * scale ) / 2;
		CGFloat ty = ABS( height * PRINT_DPI - photoHeight * scale ) / 2;

		CGFloat cw = ( width * PRINT_DPI ) / ( photoWidth * scale );
		CGFloat ch = 1;
		CGFloat cx = tx / ( photoWidth * scale );
		if ( cx < 0 )
		{
			cx = 0;
		}
		CGFloat cy = ty / ( photoHeight * scale );
		if ( cy < 0 )
		{
			cy = 0;
		}

		self.resolutionIndependentCrop = CGRectMake( cx, cy, cw, ch );
		return;
	}
}

@end
