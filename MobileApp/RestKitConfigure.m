//
//  RestKitConfigure.m
//  MobileApp
//
//  Created by Jon Campbell on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RestKitConfigure.h"
#import "ErrorMessage.h"
#import "PhotoModel.h"
#import "GroupMemberModel.h"
#import "AbstractAlbumModel.h"
#import "AlbumListModel.h"
#import "PhotoCommentModel.h"
#import "AlbumAnnotationsModel.h"
#import "EventModel.h"
#import "EventListModel.h"
#import "EventDetailAlbumModel.h"
#import "PhotoCommentsListModel.h"
#import "PrintToStoreCatalogModel.h"
#import "PrintSKUModel.h"
#import "PrintSKUPricingModel.h"
#import "StoreModel.h"
#import "RetailerModel.h"
#import "StoreCollectionModel.h"
#import "SPMRestKitTranslator.h"

@implementation RestKitConfigure

+ (void)initializeMappings {
    RKObjectManager *objectManager = [RKObjectManager objectManagerWithBaseURL:kRestKitBaseUrl]; //kRestKitBaseUrl];
    [RKRequestQueue sharedQueue].showsNetworkActivityIndicatorWhenBusy = YES;

    // Error Messages
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[ErrorMessage class]];
    [errorMapping mapKeyPathsToAttributes:
            @"detail", @"detail",
            @"errorCode", @"errorCode",
            nil];
    [objectManager.mappingProvider registerMapping:errorMapping withRootKeyPath:@"ErrorList.Error"];

    //////  Photo
    RKObjectMapping *photoMapping = [RKObjectMapping mappingForClass:[PhotoModel class]];
    photoMapping.setDefaultValueForMissingAttributes = YES;
    photoMapping.setNilForMissingRelationships = NO;

    [photoMapping mapKeyPathsToAttributes:
            @"id", @"photoId",
            @"partitionId", @"partitionId",
            @"height", @"height",
            @"width", @"width",
            @"photoUriSumoJpeg", @"sumoUrl",
            @"photoUriSmallJpeg", @"albUrl",
            @"photoUriMediumJpeg", @"bgUrl",
            @"photoUriThumbJpeg", @"smUrl",
            @"photoUriFullResJpeg", @"fullResUrl",
            @"ownerId", @"ownerId",
            @"UploadedBy.firstName", @"uploaderName",
            @"UploadedBy.uploaderId", @"uploaderId",
            @"numOfComments", @"numComments",
            nil];

    [objectManager.mappingProvider registerMapping:photoMapping withRootKeyPath:@"photo"];

    //////  Group members
    RKObjectMapping *groupMemberMapping = [RKObjectMapping mappingForClass:[GroupMemberModel class]];
    groupMemberMapping.setDefaultValueForMissingAttributes = YES;
    groupMemberMapping.setNilForMissingRelationships = YES;

    [groupMemberMapping mapKeyPathsToAttributes:
            @"firstName", @"firstName",
            @"email", @"email",
            @"role", @"role",
            @"status", @"status",
            @"memberAvatarLink", @"memberAvatarLink",
            @"uploadCount", @"uploadCount",
            nil];

    //////  Event Album
    RKObjectMapping *eventAlbumMapping = [RKObjectMapping mappingForClass:[AbstractAlbumModel class]];
    eventAlbumMapping.setDefaultValueForMissingAttributes = NO;
    eventAlbumMapping.setNilForMissingRelationships = NO;

    [eventAlbumMapping mapKeyPathsToAttributes:
            @"Group.id", @"groupId",
            @"Album.id", @"albumId",
            @"Album.name", @"name",
            @"Album.description", @"albumDescription",
            @"Album.userEditedDate", @"creationDate",
            @"memberCount", @"memberCount",
            @"Album.size", @"photoCount",
            @"Album.lastUpdatedDate", @"timeUpdated",
            @"Album.timeCreated", @"timeCreated",
            @"Album.type", @"type",
            @"Album.autoShareToken", @"autoShareToken",
            @"Album.permissions", @"permission",
            @"isFriends", @"isFriends",
            nil];

    [eventAlbumMapping mapKeyPath:@"Album.firstPhoto" toRelationship:@"firstPhoto" withMapping:photoMapping];
    [eventAlbumMapping mapKeyPath:@"Album.pictures" toRelationship:@"photos" withMapping:photoMapping];
    [eventAlbumMapping mapKeyPath:@"Group.GroupFounder" toRelationship:@"founder" withMapping:groupMemberMapping];
    [eventAlbumMapping mapKeyPath:@"GroupMembers.groupMember" toRelationship:@"members" withMapping:groupMemberMapping];


    //////  Event Full Album
    RKObjectMapping *eventAlbumFullMapping = [RKObjectMapping mappingForClass:[AbstractAlbumModel class]];
    eventAlbumFullMapping.setDefaultValueForMissingAttributes = YES;
    eventAlbumFullMapping.setNilForMissingRelationships = YES;

    [eventAlbumFullMapping mapKeyPathsToAttributes:
            @"id", @"groupId",
            @"Album.id", @"albumId",
            @"Album.name", @"name",
            @"Album.description", @"albumDescription",
            @"Album.userEditedDate", @"creationDate",
            @"GroupMembers.groupMember.@count", @"memberCount",
            @"Album.size", @"photoCount",
            @"Album.permissions", @"permission",
            @"timeUpdated", @"timeUpdated",
            @"timeCreated", @"timeCreated",
            @"Album.type", @"type",
            @"autoShareToken", @"autoShareToken",
            nil];

    [eventAlbumFullMapping mapKeyPath:@"Album.firstPhoto" toRelationship:@"firstPhoto" withMapping:photoMapping];
    [eventAlbumFullMapping mapKeyPath:@"Album.pictures" toRelationship:@"photos" withMapping:photoMapping];
    [eventAlbumFullMapping mapKeyPath:@"Group.GroupFounder" toRelationship:@"founder" withMapping:groupMemberMapping];
    [eventAlbumFullMapping mapKeyPath:@"GroupMembers.groupMember" toRelationship:@"members" withMapping:groupMemberMapping];


    [objectManager.mappingProvider registerMapping:eventAlbumFullMapping withRootKeyPath:@"Group"];


    RKObjectMapping *albumMapping = [RKObjectMapping mappingForClass:[AbstractAlbumModel class]];
    albumMapping.setDefaultValueForMissingAttributes = NO;
    albumMapping.setNilForMissingRelationships = NO;

    [albumMapping mapKeyPathsToAttributes:
            @"id", @"albumId",
            @"name", @"name",
            @"size", @"photoCount",
            @"lastUpdatedDate", @"timeUpdated",
            @"type", @"type",
            @"autoShareToken", @"autoShareToken",
            @"isFriends", @"isFriends",
            @"description", @"albumDescription",
            nil];

    [albumMapping mapKeyPath:@"firstPhoto" toRelationship:@"firstPhoto" withMapping:photoMapping];
    [albumMapping mapKeyPath:@"pictures" toRelationship:@"photos" withMapping:photoMapping];

    [objectManager.mappingProvider registerMapping:albumMapping withRootKeyPath:@"Album"];

    ////// Album List
    RKObjectMapping *albumListMapping = [RKObjectMapping mappingForClass:[AlbumListModel class]];

    [albumListMapping mapKeyPath:@"AlbumItem" toRelationship:@"albums" withMapping:eventAlbumMapping];
    [objectManager.mappingProvider registerMapping:albumListMapping withRootKeyPath:@"AllAlbumList"];


    //////  Comments
    RKObjectMapping *commentMapping = [RKObjectMapping mappingForClass:[PhotoCommentModel class]];
    commentMapping.setDefaultValueForMissingAttributes = YES;
    commentMapping.setNilForMissingRelationships = YES;

    [commentMapping mapKeyPathsToAttributes:
            @"id", @"commentId",
            @"photoId", @"photoId",
            @"authorId", @"authorId",
            @"author", @"author",
            @"email", @"email",
            @"lastUpdated", @"lastUpdated",
            @"text", @"text",
            nil];

    RKObjectMapping *commentListMapping = [RKObjectMapping mappingForClass:[PhotoCommentsListModel class]];

    [commentListMapping mapKeyPath:@"Comment" toRelationship:@"comments" withMapping:commentMapping];
    [objectManager.mappingProvider registerMapping:commentListMapping withRootKeyPath:@"Comments"];

    //////  Likes - Annotations
    // Annotation for a photo
    RKObjectMapping *pictureAnnotationMapping = [RKObjectMapping mappingForClass:[PictureAnnotationModel class]];
    pictureAnnotationMapping.setDefaultValueForMissingAttributes = YES;
    pictureAnnotationMapping.setNilForMissingRelationships = YES;
    [pictureAnnotationMapping mapKeyPathsToAttributes:
            @"id", @"annotationId",
            @"annotatorName", @"annotatorName",
            @"annotatorId", @"annotatorId",
            @"timestamp", @"timeStamp",
            nil];

    // The list of annotations for a photo
    RKObjectMapping *picturesAnnotationsMapping = [RKObjectMapping mappingForClass:[AlbumPicturesAnnotationsModel class]];
    picturesAnnotationsMapping.setDefaultValueForMissingAttributes = YES;
    picturesAnnotationsMapping.setNilForMissingRelationships = YES;
    [picturesAnnotationsMapping mapKeyPathsToAttributes:
            @"id", @"photoId",
            nil];
    [picturesAnnotationsMapping mapKeyPath:@"annotations" toRelationship:@"annotations" withMapping:pictureAnnotationMapping];
    [objectManager.mappingProvider registerMapping:picturesAnnotationsMapping withRootKeyPath:@"pictureAnnotations"];


    // The list of photos that have annotations in the album
    RKObjectMapping *albumAnnotationsMapping = [RKObjectMapping mappingForClass:[AlbumAnnotationsModel class]];

    [albumAnnotationsMapping mapKeyPath:@"pictureAnnotations" toRelationship:@"picturesAnnotations" withMapping:picturesAnnotationsMapping];
    [objectManager.mappingProvider registerMapping:albumAnnotationsMapping withRootKeyPath:@"AlbumAnnotations"];


    // Event Stream API
    RKObjectMapping *eventMapping = [RKObjectMapping mappingForClass:[EventModel class]];
    eventMapping.setDefaultValueForMissingAttributes = YES;
    eventMapping.setNilForMissingRelationships = YES;
    [eventMapping mapKeyPathsToAttributes:
            @"id", @"eventId",
            @"link", @"eventLink",
            @"SubjType", @"subjectType",
            @"SubjId", @"subjectId",
            @"SubjName", @"subjectName",
            @"SubjIcon", @"subjectIcon",
            @"ObjType", @"objectType",
            @"ObjId", @"objectId",
            @"ObjName", @"objectName",
            @"ObjIcon", @"objectIcon",
            @"ObjOwnerId", @"objectOwnerId",
            @"ObjOwnerName", @"objectOwnerName",
            @"PredType", @"predicateType",
            @"Time", @"time",
            @"AlbumIdHint", @"albumIdHint",
            @"PublisherId", @"publisherId",
            nil];

    RKObjectMapping *eventListMapping = [RKObjectMapping mappingForClass:[EventListModel class]];
    [eventListMapping mapKeyPath:@"EventList.Event" toRelationship:@"events" withMapping:eventMapping];
    [eventListMapping mapKeyPath:@"NewEventsCount" toAttribute:@"unreadEventsCount"];
    [objectManager.mappingProvider registerMapping:eventListMapping withRootKeyPath:@"Events"];

    RKObjectMapping *eventDetailAlbumMapping = [RKObjectMapping mappingForClass:[EventDetailAlbumModel class]];
    [objectManager.mappingProvider registerMapping:eventDetailAlbumMapping withRootKeyPath:@"Event.Detail.Album"];
    [eventDetailAlbumMapping mapKeyPathsToAttributes:
            @"id", @"albumId",
            @"name", @"albumName",
            nil];

    RKObjectRouter *router = [objectManager router];

    [router routeClass:[AbstractAlbumModel class] toResourcePath:@"/site/rest/v1.0/group/(groupId)"];
    
    [RestKitConfigure initializeCartMappings:objectManager];
}


