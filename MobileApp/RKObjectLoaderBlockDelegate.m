//
//  RKObjectLoaderBlockDelegate.m
//  MobileApp
//
//  Created by Darron Schall on 9/21/11.
//

// From https://github.com/RestKit/RestKit/issues/316

#import "RKObjectLoaderBlockDelegate.h"

@implementation RKObjectLoaderBlockDelegate

- (id)initWithOnFail:(DidFailWithErrorBlock)onFail
	andOnLoadObjects:(DidLoadObjectsBlock)onLoad
 andOnLoadUnexpected:(DidLoadUnexpectedResponseBlock)onUnexpected;
{
	self = [super init];
	if ( self )
	{
		if ( onFail )
		{
			didFailWithErrorCallback = Block_copy(onFail);
		}
		if ( onLoad )
		{
			didLoadObjectsCallback = Block_copy(onLoad);
		}
		if ( onUnexpected )
		{
			didLoadUnexpectedResponseCallback = Block_copy(onUnexpected);
		}
	}

	return self;
}

- (void)dealloc
{
	if ( didFailWithErrorCallback )
	{
		Block_release(didFailWithErrorCallback);
	}
	if ( didLoadObjectsCallback )
	{
		Block_release(didLoadObjectsCallback);
	}
	if ( didLoadUnexpectedResponseCallback )
	{
		Block_release(didLoadUnexpectedResponseCallback);
	}
	[super dealloc];
}

+ (RKObjectLoaderBlockDelegate *)blockDelegateWithOnFail:(DidFailWithErrorBlock)onFail
										andOnLoadObjects:(DidLoadObjectsBlock)onLoad
									 andOnLoadUnexpected:(DidLoadUnexpectedResponseBlock)onUnexpected
{
	return (RKObjectLoaderBlockDelegate *) [[[RKObjectLoaderBlockDelegate alloc] initWithOnFail:onFail andOnLoadObjects:onLoad andOnLoadUnexpected:onUnexpected] autorelease];
}


- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
	if ( didFailWithErrorCallback )
	{
		didFailWithErrorCallback( objectLoader, error );
	}
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
	if ( didLoadObjectsCallback )
	{
		didLoadObjectsCallback( objectLoader, objects );
	}
}

- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader
{
	if ( didLoadUnexpectedResponseCallback )
	{
		didLoadUnexpectedResponseCallback( objectLoader );
	}
}

@end
