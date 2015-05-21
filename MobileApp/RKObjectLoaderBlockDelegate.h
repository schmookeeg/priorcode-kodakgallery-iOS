//
//  RKObjectLoaderBlockDelegate.h
//  MobileApp
//
//  Created by Darron Schall on 9/21/11.
//
//

// From https://github.com/RestKit/RestKit/issues/316

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

typedef void (^DidFailWithErrorBlock)( RKObjectLoader *objectLoader, NSError *error );

typedef void (^DidLoadObjectsBlock)( RKObjectLoader *objectLoader, NSArray *objects );

typedef void (^DidLoadUnexpectedResponseBlock)( RKObjectLoader *objectLoader );

@interface RKObjectLoaderBlockDelegate : NSObject <RKObjectLoaderDelegate>
{
	DidFailWithErrorBlock didFailWithErrorCallback;
	DidLoadObjectsBlock didLoadObjectsCallback;
	DidLoadUnexpectedResponseBlock didLoadUnexpectedResponseCallback;
}

- (id)initWithOnFail:(DidFailWithErrorBlock)onFail
	andOnLoadObjects:(DidLoadObjectsBlock)onLoad
 andOnLoadUnexpected:(DidLoadUnexpectedResponseBlock)onUnexpected;

- (void)dealloc;

+ (RKObjectLoaderBlockDelegate *)blockDelegateWithOnFail:(DidFailWithErrorBlock)onFail
										andOnLoadObjects:(DidLoadObjectsBlock)onLoad
									 andOnLoadUnexpected:(DidLoadUnexpectedResponseBlock)onUnexpected;

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error;

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects;

- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader;

@end
