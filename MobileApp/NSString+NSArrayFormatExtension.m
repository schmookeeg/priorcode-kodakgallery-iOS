//
//  NSString+NSArrayFormatExtension.m
//  MobileApp
//
//  Created by Darron Schall on 9/16/11.
//

#import "NSString+NSArrayFormatExtension.h"

@implementation NSString (NSArrayFormatExtension)

+ (id)stringWithFormat:(NSString *)format array:(NSArray *)arguments;
{
	char *argList = (char *) malloc( sizeof(NSString *) * [arguments count] );
	[arguments getObjects:(id *) argList];
	NSString *result = [[[NSString alloc] initWithFormat:format arguments:argList] autorelease];
	free( argList );
	return result;
}

@end