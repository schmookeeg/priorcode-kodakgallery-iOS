//
//  PhotoCommentsListModel.m
//  MobileApp
//
//  Created by Peter Traeg on 6/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "PhotoCommentsListModel.h"
#import "DDXML.h"

@implementation PhotoCommentsListModel
@synthesize photoId = _photoId;
@synthesize comments = _comments;
@synthesize delegate = _delegateOverride;

- (NSString *)url {
    return [NSString stringWithFormat:kServicePhotoComments, self.photoId];
}

- (void)addComment:(NSString *)commentText
{
	DDXMLElement *root = [DDXMLElement elementWithName:@"Comment"];
	[root addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://namespace.kodakgallery.com/site/20080402/Picture"]];

	[root addChild:[DDXMLNode elementWithName:@"id" stringValue:@"0"]];
	[root addChild:[DDXMLNode elementWithName:@"photoId" stringValue:[self photoId]]];
	[root addChild:[DDXMLNode elementWithName:@"visibility" stringValue:@"public"]];
	[root addChild:[DDXMLNode elementWithName:@"text" stringValue:commentText]];

	NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kServicePhotoComment, self.photoId]];

	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
	[request setMethod:RKRequestMethodPOST];


	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"text/xml" forKey:@"Content-Type"];
	[request setAdditionalHTTPHeaders:headers];

	NSData *data = [[root XMLString] dataUsingEncoding:NSUTF8StringEncoding];
	[request.URLRequest setHTTPBody:data];

	[request setUserData:@"addComment"];

	[request send];

}

- (void)fetchWithPhotoId:(NSString *)photoId;
{
	self.photoId = photoId;
	[self fetch];
}

- (void)processAddCommentResponse:(RKResponse *)response
{
	if ( [response isOK] )
	{
		NSError *error = nil;
		NSData *data = [response body];

		DDXMLElement *root = [[[[DDXMLDocument alloc] initWithData:data options:0 error:&error] autorelease] rootElement];
		DDXMLElement *commentIdDom = [[root elementsForName:@"id"] objectAtIndex:0];
		NSNumber *commentId = [NSNumber numberWithDouble:[[commentIdDom stringValue] doubleValue]];

		if ( [commentId compare:[NSNumber numberWithInt:0]] > 0 )
		{
			if ( [self.delegate respondsToSelector:@selector(didAddCommentSucceed:)] )
			{
				[self.delegate didAddCommentSucceed:self];
				return;
			}
		}
	}

	if ( [self.delegate respondsToSelector:@selector(didAddCommentFail:error:)] )
	{
		[self.delegate didAddCommentFail:self error:[response failureError]];
	}

}


- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	if ( [[request userData] isEqualToString:@"addComment"] )
	{
		[self processAddCommentResponse:response];
	}
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
	if ( [[request userData] isEqualToString:@"addComment"] )
	{
		if ( [self.delegate respondsToSelector:@selector(didAddCommentFail:error:)] )
		{
			[self.delegate didAddCommentFail:self error:error];
		}
	}
}

- (void)dealloc
{
	[_photoId release];
	[_comments release];

	[super dealloc];
}


@end
