//
//  EventModel.h
//  MobileApp
//
//  Created by Darron Schall on 9/15/11.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AbstractModel.h"

@interface EventModel : NSObject <RKRequestDelegate>
{
	NSDate *_time;
}

@property ( retain, nonatomic ) NSNumber *eventId;
@property ( retain, nonatomic ) NSString *eventLink;

@property ( retain, nonatomic ) NSString *subjectType;
@property ( retain, nonatomic ) NSNumber *subjectId;
@property ( retain, nonatomic ) NSString *subjectName;
@property ( retain, nonatomic ) NSString *subjectIcon;

@property ( retain, nonatomic ) NSString *objectType;
@property ( retain, nonatomic ) NSNumber *objectId;
@property ( retain, nonatomic ) NSString *objectName;
@property ( retain, nonatomic ) NSString *objectIcon;
@property ( retain, nonatomic ) NSNumber *objectOwnerId;
@property ( retain, nonatomic ) NSString *objectOwnerName;

@property ( retain, nonatomic ) NSString *predicateType;

@property ( retain, nonatomic ) NSNumber *albumIdHint;

@property ( retain, nonatomic ) NSNumber *publisherId;

/**
 Returns a friendly description that describes the event, for
 example: Darron commented on your photo.
 */
- (NSString *)friendlyDescription;

/*
Checks for anon in the subject name and returns Guest instead.
 */
- (NSString *)sanitizedSubjectName;
- (NSString *)checkForGuest:(NSString *)name;

- (NSString *)displayImage;

// FIXME Better API here is -(void)setTime:(NSDate *)date so that time is a property that
// we can just synthesize and then create a separate -(void)setTimeFromDateString:(NSString *)dateString
// helper method.
- (NSDate *)time;

- (void)setTimeFromDate:(NSDate *)date;

- (void)setTime:(NSString *)dateString;

@end