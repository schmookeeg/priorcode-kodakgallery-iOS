//
//  UploadModel.m
//  MobileApp
//
//  Created by Jon Campbell on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadModel.h"
#import "UserModel.h"
#import "UIImage+Resize.h"
#import "SettingsModel.h"
#import "DDXML.h"
#import <ImageIO/ImageIO.h>

@interface UploadModel ()

@property ( nonatomic, retain ) RKRequest *currentUploadRequest;

@end

@implementation UploadModel
@synthesize album = _album, delegate = _delegate, uploadQueue = _uploadQueue;
@synthesize uploadedPhotoIds = _uploadedPhotoIds;
@synthesize currentUploadRequest;


- (void)uploadImageQueue:(NSArray *)images album:(AbstractAlbumModel *)album
{
	[self setAlbum:album];
	[self uploadImageQueue:images];
}

- (void)uploadImageQueue:(NSArray *)images
{
	self.uploadedPhotoIds = [NSMutableArray array];
	_currentQueueIndex = -1;
	[self setUploadQueue:images];
	[self uploadImage];
}

- (void)uploadImage
{
	// Are we done trying to upload all of the images in the current queue?
	if ( _currentQueueIndex + 1 >= [[self uploadQueue] count] )
	{
		[self uploadComplete];
		return;
	}

	// More work to do in the current queue.  Locate the imageData for the image.

	id current = [_uploadQueue objectAtIndex:++_currentQueueIndex];

	if ( [current isKindOfClass:[NSURL class]] )
	{
		// Asynchronously load the image data for the NSURL instance. This will send self the
		// assetLibraryImageFetched: message when it completes, which will continue the
		// upload process.
		[self getFullImageDataForAssetURL:current];
	}
	else
	{
		// Not loading from the asset library, try to get the image data directly
		// from the upload queue itself.

		NSData *imageData = nil;

		if ( [current isKindOfClass:[NSData class]] )
		{
			imageData = current;
		}
		else if ( [current isKindOfClass:[UIImage class]] )
		{
			imageData = UIImageJPEGRepresentation( (UIImage *) current, kImageUploadResizeCompression );
		}
		else
		{
			NSLog( @"Invalid image object passed in at index %d: %@", _currentQueueIndex - 1, current );
		}

		if ( imageData != nil )
		{
			[self uploadImageData:imageData];
		}
	}
}

