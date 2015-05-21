//
//  AbstractModel.h
//  MobileApp
//
//  Created by Jon Campbell on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AbstractModelDelegate.h"
#import "ErrorMessage.h"
#import "RKObjectLoaderBlockDelegate.h"


@interface AbstractModel : NSObject <AbstractModelDelegate, RKObjectLoaderDelegate, UIAlertViewDelegate>
{
	id <AbstractModelDelegate> delegate;
	BOOL populated;
	NSDate *_populateTime;
}

- (void)fetch;
- (void)fetchWithDidLoadObjectsBlock:(DidLoadObjectsBlock)objectsBlock;



- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects;

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error;

+ (void)uncaughtFailure;
+ (void)uncaughtFailureWithErrorMessage:(ErrorMessage *)message;



@property ( nonatomic, assign ) id <AbstractModelDelegate> delegate;
@property ( nonatomic, assign ) BOOL populated;
@property ( nonatomic, retain ) NSDate *populateTime;
@property ( nonatomic, readonly ) NSString* url;


@end
