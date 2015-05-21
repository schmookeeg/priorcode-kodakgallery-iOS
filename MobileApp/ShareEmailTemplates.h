//
//  ShareEmailTemplates.h
//  MobileApp
//
//  Created by Bryan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareEmailTemplates : NSObject
{

}

+ (NSString *)shareGroupEmailTemplate:(NSString *)shareToken
						   albumTitle:(NSString *)albumTitle
							 thumbUrl:(NSString *)thumbUrl;

+ (NSString *)sharePersonalEmailTemplate:(NSString *)shareToken
							  albumTitle:(NSString *)albumTitle
								thumbUrl:(NSString *)thumbUrl;

+ (NSString *)shareSingleImageEmailTemplate:(NSString *)photoTitle
									  BGUrl:(NSString *)BGUrl;

@end
