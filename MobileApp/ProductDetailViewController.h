//
//  ProductDetailViewController.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "JSON.h"
#import "RootViewController.h"
#import "CanvasRenderer.h"
#import "SPMProject.h"
#import "EditImageElementViewController.h"
#import "EditTextElementViewController.h"
#import "SelectPhotosViewControllerDelegate.h"
#import <RestKit/RestKit.h>
#import "MBProgressHUD.h"
#import "GradientButton.h"
#import "CMPopTipView.h"
#import "EventInterceptWindow.h"
#import "TTTAttributedLabel.h"
#import "SPMProductListDataSource.h"

@interface ProductDetailViewController : RootViewController <EditImageElementViewControllerDelegate, EditTextElementViewControllerDelegate, SelectPhotosViewControllerDelegate, RKRequestDelegate, MBProgressHUDDelegate, CMPopTipViewDelegate, EventInterceptWindowDelegate>
{
	IBOutlet LowResolutionBar *lowResolutionBar;
	IBOutlet CanvasRenderer *canvasRenderer;
	IBOutlet TTTAttributedLabel *priceLabel;

	MBProgressHUD *_hud;
}

@property ( nonatomic, retain ) SPMProject *project;
@property ( nonatomic, readonly ) MBProgressHUD *hud;
@property ( nonatomic, retain ) CMPopTipView *photoHoleTipView;

/**
 * We need the data source to change the photo for all of the products when the user
 * goes through the change photo workflow.  We also need the data source to support
 * left/right swipes on this screen to navigate between products.
 */
@property ( nonatomic, retain ) SPMProductListDataSource *dataSource;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query;

- (IBAction)changePhotoAction:(id)sender;

@end
