//
//  UploadModelDelegate.h
//  MobileApp
//
//  Created by Jon Campbell on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@class UploadModel;

@protocol UploadModelDelegate <NSObject>

@optional
- (void)uploadFileStart:(UploadModel *)model uploadIndex:(NSInteger)uploadIndex;

- (void)uploadStatusUpdate:(UploadModel *)model uploadIndex:(NSInteger)uploadIndex totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

- (void)uploadFileComplete:(UploadModel *)model uploadIndex:(NSInteger)uploadIndex;

- (void)uploadAllComplete:(UploadModel *)model;

- (void)uploadFailure:(UploadModel *)model uploadIndex:(NSInteger)uploadIndex response:(RKResponse *)response error:(NSError *)error;

- (void)uploadStartFailure:(UploadModel *)model uploadIndex:(NSInteger)uploadIndex request:(RKRequest *)request error:(NSError *)error;

- (void)assetLibraryImageFetched:(NSData *)imageData;


@end
