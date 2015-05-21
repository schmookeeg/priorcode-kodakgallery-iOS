//
//  EventAlbumModel.m
//  MobileDemo
//
//  Created by Jon Campbell on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "AbstractAlbumModel.h"
#import "EventAlbumModel.h"
#import "MyAlbumModel.h"
#import "FriendsAlbumModel.h"
#import "ISO8601DateFormatter.h"
#import "ShareEmailTemplates.h"
#import "UserModel.h" // Needed for encodeString class method, should refactor this.
//#import <RestKit/Support/XML/LibXML/RKXMLParserLibXML.h>

@implementation AbstractAlbumModel
@synthesize groupId = _groupId, albumId = _albumId, name = _name, albumDescription = _albumDescription, userEditedDate = _userEditedDate, firstPhoto = _firstPhoto, photos = _photos, photoCount = _photoCount, memberCount = _memberCount, groupAlbumType = _groupAlbumType, founder = _founder, members = _members, type = _type, autoShareToken = _autoShareToken, shareToken = _shareToken, isFriends = _isFriends, allowAnon = _allowAnon;
@synthesize delegate = _delegateOverride, permission = _permission;
@synthesize creationDate = _creationDate;

+ (NSString *)menuTitle
{
	return @"All Albums";
}

+ (NSString *)menuIcon
{
	return kAssetAllAlbumsIcon;
}

+ (id)albumClassFromType:(int)albumType
{
	if ( albumType == kEventAlbumType )
	{
		return [EventAlbumModel class];
	}
	else if ( albumType == kMyAlbumType )
	{
		return [MyAlbumModel class];
	}
	else if ( albumType == kFriendAlbumType )
	{
		return [FriendsAlbumModel class];
	}
	return [AbstractAlbumModel class];
}


- (id)initWithAlbum:(AbstractAlbumModel *)album
{
	self = [super init];

	// this are the potential populate properties we might need
	if ( self )
	{
		self.albumId = album.albumId;
		self.groupId = album.groupId;
		self.name = album.name;
		self.albumDescription = album.albumDescription;
		self.userEditedDate = album.userEditedDate;
		[self setTimeUpdatedFromDate:album.timeUpdated];
		[self setTimeCreatedFromDate:album.timeCreated];
		self.photos = album.photos;
		self.photoCount = album.photoCount;
		self.firstPhoto = album.firstPhoto;
		self.memberCount = album.memberCount;
		self.groupAlbumType = album.groupAlbumType;
		self.founder = album.founder;
		self.members = album.members;
		self.shareToken = album.shareToken;
		self.allowAnon = album.allowAnon;
		self.isFriends = album.isFriends;
		self.autoShareToken = album.autoShareToken;
		self.shareToken = album.shareToken;
		self.permission = album.permission;
        self.creationDate = album.creationDate;

		//self.type is taken care of via subclass override.
	}

	return self;
}


- (BOOL)isEventAlbum
{
	return ( [self.type intValue] == kEventAlbumType || [self isKindOfClass:[EventAlbumModel class]] );
}

- (BOOL)isFriendAlbum
{
	return ( [self isFriends] || [self isKindOfClass:[FriendsAlbumModel class]] );
}

- (BOOL)isMyAlbum
{
	return ( ( [self.type intValue] == kMyAlbumType && ![self isFriends] ) || [self isKindOfClass:[MyAlbumModel class]] );
}

- (BOOL)isVideoSlideshowAlbum
{
	return ( [self.type intValue] == kVidSlideshowAlbumType );
}

- (int)enabledOptions
{
	return kAlbumTypeEnabledOptionsAllAlbum;
}

- (void)edit 
{
    NSLog( @"edit NOOP called" );
}

- (void)createShare
{
	NSLog( @"createShare NOOP called" );
}

- (void)join
{
	NSLog( @"join NOOP called" );
}

- (void)fetch {
    [super fetch];
}


