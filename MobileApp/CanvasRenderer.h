//
//  CanvasRenderer.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointTranslator.h"
#import "Page.h"

@interface CanvasRenderer : UIView
{
	CGSize pageAreaInPixels; // The width/height of the page area in pixels
							 // (this will likely be smaller than the frame to
							 // preserve the aspect ratio of the page within
							 // the canvas' frame).

	PointTranslator *_pointTranslator;
}

@property ( nonatomic, retain ) Page *page;

@end
