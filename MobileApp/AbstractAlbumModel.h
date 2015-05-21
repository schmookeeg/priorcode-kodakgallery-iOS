//
//  EventAlbumModel.h
//  MobileDemo
//
//  Created by Jon Campbell on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "PhotoModel.h"
#import "GroupMemberModel.h"
#import "AlbumModelDelegate.h"
#import "AbstractModelDelegate.h"
#import "ShareModel.h"

@interface AbstractAlbumModel : AbstractModel <AlbumModelDelegate, RKRequestDelegate, ShareModel>
{
	NSNumber *_groupId;
	NSNumber *_albumId;
	NSString *_name;
    NSString *_albumDescription;
    NSString *_creationDate;
	NSDate *_timeCreated;
	NSDate *_timeUpdated;
	PhotoModel *_firstPhoto;
	NSArray *_photos;
	NSNumber *_photoCount;
	NSNumber *_memberCount;
	NSNumber *_groupAlbumType;
	GroupMemberModel *_founder;
	NSArray *_members;
	NSNumber *_type;
	NSString *_autoShareToken;
	NSString *_shareToken;
	BOOL _allowAnon;
	BOOL _isFriends;

	id <AlbumModelDelegate> _delegateOverride;

	BOOL createRequest;
	NSNumber *_permission;
}


- (id)initWithAlbum:(AbstractAlbumModel *)album;

- (void)create;

- (void)edit;

- (void)join;

- (void)fetch;

- (void)createShare;

- (int)enabledOptions;

/**
 Abstract method to delete the album.  Subclasses should implement and call
 deleteAlbumUsingUrl:usingId:
 */

- (void)deleteAlbum;

/**
 Protected helper method that subclasses should call in their deleteAlbum implementation.
 */
- (void)deleteAlbumUsingUrl:(NSString *)albumUrl usingId:(NSNumber *)albumOrGroupId;


- (BOOL)isEventAlbum;

- (BOOL)isFriendAlbum;

- (BOOL)isMyAlbum;

- (BOOL)isVideoSlideshowAlbum;

- (void)processCreateResponse:(RKResponse *)response;

- (void)processJoinResponse:(RKResponse *)response;

- (void)processDeleteResponse:(RKResponse *)response;

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response;

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error;


- (NSDate *)timeUpdated;

- (void)setTimeUpdatedFromDate:(NSDate *)date;

- (void)setTimeUpdated:(NSString *)dateString;

- (NSDate *)timeCreated;

- (void)setTimeCreatedFromDate:(NSDate *)date;

- (void)setTimeCreated:(NSString *)dateString;


- (PhotoModel *)photoFromId:(NSNumber *)photoId;

+ (id)albumClassFromType:(int)albumType;

+ (NSString *)menuTitle;

+ (NSString *)menuIcon;

@property ( nonatomic, assign ) id <AlbumModelDelegate> delegate;

@property ( retain, nonatomic ) NSNumber *groupId;
@property ( retain, nonatomic ) NSNumber *albumId;
@property ( retain, nonatomic ) NSString *name;
@property ( retain, nonatomic ) NSString *albumDescription;
@property ( retain, nonatomic ) NSString *creationDate;
@property ( retain, nonatomic ) NSDate *userEditedDate;
@property ( retain, nonatomic ) PhotoModel *firstPhoto;
@property ( retain, nonatomic ) NSArray *photos;
@property ( retain, nonatomic ) NSNumber *photoCount;
@property ( retain, nonatomic ) NSNumber *memberCount;
@property ( retain, nonatomic ) NSNumber *groupAlbumType;
@property ( retain, nonatomic ) GroupMemberModel *founder;
@property ( retain, nonatomic ) NSArray *members;
@property ( retain, nonatomic ) NSNumber *type;
@property ( retain, nonatomic ) NSString *autoShareToken;
@property ( retain, nonatomic ) NSString *shareToken;
@property ( nonatomic ) BOOL allowAnon;
@property ( nonatomic ) BOOL isFriends;
@property ( nonatomic, retain ) NSNumber *permission;


@end
