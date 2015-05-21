//
//  AbstractModel.m
//  MobileApp
//
//  Created by Jon Campbell on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <Three20/Three20.h>
#import "AbstractModel.h"

@implementation AbstractModel
@synthesize delegate, populated, populateTime = _populateTime;


- (id)init
{
	self = [super init];
    
	[self setPopulated:false];
    
	return self;
}

- (NSString*)url {
    NSLog(@"url NOOP called");
    return nil;
}

- (void)fetch {
 	RKObjectManager *objectManager = [RKObjectManager sharedManager];
	RKObjectLoader *loader = [objectManager objectLoaderWithResourcePath:self.url delegate:self];
    
	loader.targetObject = self;
    
	[loader send];
    
}

- (void)fetchWithDidLoadObjectsBlock:(DidLoadObjectsBlock)objectsBlock {
    __block RKObjectLoaderBlockDelegate *blockDelegate;
    
	DidLoadObjectsBlock didLoadObjectBlock = ^( RKObjectLoader *objectLoader, NSArray *objects )
	{
        objectsBlock(objectLoader, objects);
        
        dispatch_async( dispatch_get_current_queue(), ^
                       {
                           [blockDelegate release];
                       } );
    };
    
    void (^didFailLoadObjectBlock)( void ) = ^
	{
        
        [AbstractModel uncaughtFailure];
        
        dispatch_async( dispatch_get_current_queue(), ^
                       {
                           [blockDelegate release];
                       } );
    };
    
    blockDelegate = [[RKObjectLoaderBlockDelegate alloc] initWithOnFail:^( RKObjectLoader *objectLoader, NSError *error )
                {
                    didFailLoadObjectBlock();
                }
												  andOnLoadObjects:didLoadObjectBlock
											   andOnLoadUnexpected:^( RKObjectLoader *objectLoader )
                {
                    didFailLoadObjectBlock();
                }];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
	RKObjectLoader *loader = [objectManager objectLoaderWithResourcePath:self.url delegate:blockDelegate];
    
    loader.method = RKRequestMethodGET;
    
	loader.targetObject = self;
	[loader send];        
}

/*-(void)fetchRequestFinished:(RKResponse *)response
 {
 if ([delegate respondsToSelector:@selector(didModelLoad:)] ) {
 [delegate didModelLoad:self];
 } 
 }*/

- (void)fetchRequestFailed:(RKResponse *)response
{
	populated = false;
	self.populateTime = nil;
	if ( [self.delegate respondsToSelector:@selector(didModelLoadFail:withError:)] )
	{
		[self.delegate didModelLoadFail:self withError:[response failureError]];
	}
	else
	{
		[AbstractModel uncaughtFailure];
	}
    
    
}

#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
	populated = true;
	self.populateTime = [NSDate date];
    
	if ( [self.delegate respondsToSelector:@selector(didModelLoad:)] )
	{
		[self.delegate didModelLoad:self];
	}
    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
	populated = false;
	self.populateTime = nil;
    
	NSArray *errors = [[error userInfo] valueForKey:RKObjectMapperErrorObjectsKey];
	ErrorMessage *message = [errors count] > 0 ? [errors objectAtIndex:0] : nil;
    
	if ( [self.delegate respondsToSelector:@selector(didModelLoadFail:withError:)] )
	{
		[self.delegate didModelLoadFail:self withError:error];
	}
	else
	{
		[AbstractModel uncaughtFailureWithErrorMessage:message];
	}
    
}

- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader
{
	populated = false;
	self.populateTime = nil;
	NSError *error;
    
	if ( [[objectLoader response] failureError] )
	{
		error = [[objectLoader response] failureError];
	}
	else
	{
		NSDictionary *details = [NSDictionary dictionaryWithKeysAndObjects:
                                 NSLocalizedDescriptionKey, @"unexpectedResponse",
                                 @"response", [objectLoader response],
                                 @"message", [NSNumber numberWithInteger:[[objectLoader response] statusCode]],
                                 nil];
		error = [NSError errorWithDomain:@"request" code:3 userInfo:details];
	}
    
	if ( [self.delegate respondsToSelector:@selector(didModelLoadFail:withError:)] )
	{
		[self.delegate didModelLoadFail:self withError:error];
	}
	else
	{
		[AbstractModel uncaughtFailure];
	}
    
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    
}

+ (void)uncaughtFailure
{
	[AbstractModel uncaughtFailureWithErrorMessage:nil];
}

+ (void)uncaughtFailureWithErrorMessage:(ErrorMessage *)message
{
	// wait in case network has failed but we don't know yet
	[NSThread sleepForTimeInterval:4];
	if ( [[RKClient sharedClient] isNetworkAvailable] )
	{
		if ( message != nil )
		{
			NSLog( @"Server responded with errorCode:%@, detail:%@", message.errorCode, message.detail );
		}
        
		[[[[UIAlertView alloc] initWithTitle:@"Server Error"
									 message:@"We are having difficulties performing your request. Please try again." delegate:self
						   cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
        
		[[AnalyticsModel sharedAnalyticsModel] trackPageview:[NSString stringWithFormat:@"m:Error:Uncaught:%@", message.errorCode]];
	}
	else
	{
		// The internet is not reachable.
        
		// We don't want to pop any vie controllers because we want to keep
		// the "network unavailable" view on the screen.
	}
    
}

- (void)dealloc
{
	self.populateTime = nil;
	[super dealloc];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// Make sure that we always get "home" after showing the error dialog.
	[[[[TTNavigator navigator] visibleViewController] navigationController] popViewControllerAnimated:NO];
	[[[[TTNavigator navigator] visibleViewController] navigationController] popToRootViewControllerAnimated:YES];
}

@end

