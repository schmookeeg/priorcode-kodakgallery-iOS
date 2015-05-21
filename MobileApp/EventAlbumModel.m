//
//  EventAlbumModel.m
//  MobileApp
//
//  Created by Jon Campbell on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventAlbumModel.h"
#import "NSString+URL.h"


@implementation EventAlbumModel

- (NSString *)url {
    return [NSString stringWithFormat:kServiceEventAlbumFull, _groupId];
}

+ (NSString *)menuTitle
{
	return @"Event Albums";
}

+ (NSString *)menuIcon
{
	return kAssetGroupAlbumsIcon;
}

- (id)initWithAlbum:(AbstractAlbumModel *)album
{
	self = [super initWithAlbum:album];
	self.type = [NSNumber numberWithInt:kEventAlbumType];

	return self;
}

- (id)init
{
	self = [super init];
	if ( self )
	{
		self.type = [NSNumber numberWithInt:kEventAlbumType];
	}

	return self;
}

- (int)enabledOptions
{
	return kAlbumTypeEnabledOptionsEventAlbum;
}

- (void)create
{

	/*  '<Group xmlns="http://namespace.kodakgallery.com/site/20100511/Group"><name>{name}</name><description>{description}</description><userEditedDate>{date}</userEditedDate><groupAlbumType>{groupAlbumType}</groupAlbumType></Group>'
*/

	DDXMLElement *root = [DDXMLElement elementWithName:@"Group"];
	[root addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://namespace.kodakgallery.com/site/20100511/Group"]];

	[root addChild:[DDXMLNode elementWithName:@"name" stringValue:self.name]];
	[root addChild:[DDXMLNode elementWithName:@"description" stringValue:self.albumDescription]]; // not supported for now

	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS"];
	NSString *formattedDate = [dateFormatter stringFromDate:self.userEditedDate];
	[root addChild:[DDXMLNode elementWithName:@"userEditedDate" stringValue:formattedDate]];

	[root addChild:[DDXMLNode elementWithName:@"groupAlbumType" stringValue:[NSString stringWithFormat:@"%d", kEventAlbumType]]];


	NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kServiceCreateEventAlbum];

	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
	[request setMethod:RKRequestMethodPOST];


	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"text/xml" forKey:@"Content-Type"];
	//   [headers setValue:@"application/json" forKey:@"Accept"];

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

		DDXMLElement *groupIdDom = [[root elementsForName:@"id"] objectAtIndex:0];
		NSNumber *groupId = [NSNumber numberWithDouble:[[groupIdDom stringValue] doubleValue]];
		self.groupId = groupId;

		DDXMLElement *albumDom = [[root elementsForName:@"Album"] objectAtIndex:0];
		DDXMLElement *albumIdDom = [[albumDom elementsForName:@"id"] objectAtIndex:0];
		NSNumber *albumId = [NSNumber numberWithDouble:[[albumIdDom stringValue] doubleValue]];

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
#pragma mark - edit request and response

- (void)edit {
    DDXMLElement *root = [DDXMLElement elementWithName:@"AlbumMetaData"];
    
	[root addAttribute:[DDXMLNode attributeWithName:@"xmlns:ns2" stringValue:@"http://namespace.kodakgallery.com/site/2009/Caption"]];
	[root addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://namespace.kodakgallery.com/site/20080402/Picture"]];
    
    /*
     <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
     <AlbumMetaData xmlns:ns2="http://namespace.kodakgallery.com/site/2009/Caption" xmlns="http://namespace.kodakgallery.com/site/20080402/Picture">
        <name>ZKAlbum1Edited</name>
        <userEditedDate>2011-12-12T00:00:00.0+05:30</userEditedDate>
        <description>ZKAlbum Desc Edited</description>
     </AlbumMetaData>
     */
    
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
	NSString *urlString = [NSString stringWithFormat:@"%@/site/rest/v1.0/group/%@/anonjoin", kRestKitBaseUrl, _groupId];

	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
	[request setMethod:RKRequestMethodPOST];

	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"text/xml" forKey:@"Content-Type"];
	[request setAdditionalHTTPHeaders:headers];

	NSData *data = [[NSString stringWithString:@""] dataUsingEncoding:NSUTF8StringEncoding];
	[request.URLRequest setHTTPBody:data];

	[request setUserData:@"joinGroupRequest"];
	[request send];
}

