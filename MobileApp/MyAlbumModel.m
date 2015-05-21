//
//  MyAlbumModel.m
//  MobileApp
//
//  Created by Jon Campbell on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyAlbumModel.h"
#import "UserModel.h"

@implementation MyAlbumModel

+ (NSString *)menuTitle
{
	return @"My Albums";
}

+ (NSString *)menuIcon
{
	return kAssetMyAlbumsIcon;
}

- (id)initWithAlbum:(AbstractAlbumModel *)album
{
	self = [super initWithAlbum:album];
	self.type = [NSNumber numberWithInt:kMyAlbumType];

	return self;
}

- (id)init
{
	self = [super init];
	if ( self )
	{
		self.type = [NSNumber numberWithInt:kMyAlbumType];
	}

	return self;
}

- (int)enabledOptions
{
	return kAlbumTypeEnabledOptionsMyAlbum;
}


- (NSString *)url {
    if ( ![[UserModel userModel] loggedIn] && _shareToken )
	{
		NSString *url = kServiceAnonymousAlbum;
		return [NSString stringWithFormat:url, _shareToken];
	}
	else
	{
		NSString *url = kServiceMyAlbum;
		return [NSString stringWithFormat:url, _albumId];
	}
}

- (void)create
{

	/*  '<Group xmlns="http://namespace.kodakgallery.com/site/20100511/Group"><name>{name}</name><description>{description}</description><userEditedDate>{date}</userEditedDate><groupAlbumType>{groupAlbumType}</groupAlbumType></Group>'
*/

	DDXMLElement *root = [DDXMLElement elementWithName:@"Album"];
	[root addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://namespace.kodakgallery.com/site/20080402/Picture"]];

	[root addChild:[DDXMLNode elementWithName:@"id" stringValue:@"0"]];
	[root addChild:[DDXMLNode elementWithName:@"name" stringValue:self.name]];
	[root addChild:[DDXMLNode elementWithName:@"ownerid" stringValue:[[UserModel userModel] sybaseId]]];
	[root addChild:[DDXMLNode elementWithName:@"hidden" stringValue:@"0"]];
	[root addChild:[DDXMLNode elementWithName:@"type" stringValue:@"0"]];

	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS"];
	NSString *formattedDate = [dateFormatter stringFromDate:self.userEditedDate];
	[root addChild:[DDXMLNode elementWithName:@"userEditedDate" stringValue:formattedDate]];

	[root addChild:[DDXMLNode elementWithName:@"description" stringValue:self.albumDescription]];


	NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kServiceCreateMyAlbum];

	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
	[request setMethod:RKRequestMethodPOST];


	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"text/xml" forKey:@"Content-Type"];

	[request setAdditionalHTTPHeaders:headers];

	NSData *data = [[root XMLString] dataUsingEncoding:NSUTF8StringEncoding];

	[request.URLRequest setHTTPBody:data];

	createRequest = YES;

	[request setUserData:@"createRequest"];

	[request send];

}

- (void)processCreateResponse:(RKResponse *)response
{
	if ( [response isOK] )
	{
		NSError *error = nil;
		NSData *data = [response body];

		DDXMLElement *root = [[[[DDXMLDocument alloc] initWithData:data options:0 error:&error] autorelease] rootElement];

		DDXMLElement *albumIdDom = [[root elementsForName:@"id"] objectAtIndex:0];

		NSNumber *albumId = [NSNumber numberWithDouble:[[albumIdDom stringValue] doubleValue]];

		self.albumId = albumId;

		if ( [self.delegate respondsToSelector:@selector(didCreateSucceed:albumId:)] )
		{
			[self.delegate didCreateSucceed:self albumId:albumId];
		}

	}
	else
	{
		if ( [self.delegate respondsToSelector:@selector(didCreateFail:error:)] )
		{
			[self.delegate didCreateFail:self error:[response failureError]];
		}
	}
}

- (void)createShare
{
	DDXMLElement *root = [DDXMLElement elementWithName:@"ShareEmail"];
	[root addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://namespace.kodakgallery.com/site/20080402/Picture"]];


	[root addChild:[DDXMLNode elementWithName:@"subject" stringValue:@"<![CDATA[Mobile Album Share]]>"]];
	[root addChild:[DDXMLNode elementWithName:@"allowAnon" stringValue:@"true"]];
	[root addChild:[DDXMLNode elementWithName:@"doNotSendEmails" stringValue:@"true"]];

	DDXMLElement *emails = [DDXMLElement elementWithName:@"emails"];
	[emails addChild:[DDXMLNode elementWithName:@"email" stringValue:@"share@kodakgallery.com"]];

	[root addChild:emails];

	DDXMLElement *albums = [DDXMLElement elementWithName:@"albums"];
	[albums addChild:[DDXMLNode elementWithName:@"albumId" stringValue:[self.albumId stringValue]]];

	[root addChild:albums];

	[root addChild:[DDXMLNode elementWithName:@"name" stringValue:[NSString stringWithFormat:@"<![CDATA[%@]]>", [self name]]]];


	NSString *urlString = [NSString stringWithFormat:@"%@/site/rest/v1.0/share/create", kRestKitBaseUrl];

	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
	[request setMethod:RKRequestMethodPOST];


	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"text/xml" forKey:@"Content-Type"];

	[request setAdditionalHTTPHeaders:headers];

	NSData *data = [[root XMLString] dataUsingEncoding:NSUTF8StringEncoding];

	[request.URLRequest setHTTPBody:data];

	[request setUserData:@"albumShareRequest"];

	[request send];
}

