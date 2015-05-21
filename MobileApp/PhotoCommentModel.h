//
//  PhotoCommentModel.h
//  MobileApp
//
//  Created by mikeb on 6/22/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PhotoCommentModel : NSObject
{
	NSNumber *_commentId;
	NSNumber *_photoId;
	NSNumber *_authorId;
	NSString *_author;
	NSString *_email;
	NSDate *_lastUpdated;
	NSString *_text;
}

- (NSDate *)lastUpdated;

- (void)setLastUpdated:(NSString *)dateString;

- (NSString *)authorAvatarUrl;

@property ( retain, nonatomic ) NSNumber *commentId;
@property ( retain, nonatomic ) NSNumber *photoId;
@property ( retain, nonatomic ) NSNumber *authorId;
@property ( retain, nonatomic ) NSString *email;
@property ( retain, nonatomic ) NSString *text;

- (NSString *)author;

- (void)setAuthor:(NSString *)author;

- (BOOL)isAnonymous;

@end
