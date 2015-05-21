//
//  PhotoModel.m
//  MobileDemo
//
//  Created by Jon Campbell on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoModel.h"
#import "ShareEmailTemplates.h"

@implementation PhotoModel
@synthesize photoId = _photoId, partitionId = _partitionId, height = _height, width = _width;
@synthesize sumoUrl = _sumoUrl, albUrl = _albUrl, bgUrl = _bgUrl, smUrl = _smUrl;
@synthesize fullResUrl = _fullResUrl, ownerId = _ownerId, caption = _caption;
@synthesize uploaderName = _uploaderName, uploaderId = _uploaderId;
@synthesize size = _size, photoSource = _photoSource, index = _index, numComments = _numComments, numLikes = _numLikes;
@synthesize delegate = _delegateOverride;
@synthesize selected = _selected;


+ (NSDictionary *)elementToPropertyMappings {
    return [NSDictionary dictionaryWithKeysAndObjects:
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
            @"numOfAnnotations", @"numLikes",
            nil];
}

- (NSDictionary *)serializeToDictionary {
    return [NSDictionary dictionaryWithKeysAndObjects:
            @"photoId", self.photoId,
            @"partitionId", self.partitionId,
            @"width", self.width,
            @"height", self.height,
            @"sumoUrl", self.sumoUrl,
            @"albUrl", self.albUrl,
            @"bgUrl", self.bgUrl,
            @"smUrl", self.smUrl,
            @"fullResUrl", self.fullResUrl,
            @"ownerId", self.ownerId,
            nil];
}

+ (NSDictionary *)elementToRelationshipMappings {
    return [NSDictionary dictionaryWithKeysAndObjects:

            nil];
}

+ (NSString *)primaryKeyProperty {
    return @"photoId";
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    // Needed for TTPhoto
    _size = CGSizeMake([[self width] floatValue], [[self height] floatValue]);
    _index = NSIntegerMax;
    _photoSource = nil;

    [super objectLoader:objectLoader didLoadObjects:objects];
}

- (void)downloadFullResolutionPhoto {
    NSString *strUrl = [self fullResUrl];
    NSURL *url = [NSURL URLWithString:strUrl];

    if (url != nil) {
        RKRequest *request = [RKRequest requestWithURL:url delegate:self];
        request.backgroundPolicy = RKRequestBackgroundPolicyNone;
        request.method = RKRequestMethodGET;
        request.userData = @"DownloadRequest";

        [request send];
    }
}

#pragma mark ShareModel

- (NSString *)shareURL {
    return [self bgUrl];
}

- (NSString *)shareSubjectText {
    return [NSString stringWithFormat:@"View my photo"];
}

- (NSString *)shareDescriptionText {
    return [NSString stringWithString:@"View my photo on KodakGallery.com!"];
}

- (NSString *)shareSMSText {
    return [NSString stringWithFormat:@"Come visit my photo - %@ \n Shared with the KODAK Gallery app.", [self shareURL]];
}

- (NSString *)shareEmailText {
    NSString *title = [self caption];
    NSString *emailHTML = [ShareEmailTemplates shareSingleImageEmailTemplate:title BGUrl:[self bgUrl]];
    return emailHTML;
}

#pragma mark TTPhoto

- (NSString *)URLForVersion:(TTPhotoVersion)version {
    switch (version) {
        case TTPhotoVersionLarge:
            return [self bgUrl];
        case TTPhotoVersionMedium:
            return [self bgUrl];
        case TTPhotoVersionSmall:
        case TTPhotoVersionThumbnail:
            return [self thumbUrl];
        default:
            return nil;
    }
}

- (NSString *)thumbUrl {
    return [[self albUrl] stringByReplacingOccurrencesOfString:@"/ALB" withString:[NSString stringWithFormat:@"/%@", kThumbnailLongSide]];
}

- (NSString *)thumbUrlAlternate {
    return [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kAlternateThumbURL, self.photoId, self.partitionId]];
}

- (void)deletePhotoFromAlbum:(NSNumber *)albumId {
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kServiceAlbumPicture, albumId, self.photoId]];
    NSURL *url = [NSURL URLWithString:strUrl];

    if (url != nil) {
        RKRequest *request = [RKRequest requestWithURL:url delegate:self];
        request.backgroundPolicy = RKRequestBackgroundPolicyNone;
        request.method = RKRequestMethodDELETE;
        request.userData = @"DeleteRequest";

        [request send];
    }
}

/*
 Helper method to perform the photo rotation.
 */
- (void)rotateUsingAngle:(int)angle inAlbum:(NSNumber *)albumId {
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kServiceAlbumPictureRotate, albumId, self.photoId, angle]];
    NSURL *url = [NSURL URLWithString:strUrl];

    if (url != nil) {
        RKRequest *request = [RKRequest requestWithURL:url delegate:self];
        request.backgroundPolicy = RKRequestBackgroundPolicyNone;
        request.method = RKRequestMethodPOST;

        NSDictionary *headers = [NSMutableDictionary dictionary];
        [headers setValue:@"text/xml" forKey:@"Content-Type"];
        request.additionalHTTPHeaders = headers;

        NSData *data = [[NSString stringWithString:@""] dataUsingEncoding:NSUTF8StringEncoding];
        request.URLRequest.HTTPBody = data;

        request.userData = @"RotateRequest";

        [request send];
    }
}

