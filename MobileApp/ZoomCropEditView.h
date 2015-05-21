//
//  ZoomCropEditView.h
//  MobileApp
//
//  Created by Darron Schall on 2/29/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//
//  Initial implementation based on BJImageCropper, available from
//  https://github.com/barrettj/BJImageCropper

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "ImageElement.h"

#define IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE 40.0f
#define IMAGE_CROPPER_INSIDE_STILL_EDGE 20.0f


@interface ZoomCropEditView : UIView <TTImageViewDelegate>
{
	TTPhotoView *photoView;

	// Store the tint type that is applied so we don't try to tint
	// multiple times for the same time.
	ImageElementTintType tintTypeApplied;

	UIView *cropView;

	UIView *topView;
	UIView *bottomView;
	UIView *leftView;
	UIView *rightView;

	UIView *topLeftView;
	UIView *topRightView;
	UIView *bottomLeftView;
	UIView *bottomRightView;

	CGFloat imageScale;

	BOOL isPanning;
	NSInteger currentTouches;
	CGPoint panTouch;
	CGFloat scaleDistance;
	UIView *currentDragView; // Weak reference

	ImageElement *_imageElement;
}

@property ( nonatomic, assign ) CGRect crop;
@property ( nonatomic, readonly ) CGRect resolutionIndependentCrop;

@property ( nonatomic, assign ) ImageElementTintType tintType;

@property ( nonatomic, retain, readonly ) TTPhotoView *photoView;

+ (UIView *)initialCropViewForPhotoView:(TTPhotoView *)photoView withImageElement:(ImageElement *)imageElement;

- (id)initWithImageElement:(ImageElement *)imageElement andFrameSize:(CGSize)frameSize;

- (BOOL)isLowResolution;

@end