+ (void)initializeCartMappings:(RKObjectManager *)objectManager {

     ////// PrintSKUPricing
         RKObjectMapping *printSkuPricingMapping = [RKObjectMapping mappingForClass:[PrintSKUPricingModel class]];
    printSkuPricingMapping.setDefaultValueForMissingAttributes = YES;
    printSkuPricingMapping.setNilForMissingRelationships = YES;
         [printSkuPricingMapping mapKeyPathsToAttributes:
                 @"name", @"name",
                 @"price", @"price",
                 @"salePrice", @"salePrice",
                 nil];

    ////// PrintSKU
    RKObjectMapping *skuMapping = [RKObjectMapping mappingForClass:[PrintSKUModel class]];
    skuMapping.setDefaultValueForMissingAttributes = YES;
    skuMapping.setNilForMissingRelationships = YES;
    [skuMapping mapKeyPathsToAttributes:
            @"skuId", @"skuId",
            @"paperSize", @"paperSize",
            @"colorMgmt", @"colorMgmt",
            @"paperFinish", @"paperFinish",
            @"border", @"border",
            @"tint", @"tint",
            nil];


    [skuMapping mapKeyPath:@"pricing" toRelationship:@"pricing" withMapping:printSkuPricingMapping];


    ////// PrintToStoreCatalog
    RKObjectMapping *catalogMapping = [RKObjectMapping mappingForClass:[PrintToStoreCatalogModel class]];

    [catalogMapping mapKeyPath:@"PrintSKUList" toRelationship:@"skuList" withMapping:skuMapping];
    [objectManager.mappingProvider registerMapping:catalogMapping withRootKeyPath:@"PrintToStoreCatalog"];




    ////// RetailerModel
    RKObjectMapping *retailerMapping = [RKObjectMapping mappingForClass:[RetailerModel class]];
    retailerMapping.setDefaultValueForMissingAttributes = YES;
    retailerMapping.setNilForMissingRelationships = YES;
    [retailerMapping mapKeyPathsToAttributes:
            @"logoUrl", @"logoUrl",
            @"maxOrderAmt", @"maxOrderAmt",
            nil];

    ////// StoreModel
      RKObjectMapping *storeMapping = [RKObjectMapping mappingForClass:[StoreModel class]];
    storeMapping.setDefaultValueForMissingAttributes = YES;
    storeMapping.setNilForMissingRelationships = YES;
      [storeMapping mapKeyPathsToAttributes:
              @"storeId", @"storeId",
              @"address", @"address",
              @"city", @"city",
              @"state", @"state",
              @"distance", @"distance",
              @"enabled", @"enabled",
              @"formatedStoreHours", @"formattedStoreHours",
              @"id", @"id",
              @"name", @"name",
              @"phoneNumber", @"phoneNumber",
              @"postalCode", @"postalCode",
              @"printSizes", @"printSizes",
              @"retailerId", @"retailerId",
              @"serviceTime", @"serviceTime",
              @"storeDays", @"storeDays",
              @"storeHours", @"storeHours",
              @"latitude", @"latitude",
              @"longitude", @"longitude",
              nil];

    [storeMapping mapKeyPath:@"retailer" toRelationship:@"retailer" withMapping:retailerMapping];


    ////// StoreCollectionModel
       RKObjectMapping *storeCollectionMapping = [RKObjectMapping mappingForClass:[StoreCollectionModel class]];

       [storeCollectionMapping mapKeyPath:@"Store" toRelationship:@"stores" withMapping:storeMapping];
       [objectManager.mappingProvider registerMapping:storeCollectionMapping withRootKeyPath:@"StoreList"];



}




@end
