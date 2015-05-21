//
//  Created by darron on 3/13/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FontInstance.h"
#import "FontStyle.h"

@implementation FontInstance

@synthesize family = _family;
@synthesize style = _style;
@synthesize size = _size;
@synthesize color = _color;

#pragma mark init / dealloc

- (void)dealloc
{
	[_family release];
	[_style release];
	[_size release];
	[_color release];

	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p \
	            family: %@\n \
	            style: %@\n \
			    size: %@\n \
				color: %@\n"
				, NSStringFromClass( [self class] ), (void *) self, self.family, self.style, self.size, self.color];
}

#pragma mark -

+ (NSString *)uiFontFamilyNameFromFamily:(NSString *)family andStyle:(NSString *)style
{
// Below is temp code to figure out the font names from ttf files so we can map
// what we get from the server to what we have in the UI.
//
//	NSArray *familyNames = [UIFont familyNames];
//	for ( NSString *familyName in familyNames )
//	{
//		if ( [familyName hasPrefix:@"Zi"] )
//		{
//			NSLog( @"Family name: %@", familyName );
//			NSLog( @"Font names in family: %@", [UIFont fontNamesForFamilyName:familyName] );
//		}
//	}

	NSString *fontName = nil;

	if ( [family isEqualToString:@"Bodoni"] )
	{
		if ( [style isEqualToString:FontStyleNormal] )
		{
			fontName = @"BodoniStd-Book";
		}
		else if ( [style isEqualToString:FontStyleBold] )
		{
			fontName = @"BodoniStd-Bold";
		}
		else if ( [style isEqualToString:FontStyleItalic] )
		{
			fontName = @"BodoniStd-BookItalic";
		}
		else if ( [style isEqualToString:FontStyleBoldItalic] )
		{
			fontName = @"BodoniStd-BoldItalic";
		}
	}
	else if ( [family isEqualToString:@"Caflisch Script"] )
	{
		if ( [style isEqualToString:FontStyleNormal] )
		{
			fontName = @"CaflischScriptPro-Regular";
		}
		else if ( [style isEqualToString:FontStyleBold] )
		{
			fontName = @"CaflischScriptPro-Bold";
		}
	}
	else if ( [family isEqualToString:@"Copperplate"] )
	{
		if ( [style isEqualToString:FontStyleNormal] )
		{
			fontName = @"CopperplateGothicStd-29BC";
		}
		else if ( [style isEqualToString:FontStyleBold] )
		{
			fontName = @"CopperplateGothicStd-30AB";
		}
	}
	else if ( [family isEqualToString:@"Corky"] )
	{
		if ( [style isEqualToString:FontStyleNormal] )
		{
			fontName = @"Corky";
		}
	}
	else if ( [family isEqualToString:@"Futura"] )
	{
		if ( [style isEqualToString:FontStyleNormal] )
		{
			fontName = @"FuturaStd-Book";
		}
		else if ( [style isEqualToString:FontStyleBold] )
		{
			fontName = @"FuturaStd-Bold";
		}
		else if ( [style isEqualToString:FontStyleItalic] )
		{
			fontName = @"FuturaStd-BookOblique";
		}
		else if ( [style isEqualToString:FontStyleBoldItalic] )
		{
			fontName = @"FuturaStd-BoldOblique";
		}
	}
	else if ( [family isEqualToString:@"Zipty Do"] )
	{
		if ( [style isEqualToString:FontStyleNormal] )
		{
			fontName = @"ZiptyDoStd";
		}
	}

	if ( !fontName )
	{
		NSLog( @"Style \"%@\" not supported for family \"%@\".", style, family );
	}

	return fontName;
}

- (NSString *)uiFontFamilyName
{
	return [FontInstance uiFontFamilyNameFromFamily:_family andStyle:_style];
}



@end