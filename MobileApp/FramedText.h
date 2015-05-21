//
//  FramedText.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextElement.h"
#import <QuartzCore/QuartzCore.h>

@interface FramedText : UIView
{
	CATextLayer *_textLayer;
}

@property ( nonatomic, retain ) TextElement *textElement;

@end
