//
//  ShopViewController.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "SelectPhotosViewControllerDelegate.h"
#import "AnonymousSignInModalAlertView.h"
#import "GradientButton.h"
#import "TTTAttributedLabel.h"

@interface ShopViewController : RootViewController <SelectPhotosViewControllerDelegate>
{
    IBOutlet TTTAttributedLabel *makePrintsLabel;
    IBOutlet TTTAttributedLabel *printsPriceLabel;
    IBOutlet GradientButton *shopPrints;
    
    IBOutlet TTTAttributedLabel *makeMagnetsLabel;
    IBOutlet TTTAttributedLabel *magnetPriceLabel;
    IBOutlet GradientButton *shopPhotoGift;
    
	AnonymousSignInModalAlertView *signInAlertView;
}

@end
