//
//  NSStringUrlEncode.m
//  MobileApp
//
//  Created by Dev on 8/11/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString (URL)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
	return (NSString *) CFURLCreateStringByAddingPercentEscapes( NULL,
			(CFStringRef) self,
			NULL,
			(CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ",
			CFStringConvertNSStringEncodingToEncoding( encoding ) );
}
@end

