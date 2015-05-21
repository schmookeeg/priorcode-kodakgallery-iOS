//
//  Created by darron on 3/6/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "LowResolutionBar.h"
#import <QuartzCore/QuartzCore.h>

@interface LowResolutionBar ()

- (void)doInit;

- (void)applyBackgroundGradient;

@end

@implementation LowResolutionBar

#pragma mark init / dealloc

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        [self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self doInit];
    }
    return self;
}

- (void)doInit
{
    self.backgroundColor = [UIColor blackColor];
    [self applyBackgroundGradient];

	_lowResolutionWarningLabel = [[UILabel alloc] init];
	_lowResolutionWarningLabel.font = [UIFont boldSystemFontOfSize:12];
	_lowResolutionWarningLabel.text = @"Low Resolution";
	_lowResolutionWarningLabel.backgroundColor = [UIColor clearColor];
	_lowResolutionWarningLabel.textColor = [UIColor blackColor];
	[self addSubview:_lowResolutionWarningLabel];

	_lowResolutionWarningSubtextLabel = [[UILabel alloc] init];
	_lowResolutionWarningSubtextLabel.font = [UIFont systemFontOfSize:12];
	_lowResolutionWarningSubtextLabel.text = @"Image may be blurred when printed.";
	_lowResolutionWarningSubtextLabel.backgroundColor = [UIColor clearColor];
	_lowResolutionWarningSubtextLabel.textColor = [UIColor blackColor];
	[self addSubview:_lowResolutionWarningSubtextLabel];

	_lowResolutionIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
	[self addSubview:_lowResolutionIcon];

	[self setNeedsLayout];
}

- (void)dealloc
{
    [_lowResolutionWarningLabel release];
	[_lowResolutionWarningSubtextLabel release];
	[_lowResolutionIcon release];

    [super dealloc];
}

#pragma mark -

- (void)applyBackgroundGradient
{
	// Initialize the gradient layer
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];

	gradientLayer.bounds = self.bounds;
	gradientLayer.position = CGPointMake( CGRectGetMidX( self.bounds ), CGRectGetMidY( self.bounds ) );


	UIColor *highColor = [UIColor colorWithRed:0xf8/255.0 green:0xeb/255.0 blue:0x7b/255.0 alpha:1];
	UIColor *lowColor = [UIColor colorWithRed:0xfb/255.0 green:0xd2/255.0 blue:0x5c/255.0 alpha:1];
	gradientLayer.colors = [NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil];

	[self.layer insertSublayer:gradientLayer atIndex:0];

	[gradientLayer release];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

	// Icon on the left, vertically centered.
	CGRect iconFrame = _lowResolutionIcon.frame;
	iconFrame.origin.x = 8;
	iconFrame.origin.y = ( self.frame.size.height - iconFrame.size.height ) / 2; // vertical align middle
	_lowResolutionIcon.frame = iconFrame;

	[_lowResolutionWarningLabel sizeToFit];
	CGRect warningTitleFrame = _lowResolutionWarningLabel.frame;
	warningTitleFrame.origin.x = iconFrame.origin.x + iconFrame.size.width + 6.0;
	warningTitleFrame.origin.y = 3.0;
	_lowResolutionWarningLabel.frame = warningTitleFrame;

	[_lowResolutionWarningSubtextLabel sizeToFit];
	CGRect warningSubtitleFrame = _lowResolutionWarningSubtextLabel.frame;
	warningSubtitleFrame.origin.x = warningTitleFrame.origin.x;
	warningSubtitleFrame.origin.y = warningTitleFrame.origin.y + warningTitleFrame.size.height + 2.0;
	_lowResolutionWarningSubtextLabel.frame = warningSubtitleFrame;
}

@end