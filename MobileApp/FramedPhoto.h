//
//  FramedPhoto.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageElement.h"
#import <Three20/Three20.h>

@interface FramedPhoto : UIView <TTImageViewDelegate>
{
	TTPhotoView *_imageElementView;

	// Store the tint type that is applied so we don't try to tint
	// multiple times for the same time.
	ImageElementTintType tintTypeApplied;
}

@property ( nonatomic, retain ) ImageElement *imageElement;

@end
