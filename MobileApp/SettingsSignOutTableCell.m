//
//  SettingsSignOutTableCell.m
//  MobileApp
//
//  Created by Dev on 9/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "SettingsSignOutTableCell.h"
#import "SettingsSignOutItem.h"

static const CGFloat kInitialXpos = 0;
static const CGFloat kInitialYpos = 0;
static const CGFloat kSignOutButtonAdjustment = 26;
static const CGFloat kLabelWidthAdjustmentValue = 20;
static const CGFloat kSignOutButtonMargin = 10;

@implementation SettingsSignOutTableCell
@synthesize _signInAs, _email, _signOut;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
	if ( self == [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier] )
	{
		_signInAs = [[UILabel alloc] init];
		_email = [[UILabel alloc] init];

		_signOut = [[GradientButton alloc] init];
		// Sign-out button must be sized before calling awakeFromNib on the gradient button as it builds the gradient layer
		// based on the button size.
		[_signOut setFrame:CGRectMake( kSignOutButtonMargin, 45, ( self.frame.size.width - kSignOutButtonMargin * 4 ), 35 )];
		[_signOut awakeFromNib];


		[self.contentView addSubview:_signInAs];
		[self.contentView addSubview:_email];
		[self.contentView addSubview:_signOut];

		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		[self setAccessoryType:UITableViewCellAccessoryNone];
	}
	return self;
}


- (void)dealloc
{
	TT_RELEASE_SAFELY(_signInAs)
	TT_RELEASE_SAFELY(_email)
	TT_RELEASE_SAFELY(_signOut)

	[super dealloc];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self.detailTextLabel sizeToFit];

	//Sign In As Label
	_signInAs.frame = CGRectMake( kInitialXpos, kInitialYpos, ( self.frame.size.width - kLabelWidthAdjustmentValue ), self.frame.size.height / 4.0 );
	[_signInAs setFont:[UIFont systemFontOfSize:14]];
	[_signInAs setTextAlignment:UITextAlignmentCenter];
	[_signInAs setBackgroundColor:[UIColor clearColor]];

	//Email Label
	_email.frame = CGRectMake( kInitialXpos, ( self.frame.size.height / 4.0 - kSignOutButtonAdjustment / 5 ), ( self.frame.size.width - kLabelWidthAdjustmentValue ), self.frame.size.height / 4.0 );
	[_email setFont:[UIFont boldSystemFontOfSize:14]];
	[_email setTextAlignment:UITextAlignmentCenter];
	[_email setBackgroundColor:[UIColor clearColor]];

	//SignOut Button
	//_signout was positioned in the initWithStyle method
	[_signOut.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
	//[_signOut setBackgroundColor:[UIColor redColor]];
	[_signOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	UIColor *highColor = [UIColor colorWithRed:238.0 / 255.0 green:117.0 / 255.0 blue:126.0 / 255.0 alpha:1.0];
	UIColor *lowColor = [UIColor colorWithRed:236.0 / 255.0 green:17.0 / 255.0 blue:15.0 / 255.0 alpha:1.0];
	[_signOut setHighColor:highColor];
	[_signOut setLowColor:lowColor];
}

- (id)object
{
	return self;
}

- (void)setObject:(id)object
{
	[super setObject:object];
	SettingsSignOutItem *item = object;
	[_signInAs setText:item._signin];
	[_email setText:item._emailid];
	[_signOut setTitle:item._buttonTitle forState:UIControlStateNormal];
	[_signOut addTarget:item.buttonDelegate action:item.buttonAction forControlEvents:UIControlEventTouchUpInside];
}

@end
