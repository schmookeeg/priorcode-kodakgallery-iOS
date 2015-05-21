//
//  UploadModel.h
//  MobileApp
//
//  Created by Jon Campbell on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AbstractModel.h"
#import "UploadModelDelegate.h"
#import "AbstractAlbumModel.h"

@interface UploadModel : NSObject <RKRequestDelegate, UploadModelDelegate>
{
	AbstractAlbumModel *_album;
	NSArray *_uploadQueue;
	NSMutableArray *_uploadedPhotoIds;
	int _currentQueueIndex;
	id <UploadModelDelegate> _delegate;
}

- (NSString *)extractPhotoIdFromResponse:(NSString *)response;

- (void)uploadImage;

- (void)uploadImageData:(NSData *)imageData;

- (void)uploadImageQueue:(NSArray *)images;

- (void)uploadImageQueue:(NSArray *)images album:(AbstractAlbumModel *)album;

- (void)uploadComplete;

- (void)uploadRearrangeCall;

- (void)cancelUploadQueue;

+ (UIImage *)getThumbImageForAssetURL:(NSURL *)imageUrl;

+ (UIImage *)getScreenImageForAssetURL:(NSURL *)imageUrl;

+ (UIImage *)getFullImageForAssetURL:(NSURL *)imageUrl;

- (NSData *)getFullImageDataForAssetURL:(NSURL *)imageUrl;

@property ( nonatomic, retain ) id <UploadModelDelegate> delegate;
@property ( nonatomic, retain ) AbstractAlbumModel *album;
@property ( nonatomic, retain ) NSArray *uploadQueue;
@property ( nonatomic, retain ) NSMutableArray *uploadedPhotoIds;

@end