- (void)processCreateShareResponse:(RKResponse *)response
{
	if ( [response isOK] )
	{
		NSError *error = nil;
		NSData *data = [response body];

		DDXMLElement *root = [[[[DDXMLDocument alloc] initWithData:data options:0 error:&error] autorelease] rootElement];

		DDXMLElement *shareTokenDom = [[[[root elementsForName:@"result"] objectAtIndex:0] elementsForName:@"shareToken"] objectAtIndex:0];

		NSString *shareToken = [shareTokenDom stringValue];

		self.shareToken = shareToken;

		if ( [self.delegate respondsToSelector:@selector(didCreateShareSucceed:shareToken:)] )
		{
			[self.delegate didCreateShareSucceed:self shareToken:shareToken];
		}

	}
	else
	{
		if ( [self.delegate respondsToSelector:@selector(didCreateShareFail:error:)] )
		{
			[self.delegate didCreateShareFail:self error:[response failureError]];
		}
	}

}
#pragma mark - Edit request and response
- (void)edit {
    
    /*
     <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
     <AlbumMetaData xmlns:ns2="http://namespace.kodakgallery.com/site/2009/Caption" xmlns="http://namespace.kodakgallery.com/site/20080402/Picture">
        <name>ZKAlbum1Edited</name>
        <userEditedDate>2011-12-12T00:00:00.0+05:30</userEditedDate>
        <description>ZKAlbum Desc Edited</description>
     </AlbumMetaData>
     */
    
    DDXMLElement *root = [DDXMLElement elementWithName:@"AlbumMetaData"];
    
	[root addAttribute:[DDXMLNode attributeWithName:@"xmlns:ns2" stringValue:@"http://namespace.kodakgallery.com/site/2009/Caption"]];
	[root addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://namespace.kodakgallery.com/site/20080402/Picture"]];
    
	[root addChild:[DDXMLNode elementWithName:@"name" stringValue:self.name]];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS"];
	NSString *formattedDate = [dateFormatter stringFromDate:self.userEditedDate];
    
    [root addChild:[DDXMLNode elementWithName:@"userEditedDate" stringValue:formattedDate]];
    
    [root addChild:[DDXMLNode elementWithName:@"description" stringValue:self.albumDescription]]; 
    
	NSString *urlString = [NSString stringWithFormat:@"%@/site/rest/v1.0/album/%@/metaData", kRestKitBaseUrl, self.albumId];
    
	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
	[request setMethod:RKRequestMethodPUT];
    
  	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"text/xml" forKey:@"Content-Type"];
    
	[request setAdditionalHTTPHeaders:headers];
    
    NSString *strXml = [root XMLString];
    
    strXml = [@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" stringByAppendingString:strXml];
	NSData *data = [strXml dataUsingEncoding:NSUTF8StringEncoding];
    
	[request.URLRequest setHTTPBody:data];
    
	createRequest = YES;
    
	[request setUserData:@"renameRequest"];
    
	[request send];
}
- (void) processEditResponse:(RKResponse *)response {
 	if ( [response isOK] )
	{
        if ( [self.delegate respondsToSelector:@selector(didEditSucceed:)] )
        {
        	[self.delegate didEditSucceed:self];
        }
    }
    else {
        if ( [self.delegate respondsToSelector:@selector(didEditFail:error:)] )
		{
			[self.delegate didEditFail:self error:[response failureError]];
		}
    }
}

#pragma mark -

- (void)join
{
	// This is essentially an empty operation because albums are migrated via the login.jsp and join.jsp pages.
	if ( [self.delegate respondsToSelector:@selector(didJoinSucceed:)] )
	{
		[self.delegate didJoinSucceed:self];
	}
}


- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	NSString *userData = [request userData];

	if ( [userData isEqualToString:@"deleteRequest"] )
	{
		[self processDeleteResponse:response];
	}
	else if ( [userData isEqualToString:@"redeemAlbumRequest"] )
	{
		[self processJoinResponse:response];
	}
	else if ( [userData isEqualToString:@"albumShareRequest"] )
	{
		[self processCreateShareResponse:response];
	}
    else if( [userData isEqualToString:@"renameRequest"] )
    {
        [self processEditResponse:response];
    }
	else
	{
		[super request:request didLoadResponse:response];
	}
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
	NSString *userData = [request userData];

	if ( [userData isEqualToString:@"redeemAlbumRequest"] )
	{
		if ( [self.delegate respondsToSelector:@selector(didJoinFail:error:)] )
		{
			[self.delegate didJoinFail:self error:error];
		}
	}
	else if ( [userData isEqualToString:@"deleteRequest"] )
	{
		[self.delegate albumDeletionFailWith:error];
	}
    else if ( [[request userData] isEqualToString:@"renameRequest"] )
	{
		if ( [self.delegate respondsToSelector:@selector(didEditFail:error:)] )
		{
			[self.delegate didEditFail:self error:error];
		}
	}
	else
	{
		[super request:request didFailLoadWithError:error];
	}
    
}

- (void)deleteAlbum
{
	[self deleteAlbumUsingUrl:kServiceMyAlbum usingId:self.albumId];
}

@end
