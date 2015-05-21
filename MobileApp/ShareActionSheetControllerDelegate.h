//
//  ShareActionSheetControllerDelegate.h
//  MobileApp
//
//  Created by Jon Campbell on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Implementors of this delegate should be the UIViewController that enables the sharing option.
 */
@protocol ShareActionSheetControllerDelegate <NSObject>

/** The view in which to show the action sheet */
- (UIView *)view;

@optional

/** The navigation controller that we use to grab the view from to display an MBProgressHUD */
- (UINavigationController *)navigationController;

@end
