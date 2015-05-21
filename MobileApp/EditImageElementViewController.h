//
//  EditImageElementViewController.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomCropEditView.h"
#import "ImageElement.h"
#import "LowResolutionBar.h"
#import "FramedPhoto.h"

@protocol EditImageElementViewControllerDelegate;

@interface EditImageElementViewController : UIViewController
{
	ZoomCropEditView *zoomCropEditView;
	LowResolutionBar *lowResolutionBar;

	ImageElement *_imageElement;
    
    FramedPhoto *originalFilterDisplay;
	UILabel *originalLabel;

    FramedPhoto *blackWhiteFilterDisplay;
	UILabel *blackWhiteLabel;

    FramedPhoto *sepiaFilterDisplay;
	UILabel *sepiaLabel;
}

@property ( nonatomic, assign ) id <EditImageElementViewControllerDelegate> delegate;

/**
 * Read-only value to get the new resolutionIndependentCrop corresponding to the user's edits.
 */
@property ( nonatomic, readonly ) CGRect resolutionIndependentCrop;

/**
 * Read-only value to get the new tintType corresponding to the user's edits.
 */
@property ( nonatomic, readonly ) ImageElementTintType tintType;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query;


@end


@protocol EditImageElementViewControllerDelegate <NSObject>

@optional

- (void)imageElementEditor:(EditImageElementViewController *)editor didFinishEditing:(ImageElement *)imageElement;

- (void)imageElementEditorDidCancelEditing:(EditImageElementViewController *)editor;

@end