- (void)processJoinResponse:(RKResponse *)response
{
	if ( [response isOK] )
	{
		if ( [self.delegate respondsToSelector:@selector(didJoinSucceed:)] )
		{
			[self.delegate didJoinSucceed:self];
		}
	}
	else
	{
		if ( [self.delegate respondsToSelector:@selector(didJoinFail:error:)] )
		{
			// Try to grab the error from RestKit directly
			NSError *failureError = [response failureError];
			if ( !failureError )
			{
				//[response bodyAsString] == <?xml version="1.0" encoding="UTF-8" standalone="yes"?><ErrorList xmlns="http://error.domain.kin.com"><Error><errorCode>OBJECT_NOT_FOUND</errorCode><detail>no such group [12345] could not find entity by: {1}</detail><parameters>no such group [12345]</parameters></Error></ErrorList>

				// Try to parse an error from the response body
//				NSError *error = nil;
//				NSString *data = [response bodyAsString];
//
//				//NSString* MIMEType = RKMIMETypeXML;
//				//NSString *MIMEType = @"text/xml";
//				//id <RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:MIMEType];
//
//				// Becuase we don't link in the library, this line fails to compiler.  RestKit works for us
//                // because we default everything to JSON (the object loader's acceptMimeType defaults to 
//                // RKMIMETypeJSON.  If we want to use RestKit to parse this XML response, we either need to
//                // use the DDXML library "by hand" or link in the library... OR, we can ask the join
//                // call to use JSON instead of XML (but perhaps the service only supports XML?)
//                // id<RKParser> parser = [[[RKXMLParserLibXML alloc] init] autorelease];
//                id<RKParser> parser = nil;
//
//				//Class parserClass = NSClassFromString( @"RKXMLParserLibXML" );
//				//id<RKParser> parser = [[[parserClass alloc] init] autorelease];
//
//				id parsedData = [parser objectFromString:data error:&error];
//                
//                if ( parsedData != nil && error != nil )
//                {
//                    RKObjectManager *sharedManager = [RKObjectManager sharedManager];
//                    RKObjectMappingProvider *mappingProvider = sharedManager.mappingProvider;
//                    RKObjectMapper *mapper = [RKObjectMapper mapperWithObject:parsedData mappingProvider:mappingProvider];
//                    RKObjectMappingResult *result = [mapper performMapping];
//                    if ( result == nil )
//                    {
//                        NSLog( @"Failed due to object mapping errors: %@", mapper.errors );
//                    }
//                    
//                    NSArray *mappedObjects = [result asCollection];
//                    NSLog( @"Mapped: %@", mappedObjects );
//                    
//                    ErrorMessage *errorMessage = nil;
//                    if ( [mappedObjects count] )
//                    {
//                        errorMessage = [mappedObjects objectAtIndex:0];
//                    }
//                    
//                    // TODO: Create failtureError as new NSError, and attach ErrorMessage
//                    // to the userInfo dictionary so that it gets passed through to the delegate
//                    // in the error message
//
//                }
            }
            
			[self.delegate didJoinFail:self error:failureError];
		}
	}
}

- (void)create
{
	NSLog( @"create NOOP called" );
}

- (void)processCreateResponse:(RKResponse *)response
{
	NSLog( @"processCreateResponse NOOP called" );
}

- (void)deleteAlbum
{
	NSLog( @"deleteAlbum NOOP called" );
}

- (void)deleteAlbumUsingUrl:(NSString *)albumUrl usingId:(NSNumber *)albumOrGroupId
{
	NSString *strUrl = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:albumUrl, albumOrGroupId]];
	NSURL *url = [NSURL URLWithString:strUrl];

	if ( url != nil )
	{
		RKRequest *request = [RKRequest requestWithURL:url delegate:self];
		request.backgroundPolicy = RKRequestBackgroundPolicyNone;
		request.method = RKRequestMethodDELETE;
		[request setUserData:@"deleteRequest"];

		[request send];
	}
}

- (void)processDeleteResponse:(RKResponse *)response
{
	if ( [response isOK] )
	{
		[self.delegate albumDeletionSuccessWith:self];
	}
	else
	{
		[self.delegate albumDeletionFailWith:[response failureError]];
	}
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	if ( [[request userData] isEqualToString:@"createRequest"] )
	{
		[self processCreateResponse:response];
	}
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
	if ( [[request userData] isEqualToString:@"createRequest"] )
	{
		if ( [self.delegate respondsToSelector:@selector(didCreateFail:error:)] )
		{
			[self.delegate didCreateFail:self error:error];
		}
	}
}

- (PhotoModel *)photoFromId:(NSNumber *)photoId
{
	for ( PhotoModel *photo in _photos )
	{
		if ( [[photo photoId] isEqual:photoId] )
		{
			return photo;
		}
	}
	return nil;
}

- (NSDate *)timeUpdated;
{
	return _timeUpdated;
}

