//
//  PictureAnnotationsModel.h
//  MobileApp
//
//  Created by mikeb on 7/20/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>


@interface PictureAnnotationModel : NSObject
{
	NSNumber *_annotationId;
	NSString *_annotatorName;
	NSNumber *_annotatorId;
	NSDate *_timeStamp;
}

- (NSDate *)timeStamp;

- (void)setTimeStamp:(NSString *)dateString;

- (void)setTimeStampWithDate:(NSDate *)date;

- (NSString *)annotatorAvatarUrl;

- (NSString *)annotatorName;

- (void)setAnnotatorName:(NSString *)annotatorName;

- (BOOL)isAnonymous;

@property ( retain, nonatomic ) NSNumber *annotationId;
@property ( retain, nonatomic ) NSNumber *annotatorId;


@end
