//
//  ErrorModel.m
//  MobileApp
//
//  Created by Darron Schall on 8/30/11.

#import "ErrorMessage.h"

@implementation ErrorMessage

@synthesize detail = _detail, errorCode = _errorCode;

- (void)setDetail:(NSString *)detail
{
	[detail retain];
	[_detail release];
	_detail = detail;
}

- (void)setErrorCode:(NSString *)errorCode
{
	[errorCode retain];
	[_errorCode release];
	_errorCode = errorCode;
}

- (void)dealloc
{
	[_detail release];
	[_errorCode release];

	[super dealloc];
}

@end
