//
//  EmptyAlbumsView.m
//  MobileApp
//
//  Created by Darron Schall on 8/23/11.
//

#import "EmptyAlbumsView.h"
#import <QuartzCore/QuartzCore.h>

@interface EmptyAlbumsView ()

- (void)roundCallToActionLabelCorners;

@end

@implementation EmptyAlbumsView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		[self roundCallToActionLabelCorners];
	}
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	[self roundCallToActionLabelCorners];
}

- (void)roundCallToActionLabelCorners
{
	// Draw rounded corners
	callToActionLabel.layer.cornerRadius = 10;
	callToActionLabel.clipsToBounds = YES;
}

- (void)dealloc
{
	[callToActionLabel release];

	[super dealloc];
}

@end
