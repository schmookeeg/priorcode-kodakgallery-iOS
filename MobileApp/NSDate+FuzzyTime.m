//
//  NSDate+FuzzyTime.m
//  MobileApp
//
//  Created by Jon Campbell on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDate+FuzzyTime.h"

NSTimeInterval const kTenSeconds = ( 10.0f );
NSTimeInterval const kOneMinute = ( 60.0f );
NSTimeInterval const kFiveMinutes = ( 5.0f * 60.0f );
NSTimeInterval const kFifteenMinutes = ( 15.0f * 60.0f );
NSTimeInterval const kHalfAnHour = ( 30.0f * 60.0f );
NSTimeInterval const kOneHour = 3600.0f;	// (60.0f * 60.0f);
NSTimeInterval const kThreeHours = 10800.0f;
NSTimeInterval const kHalfADay = ( 3600.0f * 12.0f );
NSTimeInterval const kOneDay = ( 3600.0f * 24.0f );
NSTimeInterval const kOneWeek = ( 3600.0f * 24.0f * 7.0f );

@implementation NSDate (FuzzyTime)

- (NSString *)fuzzyStringRelativeToNow;
{
	double timeFromNow = (double) [self timeIntervalSinceNow];
	timeFromNow = -timeFromNow;

	// let's not support negative numbers
	if ( timeFromNow < 0 )
	{
		timeFromNow = 0;
	}

	if ( timeFromNow < kOneMinute )
	{
		NSInteger time = [[NSNumber numberWithDouble:timeFromNow] integerValue];

		return [NSString stringWithFormat:@"%i second%@ ago", time, ( time != 1 ) ? @"s" : @""];
	}


	if ( timeFromNow < kOneHour )
	{
		NSInteger time = [[NSNumber numberWithDouble:( timeFromNow / kOneMinute )] integerValue];

		return [NSString stringWithFormat:@"%i minute%@ ago", time, ( time != 1 ) ? @"s" : @""];
	}

	if ( timeFromNow < kThreeHours )
	{
		NSInteger time = [[NSNumber numberWithDouble:( timeFromNow / kOneHour )] integerValue];

		return [NSString stringWithFormat:@"%i hour%@ ago", time, ( time >= 2 ) ? @"s" : @""];
	}

	NSDate *today = [NSDate date];
	NSCalendar *gregorian = [[[NSCalendar alloc]
			initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *todayComponents =
			[gregorian components:( NSDayCalendarUnit ) fromDate:today];

	NSDateComponents *dateComponents =
			[gregorian components:( NSDayCalendarUnit ) fromDate:self];

	if ( [todayComponents day] == [dateComponents day] )
	{
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];

		[dateFormatter setDateFormat:@"h:mma"];

		return [NSString stringWithFormat:@"Today, %@", [dateFormatter stringFromDate:self]];
	}

	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];

	[dateFormatter setDateFormat:@"MMM d, yyyy"];

	return [dateFormatter stringFromDate:self];

}
@end
