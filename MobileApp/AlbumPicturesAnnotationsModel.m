//
//  AlbumPicturesAnnotationModel.m
//  MobileApp
//
//  Created by Dev on 7/20/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "AlbumPicturesAnnotationsModel.h"
#import "AlbumAnnotationsModel.h"
#import "DDXML.h"
#import "UserModel.h"


@implementation AlbumPicturesAnnotationsModel
@synthesize annotations = _annotations, photoId = _photoId, delegate = _delegateOverride, request = _request;

/*
+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"id", @"photoId",
			nil];
}

+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"annotations", @"annotations",
			nil];
}
*/

- (PictureAnnotationModel *)annotationForCurrentUser
{
	NSNumber *userId = [NSNumber numberWithDouble:[[[UserModel userModel] sybaseId] doubleValue]];

	for ( PictureAnnotationModel *photoLike in _annotations )
	{
		if ( [photoLike.annotatorId isEqualToNumber:userId] )
		{
			return photoLike;
		}
	}
	return nil;
}

- (void)toggleLike
{
	if ( [AlbumAnnotationsModel userLikesPhoto:self.photoId] )
	{
		[self unlikePhoto];
	}
	else
	{
		[self likePhoto];
	}
}

- (void)likePhoto
{
	DDXMLElement *root = [DDXMLElement elementWithName:@"Picture"];
	[root addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://namespace.kodakgallery.com/site/20080402/Picture"]];

	NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kServicePhotoLike, self.photoId]];

	self.request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
	[_request setMethod:RKRequestMethodPOST];


	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"text/xml" forKey:@"Content-Type"];
	[_request setAdditionalHTTPHeaders:headers];

	NSData *data = [[root XMLString] dataUsingEncoding:NSUTF8StringEncoding];
	[_request.URLRequest setHTTPBody:data];

	[_request setUserData:@"likePhoto"];

	[_request send];

	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Like Photo"];
};


- (void)unlikePhoto
{

	PictureAnnotationModel *annotation = [self annotationForCurrentUser];

	if ( annotation == nil )
	{
		return;
	}

    NSString *url = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kServicePhotoAnnotation, annotation.annotationId]];

	self.request = [RKRequest requestWithURL:[NSURL URLWithString:url] delegate:self];
	[_request setMethod:RKRequestMethodDELETE];

	[_request setUserData:@"unlikePhoto"];

	[_request send];

	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Unlike Photo"];
};

- (void)processLikeResponse:(RKResponse *)response
{

	if ( [response isOK] )
	{
		NSError *error = nil;
		NSData *data = [response body];

		DDXMLElement *root = [[[[DDXMLDocument alloc] initWithData:data options:0 error:&error] autorelease] rootElement];
		DDXMLElement *annotationIdDom = [[root elementsForName:@"id"] objectAtIndex:0];
		NSNumber *annotationId = [NSNumber numberWithDouble:[[annotationIdDom stringValue] doubleValue]];

		if ( [annotationId compare:[NSNumber numberWithInt:0]] > 0 )
		{

			// Like succeeded - we must add this like to the list of existing annotations for the photo
			PictureAnnotationModel *picAnnotation = [[[PictureAnnotationModel alloc] init] autorelease];

			picAnnotation.annotatorId = [NSNumber numberWithDouble:[[[UserModel userModel] sybaseId] doubleValue]];
			picAnnotation.annotatorName = [[UserModel userModel] firstName];
			picAnnotation.annotationId = annotationId;
			[picAnnotation setTimeStampWithDate:[NSDate date]];

			self.annotations = [[self annotations] arrayByAddingObject:picAnnotation];

			if ( self.delegate && [self.delegate respondsToSelector:@selector(didLikeSucceed:)] )
			{
				[self.delegate didLikeSucceed:self];
				return;
			}

			self.request = nil;
		}
	}
}

- (void)processUnlikeResponse:(RKResponse *)response
{

	if ( [response isOK] )
	{

		PictureAnnotationModel *usersAnnotation = [self annotationForCurrentUser];

		if ( usersAnnotation != nil )
		{

			// Remove this like
			NSMutableArray *mAnnotations = [NSMutableArray arrayWithArray:_annotations];
			[mAnnotations removeObject:usersAnnotation];

			/*
			NSUInteger idx = [mAnnotations indexOfObjectPassingTest:
							  ^ BOOL (PictureAnnotationModel* annotation, NSUInteger idx, BOOL *stop)
							  {
								  return [annotation.annotationId isEqualToNumber:[usersAnnotation annotationId]];
							  }];
			*/

			self.annotations = [NSMutableArray arrayWithArray:mAnnotations];

			if ( [self.delegate respondsToSelector:@selector(didUnLikeSucceed:)] )
			{
				[self.delegate didUnLikeSucceed:self];
				return;
			}

			self.request = nil;
		}
	}
}


- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	if ( [[request userData] isEqualToString:@"likePhoto"] )
	{
		[self processLikeResponse:response];
	}
	else if ( [[request userData] isEqualToString:@"unlikePhoto"] )
	{
		[self processUnlikeResponse:response];
	}
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
	if ( [[request userData] isEqualToString:@"likePhoto"] )
	{
		if ( [self.delegate respondsToSelector:@selector(didLikeFail:error:)] )
		{
			[self.delegate didLikeFail:self error:error];
		}
	}
	else if ( [[request userData] isEqualToString:@"unlikePhoto"] )
	{
		if ( [self.delegate respondsToSelector:@selector(didUnLikeFail:error:)] )
		{
			[self.delegate didUnLikeFail:self error:error];
		}
	}
}

- (void)dealloc
{
	self.delegate = nil;

	if ( self.request )
	{
		self.request.delegate = nil;
		self.request = nil;
	}

	[_annotations release];
	[_photoId release];

	[super dealloc];
}


@end
