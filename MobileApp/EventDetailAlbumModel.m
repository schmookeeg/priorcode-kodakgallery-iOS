//
//  EventDetailAlbumModel.m
//  MobileApp
//
//  Created by Peter Traeg on 9/27/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "EventDetailAlbumModel.h"


@implementation EventDetailAlbumModel
@synthesize albumId, albumName;


- (void)fetchViaURL:(NSString *)eventURL
{
	RKObjectManager *objectManager = [RKObjectManager sharedManager];

	RKObjectLoader *loader = [objectManager objectLoaderWithResourcePath:eventURL delegate:self];

	loader.method = RKRequestMethodGET;
	loader.targetObject = self;
	[loader send];
}

#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
	[super objectLoader:objectLoader didLoadObjects:objects];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
	[super objectLoader:objectLoader didFailWithError:error];
}

- (void)dealloc
{
	self.albumId = nil;
	self.albumName = nil;
	[super dealloc];
}

@end