- (void)resizeImageAndUpload:(NSData *)sourceImageData
{
	UIImage *sourceImage = [[UIImage alloc] initWithData:sourceImageData];

	BOOL resizeUploads = [[SettingsModel settings] resizeImagesOnUpload];
	if ( !resizeUploads ||
			( sourceImage.size.width <= kImageUploadResizeMaxEdge && sourceImage.size.height <= kImageUploadResizeMaxEdge ) )
	{
		// Image size is below the resize level so just send it as-is
		[sourceImage release];
		NSLog( @"Performing upload without resize" );
		[self uploadImageData:sourceImageData];
		return;
	}

	NSLog( @"Resizing image prior to upload" );
	CGSize newSize;
	if ( sourceImage.size.width > sourceImage.size.height )
	{
		newSize = CGSizeMake( kImageUploadResizeMaxEdge, kImageUploadResizeMaxEdge / sourceImage.size.width * sourceImage.size.height );
	}
	else
	{
		newSize = CGSizeMake( kImageUploadResizeMaxEdge / sourceImage.size.height * sourceImage.size.width, kImageUploadResizeMaxEdge );
	}

	// Get the metadata of the source image as a mutable dictionary
	CGImageSourceRef originalImage = CGImageSourceCreateWithData( (CFDataRef) sourceImageData, NULL );
	NSDictionary *metadata = (NSDictionary *) CGImageSourceCopyPropertiesAtIndex( originalImage, 0, NULL );
	CFRelease( originalImage );
	originalImage = NULL;
	NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
	[metadata release];
	metadata = nil;

	NSMutableDictionary *exifDictionary = [[metadataAsMutable objectForKey:(NSString *) kCGImagePropertyExifDictionary] mutableCopy];
	// Guard against no exif data, which would yield a crash trying to set the kCGImagePropertyExifDictionary
	if ( exifDictionary != nil )
	{
		// The image our resize code returns is always in the UIImageOrientationUp orienation.  Also, our image is now smaller
		// as a result of the resize.  We must modify the metadata to respect these new values or the image may get rotated again
		// when we do CGImageDestinationAddImageFromSource
		[exifDictionary setObject:[NSNumber numberWithFloat:newSize.width] forKey:(NSString *) kCGImagePropertyExifPixelXDimension];
		[exifDictionary setObject:[NSNumber numberWithFloat:newSize.height] forKey:(NSString *) kCGImagePropertyExifPixelYDimension];
		[metadataAsMutable setObject:exifDictionary forKey:(NSString *) kCGImagePropertyExifDictionary];
		[exifDictionary release];
	}

	[metadataAsMutable setObject:[NSNumber numberWithFloat:newSize.width] forKey:(NSString *) kCGImagePropertyPixelWidth];
	[metadataAsMutable setObject:[NSNumber numberWithFloat:newSize.height] forKey:(NSString *) kCGImagePropertyPixelHeight];
	[metadataAsMutable setObject:[NSNumber numberWithInt:1] forKey:(NSString *) kCGImagePropertyOrientation];

	/*	
	  CFDictionaryRef options = (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent, (id)[NSNumber numberWithFloat:kImageUploadResizeMaxEdge], (id)kCGImageSourceThumbnailMaxPixelSize, nil];
	  CGImageRef imgRef = CGImageSourceCreateThumbnailAtIndex(originalImage, 0, options);
	  NSData *resizedImageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:imgRef], kImageUploadResizeCompression);
	  CGImageRelease(imgRef);
	  */

	UIImage *resizedImage = [sourceImage resizedImage:newSize interpolationQuality:kCGInterpolationMedium];
	[sourceImageData release];
	[sourceImage release];

	NSData *resizedImageData = UIImageJPEGRepresentation( resizedImage, kImageUploadResizeCompression );
	if ( resizedImageData == nil )
	{
		NSLog( @"***Could not create JPEG from resized image ***" );

		[metadataAsMutable release];

		// Just upload the original image since resize failed
		[self uploadImageData:sourceImageData];
		return;
	}

	//this will be the data CGImageDestinationRef will write into.  dest_data is what we will ulitmately upload
	NSMutableData *dest_data = [NSMutableData data];
	CGImageDestinationRef destination = CGImageDestinationCreateWithData( (CFMutableDataRef) dest_data, CFSTR("public.jpeg"), 1, NULL );
	if ( !destination )
	{
		NSLog( @"***Could not create image destination ***" );
	}

	//add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
	CGImageSourceRef resizedSource = CGImageSourceCreateWithData( (CFDataRef) resizedImageData, NULL );
	CGImageDestinationAddImageFromSource( destination, resizedSource, 0, (CFDictionaryRef) metadataAsMutable );
	[metadataAsMutable release];

	//tell the destination to write the image data and metadata into our data object.
	//It will return false if something goes wrong
	BOOL success = NO;
	success = CGImageDestinationFinalize( destination );

	CFRelease( resizedSource );
	if ( destination )
	{
		CFRelease( destination );
	}

	if ( success )
	{
		[self uploadImageData:dest_data];
	}
	else
	{
		NSLog( @"***Could not create data from image destination ***" );
	}

}

- (void)assetLibraryImageFetched:(NSData *)imageData
{
	NSLog( @"assetLibraryImageFetched - now uploading" );
	//[self uploadImageData:imageData];
	[self resizeImageAndUpload:imageData];
}

