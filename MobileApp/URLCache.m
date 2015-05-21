//
//  URLCache.m
//  KGDemo
//
//  Created by Dev on 5/24/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "URLCache.h"
#import <objc/message.h>

static const  CGFloat kMaxLargeImageSize = 640 * 640;
static URLCache *gSharedUrlCache = nil;

@implementation URLCache
///////////////////////////////////////////////////////////////////////////////////////////////////
//  Override base method to use larger kMaxLargeImageSize
//
- (void)storeImage:(UIImage *)image forURL:(NSString *)URL force:(BOOL)force
{
	if ( nil != image && ( force || !_disableImageCache ) )
	{
		CGFloat dimensions = image.size.width * image.size.height;
		NSUInteger pixelCount = [[NSNumber numberWithFloat:dimensions] unsignedIntegerValue];

		if ( force || pixelCount <= kMaxLargeImageSize )
		{
			UIImage *existingImage = [_imageCache objectForKey:URL];
			if ( nil != existingImage )
			{
				_totalPixelCount -= existingImage.size.width * existingImage.size.height;
				[_imageSortedList removeObject:URL];
			}
			_totalPixelCount += pixelCount;

			if ( _totalPixelCount > _maxPixelCount && _maxPixelCount )
			{
				if ( [self respondsToSelector:@selector(expireImagesFromMemory)] )
				{
					objc_msgSend( self, @selector(expireImagesFromMemory) );
				}
			}

			if ( nil == _imageCache )
			{
				_imageCache = [[NSMutableDictionary alloc] init];
			}

			if ( nil == _imageSortedList )
			{
				_imageSortedList = [[NSMutableArray alloc] init];
			}

			[_imageSortedList addObject:URL];
			[_imageCache setObject:image forKey:URL];
		}
		else
		{
			NSLog( @"Image size exceeded - width: %f  height: %f", image.size.width, image.size.height );
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTURLCache *)sharedCache
{
	if ( nil == gSharedUrlCache )
	{
		gSharedUrlCache = [[URLCache alloc] init];
	}
	return gSharedUrlCache;
}

@end
