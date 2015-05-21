//
//  ShareTokenList.h
//  MobileApp
//
//  Created by mikeb on 8/17/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ShareTokenList : NSObject
{
}

+ (NSString *)shareTokenFilePath;

+ (NSString *)tokenForAlbumId:(NSNumber *)albumId;

+ (NSMutableDictionary *)tokenList;

+ (void)addToken:(NSString *)token forAlbumId:(NSNumber *)albumId;

+ (void)clear;

@end
