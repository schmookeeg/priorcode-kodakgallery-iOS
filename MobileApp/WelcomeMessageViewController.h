//
//  WelcomeMessageViewController.h
//  MobileApp
//
//  Created by mikeb on 9/14/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "GradientButton.h"

@interface WelcomeMessageViewController : UIViewController <UIWebViewDelegate>
{
	IBOutlet UIWebView *welcomeWebView;
	IBOutlet UIButton *goButton;
	NSString *url;
	NSString *goActionUrl;
	NSURL *incomingUrl;
	NSString *ownerName;
	NSString *albumTitle;
}
@property ( nonatomic, retain ) NSString *url;
@property ( nonatomic, retain ) NSString *goActionUrl;
@property ( nonatomic, retain ) NSURL *incomingUrl;
@property ( nonatomic, retain ) NSString *ownerName;
@property ( nonatomic, retain ) NSString *albumTitle;

- (id)initWithIncomingUrl:(NSURL *)incomingUrl;

- (id)initWithUrl:(NSString *)welcomeUrl actionUrl:(NSString *)actionURL;

- (IBAction)goButtonTouched:(id)sender;

@end