- (void)uploadImageData:(NSData *)imageData
{

	// TODO: This may or may not cause a memory leak in the long term, but it fixes uploads on iOS5 for now
	RKParams *params = [[RKParams params] retain];

	NSLog( @"About to set imageData params" );

	RKParamsAttachment *attachment = [params setData:imageData forParam:@"image"];
	attachment.MIMEType = @"image/jpg";
	attachment.fileName = @"picture.jpg";

	NSString *eke = nil;
	NSString *eks = nil;
	NSString *email;

	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:kRestKitBaseUrl]];
	for ( NSHTTPCookie *cookie in cookies )
	{
		NSString *name = [cookie name];
		NSString *value = [cookie value];
		if ( [name isEqualToString:@"DYN_EMAIL"] )
		{
			email = value;
		}
		else if ( [name isEqualToString:@"EK_E"] )
		{
			eke = value;
		}
		else if ( [name isEqualToString:@"EK_S"] )
		{
			eks = value;
		}
	}

	// TODO: move this to a global class
	[UserModel encodeString:&email];


	if ( eke )
	{
		[UserModel encodeString:&eke];
	}
	if ( eks )
	{
		[UserModel encodeString:&eks];
	}

	NSNumber *albumId = [_album albumId];

	NSString *uploadSource = [[SettingsModel settings] resizeImagesOnUpload] ? kUploadCompressedSourceID
							 : kUploadSourceID;

	NSString *url = nil;

	if ( [_album isEventAlbum] )
	{
		NSNumber *groupId = [_album groupId];
		url = ( eke && eks )
			  ? [NSString stringWithFormat:kServiceUploadEventAlbumWithEK, groupId, albumId, uploadSource, email, eks, eke]
			  : [NSString stringWithFormat:kServiceUploadEventAlbum, groupId, albumId, uploadSource, email];

	}
	else if ( [_album isMyAlbum] )
	{
		url = ( eke && eks )
			  ? [NSString stringWithFormat:kServiceUploadAlbumWithEK, albumId, uploadSource, email, eks, eke]
			  : [NSString stringWithFormat:kServiceUploadAlbum, albumId, uploadSource, email];
	}

	url = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, url];

	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:url] delegate:self];
	request.backgroundPolicy = RKRequestBackgroundPolicyRequeue;
	request.method = RKRequestMethodPOST;
	request.params = params;

	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"text/xml" forKey:@"Content-Type"];

	[request setAdditionalHTTPHeaders:headers];


	if ( url != nil )
	{
		self.currentUploadRequest = request;
		[request send];
	}
}

- (void)requestDidStartLoad:(RKRequest *)request
{
	if ( [[request userData] isEqualToString:@"uploadRearrangeRequest"] )
	{
		return;
	}
	if ( [_delegate respondsToSelector:@selector(uploadFileStart:uploadIndex:)] )
	{
		[_delegate uploadFileStart:self uploadIndex:_currentQueueIndex];
	}
}

