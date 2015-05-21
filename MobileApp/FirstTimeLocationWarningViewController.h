//
//  FirstTimeLocationWarning.h
//  MobileApp
//
//  Created by mikeb on 9/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FirstTimeLocationWarningDelegate
- (void)didTouchContinue:(id)sender;
@end


@interface FirstTimeLocationWarningViewController : UIViewController
{

	IBOutlet UIButton *continueButton;
}
- (IBAction)didTouchContinueButton:(id)sender;

@property ( nonatomic, assign ) id <FirstTimeLocationWarningDelegate> delegate;

@end
