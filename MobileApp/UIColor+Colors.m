//
//  Created by darron on 12/6/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIColor+Colors.h"


@implementation UIColor (Colors)

+ (NSArray*)titleBarGradientColors
{
	UIColor *highColor = [UIColor colorWithRed:0x5D/255.0 green:0x5D/255.0 blue:0x5D/255.0 alpha:1];
	UIColor *mid1Color = [UIColor colorWithRed:0x20/255.0 green:0x20/255.0 blue:0x20/255.0 alpha:1];
	UIColor *mid2Color = [UIColor colorWithRed:0x0F/255.0 green:0x0F/255.0 blue:0x0F/255.0 alpha:1];
	UIColor *lowColor = [UIColor blackColor];

	return [NSArray arrayWithObjects:(id)[highColor CGColor], (id)[mid1Color CGColor], (id)[mid2Color CGColor], (id)[lowColor CGColor], nil];
}

+ (NSArray*)titleBarGradientLocations
{
	NSNumber *stopOne = [NSNumber numberWithFloat:0.00];
	NSNumber *stopTwo = [NSNumber numberWithFloat:0.50];
	NSNumber *stopThree = [NSNumber numberWithFloat:0.50];
	NSNumber *stopFour = [NSNumber numberWithFloat:1.90];

	return [NSArray arrayWithObjects:stopOne, stopTwo, stopThree, stopFour, nil];
}

+ (NSArray*)blackViewGradientColors
{
    UIColor *highColor = [UIColor blackColor];
	UIColor *lowColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1];
    
	return [NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil];
}

@end