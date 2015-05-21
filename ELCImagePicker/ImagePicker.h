//
//  ImagePicker.h
//  ELCImagePickerDemo
//
//  Created by Dev on 5/10/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface ImagePicker : NSObject {
	NSMutableArray * assetURLs;	//List of recipients
}

-(IBAction)showPicker;
-(UIImage *)getThumbImageForAssetURL:(NSURL *)imageUrl;
-(UIImage *)getScreenImageForAssetURL:(NSURL *)imageUrl;
-(UIImage *)getFullImageForAssetURL:(NSURL *)imageUrl;


@end

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);
