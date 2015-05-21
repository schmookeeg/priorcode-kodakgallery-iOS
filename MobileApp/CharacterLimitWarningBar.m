//
//  Created by darron on 3/19/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CharacterLimitWarningBar.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Colors.h"

@interface CharacterLimitWarningBar ()

- (void)doInit;

- (void)applyBackgroundGradient;

@end

@implementation CharacterLimitWarningBar

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

	_characterLimitWarningLabel = [[UILabel alloc] init];
	_characterLimitWarningLabel.font = [UIFont boldSystemFontOfSize:12];
	_characterLimitWarningLabel.text = @"Character Limit Reached";
	_characterLimitWarningLabel.backgroundColor = [UIColor clearColor];
	_characterLimitWarningLabel.textColor = [UIColor blackColor];
	[self addSubview:_characterLimitWarningLabel];

	_characterLimitWarningSubtextLabel = [[UILabel alloc] init];
	_characterLimitWarningSubtextLabel.font = [UIFont systemFontOfSize:12];
	_characterLimitWarningSubtextLabel.text = @"Please reduce your text use a smaller font size.";
	_characterLimitWarningSubtextLabel.backgroundColor = [UIColor clearColor];
	_characterLimitWarningSubtextLabel.textColor = [UIColor blackColor];
	[self addSubview:_characterLimitWarningSubtextLabel];

	_characterLimitIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
	[self addSubview:_characterLimitIcon];

	[self setNeedsLayout];
}

- (void)dealloc
{
    [_characterLimitWarningLabel release];
	[_characterLimitWarningSubtextLabel release];
	[_characterLimitIcon release];

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
	UIColor *mid1Color = [UIColor colorWithRed:0xf8/255.0 green:0xeb/255.0 blue:0x7b/255.0 alpha:1];
	UIColor *mid2Color = [UIColor colorWithRed:0xfb/255.0 green:0xd2/255.0 blue:0x5c/255.0 alpha:1];
	UIColor *lowColor = [UIColor colorWithRed:0xfb/255.0 green:0xd2/255.0 blue:0x5c/255.0 alpha:1];
	gradientLayer.colors = [NSArray arrayWithObjects:(id)[highColor CGColor], (id)[mid1Color CGColor], (id)[mid2Color CGColor], (id)[lowColor CGColor], nil];

	gradientLayer.locations = [UIColor titleBarGradientLocations];

	[self.layer insertSublayer:gradientLayer atIndex:0];

	[gradientLayer release];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

	// Icon on the left, vertically centered.
	CGRect iconFrame = _characterLimitIcon.frame;
	iconFrame.origin.x = 8;
	iconFrame.origin.y = ( self.frame.size.height - iconFrame.size.height ) / 2; // vertical align middle
	_characterLimitIcon.frame = iconFrame;

	[_characterLimitWarningLabel sizeToFit];
	CGRect warningTitleFrame = _characterLimitWarningLabel.frame;
	warningTitleFrame.origin.x = iconFrame.origin.x + iconFrame.size.width + 6.0;
	warningTitleFrame.origin.y = 3.0;
	_characterLimitWarningLabel.frame = warningTitleFrame;

	[_characterLimitWarningSubtextLabel sizeToFit];
	CGRect warningSubtitleFrame = _characterLimitWarningSubtextLabel.frame;
	warningSubtitleFrame.origin.x = warningTitleFrame.origin.x;
	warningSubtitleFrame.origin.y = warningTitleFrame.origin.y + warningTitleFrame.size.height + 2.0;
	_characterLimitWarningSubtextLabel.frame = warningSubtitleFrame;
}

@end