//
//  UIViewController+TDSemiModalExtension.m
//  TDSemiModal
//
//  Created by Nathan Reed on 18/10/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+TDSemiModalExtension.h"

@implementation UIViewController (TDSemiModalExtension)

// Use this to show the modal view (pops-up from the bottom)
- (void) presentSemiModalViewController:(TDSemiModalViewController*)vc {
    [self presentSemiModalViewController:vc withDuration:0.6f];
}

// Use this to show the modal view with custom duration (pops-up from the bottom)
- (void) presentSemiModalViewController:(TDSemiModalViewController*)vc withDuration:(CGFloat)duration {
	// Retain the view controller because we need it all the way through the end
    // of the dismiss animation
    [vc retain];

    UIView *modalView = vc.view;
	UIView *coverView = vc.coverView;

    // If we just add as a subview of the current view, then the semi-modal view
    // does not appear over top of a possilbe navigation bar.  Instead, we need to
    // get the window and add the modal view on top of that.
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
	CGPoint center = window.center;
    
    CGSize offSize = [UIScreen mainScreen].bounds.size;
	CGPoint offScreenCenter = CGPointZero;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

	if (UIInterfaceOrientationIsLandscape(orientation)) {
		offScreenCenter = CGPointMake(offSize.height / 2.0, offSize.width * 1.2);
		center = CGPointMake(center.y, center.x);
		[modalView setBounds:CGRectMake(0, 0, 480, 320)];
	} else {
		offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.2);
		[modalView setBounds:CGRectMake(0, 0, 320, 480)];
		[coverView setFrame:CGRectMake(0, 0, 320, 480)];
	}
	
	// we start off-screen
	modalView.center = offScreenCenter;
	coverView.alpha = 0.0f;
    
    // Add to the window for "true" modality.
    [window addSubview:coverView];
    [window addSubview:modalView];
	
	// Show it with a transition effect
    [UIView animateWithDuration:duration animations:^(void) {
        modalView.center = center;
        coverView.alpha = 0.5;
    }];
}

// Use this to slide the semi-modal view back down with custom duration
-(void) dismissSemiModalViewController:(TDSemiModalViewController*)vc {
    [self dismissSemiModalViewController:vc withDuration:0.7f];
}

// Use this to slide the semi-modal view back down.
-(void) dismissSemiModalViewController:(TDSemiModalViewController*)vc withDuration:(CGFloat)duration {
	UIView *modalView = vc.view;
	UIView *coverView = vc.coverView;

	CGSize screen = [UIScreen mainScreen].bounds.size;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

	CGPoint offScreenCenter = UIInterfaceOrientationIsLandscape(orientation) ? CGPointMake(screen.height / 2.0, screen.width * 1.5) : CGPointMake(screen.width / 2.0, screen.height * 1.5);
    
    [UIView animateWithDuration:duration animations:^(void) {
        modalView.center = offScreenCenter;
        coverView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [modalView removeFromSuperview];
        [coverView removeFromSuperview];
        
        // No longer need the view controllers, so we can release to undo our previous retain.
        [vc release];
    }];
}

@end