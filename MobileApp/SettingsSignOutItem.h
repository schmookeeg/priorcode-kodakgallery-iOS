//
//  SettingsSignOutItem.h
//  MobileApp
//
//  Created by P. Traeg on 9/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20UI/TTTableCaptionItem.h"
#import "Three20Core/TTCorePreprocessorMacros.h"

@interface SettingsSignOutItem : TTTableCaptionItem
{
	NSString *_signin;
	NSString *_emailid;
	NSString *_buttonTitle;
}

@property ( nonatomic, copy ) NSString *_signin;
@property ( nonatomic, copy ) NSString *_emailid;
@property ( nonatomic, copy ) NSString *_buttonTitle;
@property ( nonatomic, assign ) id buttonDelegate;
@property ( nonatomic, assign ) SEL buttonAction;

+ (id)itemWithText:(NSString *)text caption:(NSString *)captionText signin:(NSString *)signInText emailid:(NSString *)emailText buttonTitle:(NSString *)buttonText delegate:(id)delegate selector:(SEL)selector;

@end