- (void)request:(RKRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{

	if ( [[request userData] isEqualToString:@"uploadRearrangeRequest"] )
	{
		return;
	}
	if ( [_delegate respondsToSelector:@selector(uploadStatusUpdate:uploadIndex:totalBytesWritten:totalBytesExpectedToWrite:)] )
	{
		[_delegate uploadStatusUpdate:self uploadIndex:_currentQueueIndex totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
	}
}

- (void)uploadComplete
{
	[self uploadRearrangeCall];
}


- (void)uploadRearrangeComplete
{
	if ( [_delegate respondsToSelector:@selector(uploadAllComplete:)] )
	{
		[_delegate uploadAllComplete:self];
	}

	self.currentUploadRequest = nil;
	self.uploadQueue = nil;
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	if ( [[request userData] isEqualToString:@"uploadRearrangeRequest"] )
	{
		[self uploadRearrangeComplete];
		return;
	}

	if ( [response isOK] )
	{
		if ( [_delegate respondsToSelector:@selector(uploadFileComplete:uploadIndex:)] )
		{
			[_delegate uploadFileComplete:self uploadIndex:_currentQueueIndex];
		}

		@try
		{
			[_uploadedPhotoIds addObject:[self extractPhotoIdFromResponse:[response bodyAsString]]];
		}
		@catch ( NSException *ex )
		{
			NSLog( @"Failed extracting photoIdFromResponse: %@", [response bodyAsString] );
			if ( [_delegate respondsToSelector:@selector(uploadFailure:uploadIndex:response:error:)] )
			{
				[_delegate uploadFailure:self uploadIndex:_currentQueueIndex response:response error:[response failureError]];
			}

		}

	}
	else
	{
		if ( [_delegate respondsToSelector:@selector(uploadFailure:uploadIndex:response:error:)] )
		{
			[_delegate uploadFailure:self uploadIndex:_currentQueueIndex response:response error:[response failureError]];
		}
	}

	[self uploadImage];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
	if ( [_delegate respondsToSelector:@selector(uploadStartFailure:uploadIndex:request:error:)] )
	{
		[_delegate uploadStartFailure:self uploadIndex:_currentQueueIndex request:request error:error];
	}

	[self uploadImage];
}

- (void)cancelUploadQueue
{
	// Clear out the upload queue so we don't upload anymore
	self.uploadQueue = nil;

	// Cancel the currently executing upload request
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];

	self.currentUploadRequest = nil;

}

/*
 We need to call upload rearrange on the server so that the server knows the upload is complete
 and so that it can send out the upload notification.
 */
- (void)uploadRearrangeCall
{
	if ( [_uploadedPhotoIds count] < 1 )
	{
		// Nothing to rearrange but we still need to notify the delegate that we are done.
		[self uploadRearrangeComplete];
		return;
	}

	// Temporary fix for crash https://jc.ofoto.com/jira/browse/STABTWO-1626 until we can figure out the
	// root cause of why the _album or albumId would be null in the case described in the issue.
	NSNumber *albumId = [_album albumId];
	if ( albumId != nil )
	{
		// now we need to do the upload rearrange call
		DDXMLElement *root = [DDXMLElement elementWithName:@"AlbumPhotos"];
		[root addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://namespace.kodakgallery.com/site/20080402/Picture"]];

		[root addChild:[DDXMLNode elementWithName:@"isUpload" stringValue:@"true"]];
		[root addChild:[DDXMLNode elementWithName:@"isDelta" stringValue:@"true"]];

		for ( NSString *photoId in _uploadedPhotoIds )
		{
			[root addChild:[DDXMLNode elementWithName:@"photoId" stringValue:photoId]];
		}

		NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kServiceUploadAlbumRearrange];
		urlString = [NSString stringWithFormat:urlString, albumId];


		RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];

		NSDictionary *headers = [NSMutableDictionary dictionary];
		[headers setValue:@"text/xml" forKey:@"Content-Type"];

		[request setAdditionalHTTPHeaders:headers];

		NSData *data = [[root XMLString] dataUsingEncoding:NSUTF8StringEncoding];

		[request setMethod:RKRequestMethodPOST];

		[request.URLRequest setHTTPBody:data];
		[request setUserData:@"uploadRearrangeRequest"];
		[request send];
	}
	else
	{
		NSLog( @"No valid albumId in uploadRearrangeCall." );

		// Couldn't construct a URL to call, but still notify the delegate that we are done.
		[self uploadRearrangeComplete];
	}
}

- (void)dealloc
{
	[_uploadQueue release];
	[_album release];
	[_delegate release];
	[_uploadedPhotoIds release];

	self.currentUploadRequest = nil;

	[super dealloc];
}

