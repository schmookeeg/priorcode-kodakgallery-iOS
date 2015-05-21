//
//  LocationServicesDisabledViewController.h
//  MobileApp
//
//  Created by mikeb on 9/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationServicesDisabledDelegate
- (void)didTouchLocationServicesDisabledWarningExit:(id)sender;
@end

@interface LocationServicesDisabledViewController : UIViewController
{

	UIButton *continueButton;
}
@property ( nonatomic, retain ) IBOutlet UIButton *continueButton;

- (IBAction)didTouchContinue:(id)sender;

@property ( nonatomic, assign ) id <LocationServicesDisabledDelegate> delegate;


@end
