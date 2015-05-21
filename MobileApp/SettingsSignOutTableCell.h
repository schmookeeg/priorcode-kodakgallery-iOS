//
//  SettingsSignOutTableCell.h
//  MobileApp
//
//  Created by P. Traeg on 9/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Three20UI/TTTableCaptionItemCell.h"
#import "Three20UI/TTButton.h"
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "GradientButton.h"

@interface SettingsSignOutTableCell : TTTableCaptionItemCell
{
	UILabel *_signInAs;
	UILabel *_email;
	GradientButton *_signOut;
}
@property ( nonatomic, readonly ) UILabel *_signInAs;
@property ( nonatomic, readonly ) UILabel *_email;
@property ( nonatomic, assign ) GradientButton *_signOut;


@end