- (void)setTimeUpdatedFromDate:(NSDate *)date
{

	[_timeUpdated release];
	_timeUpdated = date;
	[_timeUpdated retain];

}

- (void)setTimeUpdated:(NSString *)dateString
{


	[_timeUpdated release];
	_timeUpdated = nil;

	if ( !dateString )
	{
		return;
	}

	ISO8601DateFormatter *dateFormatter = [[[ISO8601DateFormatter alloc] init] autorelease];
	_timeUpdated = [dateFormatter dateFromString:dateString];

	[_timeUpdated retain];
}

- (NSDate *)timeCreated;
{
	return _timeCreated;
}

- (void)setTimeCreatedFromDate:(NSDate *)date
{

	[_timeCreated release];
	_timeCreated = date;
	[_timeCreated retain];

}

- (void)setTimeCreated:(NSString *)dateString;
{
	[_timeCreated release];

	if ( !dateString )
	{
		return;
	}

	ISO8601DateFormatter *dateFormatter = [[[ISO8601DateFormatter alloc] init] autorelease];
	_timeCreated = [dateFormatter dateFromString:dateString];

	[_timeCreated retain];
}

#pragma mark ShareModel

- (NSString *)shareURL
{
	NSString *shareURL = nil;

	NSString *shareToken = [self shareToken];
	NSString *title = [self name];
	[UserModel encodeString:&title];

	if ( [self isEventAlbum] )
	{
        // The share token for groups has the token and rsvp token - we just want the token for the short URL
        NSArray *shareTokenParts = [shareToken componentsSeparatedByString:@"&"];
        if (shareTokenParts != nil && shareTokenParts.count > 0)
        {
            NSString *shareTokenOnly = [shareTokenParts objectAtIndex:0];
            shareURL = [NSString stringWithFormat:@"%@/g/%@/uims", kShortCodeBaseUrl, shareTokenOnly];
        }
        else
        {
            shareURL = [NSString stringWithFormat:@"%@/g/%@/uisv", kShortCodeBaseUrl, shareToken];            
        }        
	}
	else
	{
		shareURL = [NSString stringWithFormat:@"%@/p/%@/uisv", kShortCodeBaseUrl, shareToken];
	}

	return shareURL;
}

- (NSString *)shareSubjectText
{
	NSString *emailSubject = nil;
	if ( [self isEventAlbum] )
	{
		emailSubject = @"Check out our photos!";
	}
	else
	{
		emailSubject = @"Check out my photos!";
	}

	return emailSubject;
}

- (NSString *)shareDescriptionText
{
	return [NSString stringWithFormat:@"View my %@ album on KodakGallery.com.  The fun, cool, free way to share pictures of your Happenings!", [self name]];
}

- (NSString *)shareSMSText
{
	return [NSString stringWithFormat:@"Come visit my %@ album - %@", [self name], [self shareURL]];
}

- (NSString *)shareEmailText
{
	NSString *emailHTML;

	NSString *thumbUrl = @"";
	if ( [[self photos] count] > 0 )
	{
		PhotoModel *photo = [[self photos] objectAtIndex:0];
		thumbUrl = [photo URLForVersion:TTPhotoVersionThumbnail];
	}
	else
	{
		thumbUrl = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kEmptyAlbumIcon];
	}

	NSString *shareToken = [self shareToken];
	NSString *albumTitle = [self name];

	// Pull in the appropriate template for the album type
	if ( [self isEventAlbum] )
	{
		emailHTML = [ShareEmailTemplates shareGroupEmailTemplate:shareToken albumTitle:albumTitle thumbUrl:thumbUrl];
	}
	else
	{
		emailHTML = [ShareEmailTemplates sharePersonalEmailTemplate:shareToken albumTitle:albumTitle thumbUrl:thumbUrl];
	}

	return emailHTML;
}

#pragma mark RKRequestDelegate

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
	[_albumId release];
	[_groupId release];
	[_name release];
	[_albumDescription release];
	[_userEditedDate release];
	[_timeCreated release];
	[_timeUpdated release];
	[_firstPhoto release];
	[_photos release];
	[_photoCount release];
	[_memberCount release];
	[_groupAlbumType release];
	TT_RELEASE_SAFELY(_type)
	[_shareToken release];

	[_founder release];
	[_members release];
	[_autoShareToken release];
	[_permission release];
	[super dealloc];
}


@end