+ (UIImage *)getThumbImageForAssetURL:(NSURL *)imageUrl
{
	__block UIImage *retImage;
	//
	ALAssetsLibraryAssetForURLResultBlock resultblock = ^( ALAsset *myasset )
	{
		CGImageRef iref = [myasset thumbnail];
		if ( iref )
		{
			retImage = [UIImage imageWithCGImage:iref];
			[retImage retain];
		}
	};

	//
	ALAssetsLibraryAccessFailureBlock failureblock = ^( NSError *myerror )
	{
		NSLog( @"Ooops, cant get image - %@", [myerror localizedDescription] );
	};

	ALAssetsLibrary *assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
	[assetslibrary assetForURL:imageUrl
				   resultBlock:resultblock
				  failureBlock:failureblock];
	return retImage;
}

+ (UIImage *)getScreenImageForAssetURL:(NSURL *)imageUrl
{
	__block UIImage *retImage;
	//
	ALAssetsLibraryAssetForURLResultBlock resultblock = ^( ALAsset *myasset )
	{
		ALAssetRepresentation *rep = [myasset defaultRepresentation];
		CGImageRef iref = [rep fullScreenImage];
		if ( iref )
		{
			retImage = [UIImage imageWithCGImage:iref];
			[retImage retain];
		}
	};

	//
	ALAssetsLibraryAccessFailureBlock failureblock = ^( NSError *myerror )
	{
		NSLog( @"Ooops, cant get image - %@", [myerror localizedDescription] );
	};

	ALAssetsLibrary *assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
	[assetslibrary assetForURL:imageUrl
				   resultBlock:resultblock
				  failureBlock:failureblock];
	return retImage;
}

+ (UIImage *)getFullImageForAssetURL:(NSURL *)imageUrl
{
	__block UIImage *retImage;
	//
	ALAssetsLibraryAssetForURLResultBlock resultblock = ^( ALAsset *myasset )
	{
		ALAssetRepresentation *rep = [myasset defaultRepresentation];
		CGImageRef iref = [rep fullResolutionImage];
		if ( iref )
		{
			retImage = [UIImage imageWithCGImage:iref];
			[retImage retain];
		}
	};

	//
	ALAssetsLibraryAccessFailureBlock failureblock = ^( NSError *myerror )
	{
		NSLog( @"Ooops, cant get image - %@", [myerror localizedDescription] );
	};

	ALAssetsLibrary *assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
	[assetslibrary assetForURL:imageUrl
				   resultBlock:resultblock
				  failureBlock:failureblock];
	return retImage;
}

- (NSData *)getFullImageDataForAssetURL:(NSURL *)imageUrl
{
	__block NSData *retImageData;
	//
	ALAssetsLibraryAssetForURLResultBlock resultblock = ^( ALAsset *myasset )
	{
		ALAssetRepresentation *rep = [myasset defaultRepresentation];
		NSUInteger buffSize = [rep size];
		uint8_t *buff = (uint8_t *) malloc( sizeof(uint8_t) * buffSize );
		NSError *err = nil;
		[rep getBytes:buff fromOffset:0 length:buffSize error:&err];
		retImageData = [NSData dataWithBytesNoCopy:buff length:buffSize];
		[retImageData retain];
		NSLog( @"Image data retrieved from asset library" );
		[self performSelector:@selector(assetLibraryImageFetched:) withObject:retImageData];
	};

	//
	ALAssetsLibraryAccessFailureBlock failureblock = ^( NSError *myerror )
	{
		NSLog( @"Ooops, cant get image - %@", [myerror localizedDescription] );
	};

	ALAssetsLibrary *assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
	[assetslibrary assetForURL:imageUrl
				   resultBlock:resultblock
				  failureBlock:failureblock];
	return retImageData;
}

- (NSString *)extractPhotoIdFromResponse:(NSString *)response
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<id>(\\d+)</id>" options:0 error:&error];
	NSTextCheckingResult *result = [regex firstMatchInString:response options:0 range:NSMakeRange( 0, [response length] )];
	NSRange range = [result rangeAtIndex:1];

	return [response substringWithRange:range];
}


@end
