//
//  ImageElement.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "LayoutElement.h"
#import "PhotoModel.h"


#define MIN_PHOTO_SCALE 1
#define MAX_PHOTO_SCALE 4

#define LOW_DPI 123
#define PRINT_DPI 300

#define TINT_NONE @"none"
#define TINT_SEPIA @"sepia"
#define TINT_GRAY @"gray"

typedef enum
{
	ImageElementTypePhotoHole = 1, // Photo hole in automatic layouts
	ImageElementTypeTemplateHole = 10, // Photo hole in template layouts
	ImageElementTypeBackground = 2, // Background for entire page
	ImageElementTypeCanvasAsset = 3, // Clip art / embellesment
} ImageElementType;

typedef enum
{
	ImageElementTintTypeNone = 0,
	ImageElementTintTypeSepia = 1,
	ImageElementTintTypeBlackWhite = 2
} ImageElementTintType;

@interface ImageElement : LayoutElement

@property ( nonatomic, assign ) ImageElementType type;

/**
 * URI for the product asset.  This is for RestKit so that we
 * can convert an assert URI into a Photo for Canvas Asset elements.
 */
@property ( nonatomic, copy ) NSString *assetUri;

/**
 * For template-based layouts, this is the id of the photo hole so that
 * it can be matched to a particular id in the layout.
 */
@property ( nonatomic, copy ) NSString *photoHoleId;

/**
 * Resolution independent crop box coordinates, specified as percentage of
 * of total width and height.  Valid values for rectangle properties range
 * from 0 to 1.
 */
@property ( nonatomic, assign ) CGRect resolutionIndependentCrop;

@property ( nonatomic, retain ) PhotoModel *photo;

/**
 * The rotation that the Image control inside the FramedPhoto should
 * have when displaying this image element's photo.
 *
 * This is the rotation value of just the photo.  Example, a portrait
 * photo could be set to photoRotation of 90 to be displayed as
 * landscape.
 *
 * In general, this value is limited to 0, 90, 180, or -90.
 */
@property ( nonatomic, assign ) CGFloat photoRotation;

/**
 * Convenience read/write value to adjust the crop box to a certain scale value.
 */
@property ( nonatomic, assign ) CGFloat photoScale;

/**
 * @return The photoScale value that is the largest scale possible before
 * triggering the low resolution warning for the image.  This value is calculated
 * based on the photo's full resolution width/height (in pixels), the width/height
 * of the image element (in page coordinates (inches)), and the PRINT_DPI constant
 * value that relates how many pixels there are per inch in the printed result.
 */
@property ( nonatomic, readonly ) CGFloat lowDpiPhotoScale;

@property ( nonatomic, assign ) ImageElementTintType tintType;


- (id)initWithType:(ImageElementType)type;

/**
 * Flag indicating if the value of the photo scale will make the photo
 * print out in low resolution.
 *
 * @see #lowDpiPhotoScale
 */
- (BOOL)isLowResolution;


/**
 * This will "center crop to fill" an image.  The crop box will be adjusted so that
 * the image fits into the width and height available for this image element
 * based on the photo's original with and height.
 *
 * The photoScale value be set to 1 (since the photo is not zoomed in).
 *
 * The resulting image display will be centered within the photo hole opening.
 */
- (void)centerCropToFillUsingRotation:(CGFloat)photoRotation;

/**
 * Adjusts the translate x/y values by a certain amount.  Takes into account
 * the photo rotation before adjusting the translation.
 *
 * This method is a helper method to make it easier for the "pan" code to not have
 * to worry about the photo rotation (it just gives us the after-rotation movement
 * in the x and y directions).
 */
- (void)adjustTranslationUsingPageDeltaX:(CGFloat)pageDeltaX andPageDeltaY:(CGFloat)pageDeltaY;

- (CGFloat)outputScale;
- (CGPoint)outputTranslation;
/**
 * Returns string value for tint
 * 0 = none
 * 1 = sepia
 * 2 = gray
 */
- (NSString *)tintStringValue;

@end