- (void)createShare
{
	DDXMLElement *root = [DDXMLElement elementWithName:@"Group"];
	[root addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://namespace.kodakgallery.com/site/20100511/Group"]];

	[root addChild:[DDXMLNode elementWithName:@"subject" stringValue:@"<![CDATA[Mobile Album Share]]>"]];
	[root addChild:[DDXMLNode elementWithName:@"allowAnon" stringValue:@"true"]];
	[root addChild:[DDXMLNode elementWithName:@"name" stringValue:[NSString stringWithFormat:@"<![CDATA[%@]]>", [self name]]]];

	DDXMLElement *groupInvites = [DDXMLElement elementWithName:@"GroupInvites"];

	DDXMLElement *groupInvite = [DDXMLElement elementWithName:@"groupInvite"];
	[groupInvite addChild:[DDXMLNode elementWithName:@"email" stringValue:@"share@kodakgallery.com"]];

	[groupInvites addChild:groupInvite];
	[root addChild:groupInvites];

	NSString *urlString = [NSString stringWithFormat:@"%@/site/rest/v1.0/group/%@/inviteListNoEmail", kRestKitBaseUrl, self.groupId];

	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
	[request setMethod:RKRequestMethodPOST];


	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"text/xml" forKey:@"Content-Type"];

	[request setAdditionalHTTPHeaders:headers];

	NSData *data = [[root XMLString] dataUsingEncoding:NSUTF8StringEncoding];

	[request.URLRequest setHTTPBody:data];

	[request setUserData:@"eventShareRequest"];

	[request send];
}

- (void)processCreateShareResponse:(RKResponse *)response
{
	if ( [response isOK] )
	{
		NSError *error = nil;
		NSData *data = [response body];

		DDXMLElement *root = [[[[DDXMLDocument alloc] initWithData:data options:0 error:&error] autorelease] rootElement];

		DDXMLElement *rsvpLinkDom = [[[[[[root elementsForName:@"GroupInvites"] objectAtIndex:0] elementsForName:@"groupInvite"] objectAtIndex:0] elementsForName:@"rsvpLink"] objectAtIndex:0];

		NSString *rsvpLink = (NSString *) [NSString stringWithString:[rsvpLinkDom stringValue]];
		NSString *shareToken = [[rsvpLink componentsSeparatedByString:@"/"] objectAtIndex:6];

		NSString *rsvpLinkEncoded = [rsvpLink urlEncodeUsingEncoding:NSUTF8StringEncoding];

		self.shareToken = [NSString stringWithFormat:@"%@&rsvpLink=%@", shareToken, rsvpLinkEncoded];

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


- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	NSString *userData = [request userData];

	if ( [userData isEqualToString:@"deleteRequest"] )
	{
		[self processDeleteResponse:response];
	}
	else if ( [userData isEqualToString:@"joinGroupRequest"] )
	{
		[self processJoinResponse:response];
	}
	else if ( [userData isEqualToString:@"eventShareRequest"] )
	{
		[self processCreateShareResponse:response];
	}
	else if ( [userData isEqualToString:@"createRequest"] )
	{
		[self processCreateResponse:response];
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

	if ( [userData isEqualToString:@"deleteRequest"] )
	{
		[self.delegate albumDeletionFailWith:error];
	}
	else if ( [userData isEqualToString:@"joinGroupRequest"] )
	{
		if ( [self.delegate respondsToSelector:@selector(didJoinFail:error:)] )
		{
			[self.delegate didJoinFail:self error:error];
		}

	}
	else if ( [[request userData] isEqualToString:@"createRequest"] )
	{
		if ( [self.delegate respondsToSelector:@selector(didCreateFail:error:)] )
		{
			[self.delegate didCreateFail:self error:error];
		}
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
	[self deleteAlbumUsingUrl:kServiceEventAlbum usingId:self.groupId];
}
@end