- (void)rotateLeftInAlbum:(NSNumber *)albumId {
    [self rotateUsingAngle:270 inAlbum:albumId];
}

- (void)rotateRightInAlbum:(NSNumber *)albumId {
    [self rotateUsingAngle:90 inAlbum:albumId];
}

- (void)dealloc {
    [_photoId release];
    [_partitionId release];
    [_width release];
    [_height release];
    [_sumoUrl release];
    [_albUrl release];
    [_bgUrl release];
    [_smUrl release];
    [_fullResUrl release];
    [_ownerId release];
    [_caption release];
    [_uploaderName release];
    [_numComments release];
    [_numLikes release];
    [_likes release];
    [_uploaderId release];

    [super dealloc];
}

#pragma mark - private method

/*
 After rotating a photo, the urls for the photo need to be updated.
 */
- (void)fetchPhotoUris:(NSString *)photoId {
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kServicePictureMetadataBasic, self.photoId]];
    NSURL *url = [NSURL URLWithString:strUrl];

    if (url != nil) {
        RKRequest *request = [RKRequest requestWithURL:url delegate:self];
        request.backgroundPolicy = RKRequestBackgroundPolicyNone;
        request.method = RKRequestMethodGET;
        request.userData = @"PhotoMetadataRequest";

        [request send];
    }
}

#pragma mark - RKRequestDelegates

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    NSError *error = nil;
    NSData *data = [response body];

    if ([response isOK]) {
        if ([request.userData isEqualToString:@"DownloadRequest"]) {
            UIImage *img = [UIImage imageWithData:data];

            NSLog(@"downloaded image size on camera roll :: W: %f - H: %f", img.size.width, img.size.height);

            NSParameterAssert(img);
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
            [self.delegate photoDownloadDidSucceedWithModel:self];
        }
        else if ([request.userData isEqualToString:@"DeleteRequest"]) {
            [self.delegate photoDeletionDidSucceedWithModel:self];
        }
        else if ([request.userData isEqualToString:@"RotateRequest"]) {
            DDXMLElement *root = [[[[DDXMLDocument alloc] initWithData:data options:0 error:&error] autorelease] rootElement];
            DDXMLElement *photoIdDom = [[root elementsForName:@"photoId"] objectAtIndex:0];
            DDXMLElement *partitionIdDom = [[root elementsForName:@"partitionId"] objectAtIndex:0];
            self.partitionId = [NSNumber numberWithDouble:[[partitionIdDom stringValue] doubleValue]];

//            NSLog( @"Rotate completed OK - Changing photo id from %@ to %@", self.photoId, [photoIdDom stringValue] );
            self.photoId = [NSNumber numberWithLongLong:[[photoIdDom stringValue] longLongValue]];

            [self fetchPhotoUris:[photoIdDom stringValue]];
        }
        else if ([request.userData isEqualToString:@"PhotoMetadataRequest"]) {
            DDXMLElement *root = [[[[DDXMLDocument alloc] initWithData:data options:0 error:&error] autorelease] rootElement];
            DDXMLElement *photoSmallURLDom = [[root elementsForName:@"photoUriSmallJpeg"] objectAtIndex:0];
            DDXMLElement *photoMediumURLDom = [[root elementsForName:@"photoUriMediumJpeg"] objectAtIndex:0];
            DDXMLElement *photoThumbURLDom = [[root elementsForName:@"photoUriThumbJpeg"] objectAtIndex:0];
            DDXMLElement *photoSumoURLDom = [[root elementsForName:@"photoUriSumoJpeg"] objectAtIndex:0];

            self.sumoUrl = [photoSumoURLDom stringValue];
            self.bgUrl = [photoMediumURLDom stringValue];
            self.albUrl = [photoSmallURLDom stringValue];
            self.smUrl = [photoThumbURLDom stringValue];

            [self.delegate photoRotationDidSucceedWithModel:self];
        }
    }
    else {
        if ([request.userData isEqualToString:@"DownloadRequest"]) {
            [self.delegate photoDownloadDidFailWithError:response.failureError];
        }
        else if ([request.userData isEqualToString:@"DeleteRequest"]) {
            [self.delegate photoDeletionDidFailWithError:response.failureError];
        }
        else if ([request.userData isEqualToString:@"RotateRequest"]) {
//			NSLog( @"Rotate failed for id %@", self.photoId );

            [self.delegate photoRotationDidFailWithError:response.failureError];
        }
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {

    if ([request.userData isEqualToString:@"DownloadRequest"]) {
        [self.delegate photoDownloadDidFailWithError:error];
    }
    else if ([request.userData isEqualToString:@"DeleteRequest"]) {
        [self.delegate photoDeletionDidFailWithError:error];
    }
    else if ([request.userData isEqualToString:@"RotateRequest"]) {
        [self.delegate photoRotationDidFailWithError:error];
    }
}

@end
