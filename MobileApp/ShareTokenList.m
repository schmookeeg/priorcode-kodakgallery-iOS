//
//  ShareTokenList.m
//  MobileApp
//
//  Created by Dev on 8/17/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "ShareTokenList.h"

static NSMutableDictionary *_tokenDict;


@implementation ShareTokenList

+ (NSString *)shareTokenFilePath
{
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,
			NSUserDomainMask, YES );
	NSString *appDocumentPath = [documentPaths objectAtIndex:0];
	return [NSString stringWithFormat:@"%@/shareTokensDict", appDocumentPath];
}

+ (NSString *)tokenForAlbumId:(NSNumber *)albumId;
{
	NSMutableDictionary *dict = [ShareTokenList tokenList];
	NSString *albumIdKey = [albumId stringValue];
	return [dict objectForKey:albumIdKey];
}

+ (NSMutableDictionary *)tokenList
{
	if ( !_tokenDict )
	{
		_tokenDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[ShareTokenList shareTokenFilePath]];
		if ( !_tokenDict )
		{
			_tokenDict = [[NSMutableDictionary alloc] init];
			[_tokenDict writeToFile:[ShareTokenList shareTokenFilePath] atomically:YES];
		}
		[_tokenDict retain];
	}
	NSLog( @"tokenDict: %@", _tokenDict );
	return _tokenDict;
}

+ (void)addToken:(NSString *)token forAlbumId:(NSNumber *)albumId
{
	NSMutableDictionary *dict = [ShareTokenList tokenList];
	NSString *albumIdKey = [albumId stringValue];

	if ( [dict objectForKey:albumIdKey] == nil )
	{
		// Keys for NSMutableDictionary must be NSString values or they can't be persisted via writeToFile
		[dict setObject:token forKey:albumIdKey];
		[dict writeToFile:[ShareTokenList shareTokenFilePath] atomically:YES];
	}
}

+ (void)clear
{
	[_tokenDict removeAllObjects];
	[_tokenDict writeToFile:[ShareTokenList shareTokenFilePath] atomically:YES];

}


@end
