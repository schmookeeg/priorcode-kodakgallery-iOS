//
//  AnalyticsModel.m
//  MobileApp
//
//  Created by Jon Campbell on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Environment.h"
#import "UserModel.h"

static AnalyticsModel *sharedAnalyticsModel;

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;
static const NSString *kAnonymousUser = @"Anonymous: ";
static const NSString *kLoggedInUser = @"Logged_In: ";

@implementation AnalyticsModel

- (id)init
{
	self = [super init];
	if ( self )
	{
		s = [[AppMeasurement alloc] init];

		// Global configurations across all tracking calls
		s.account = kOmnitureAccountId;
		s.trackingServer = kOmnitureTrackingServer;
		s.prop3 = @"D=User-Agent";
		s.prop10 = @"iphone";		   // Application platform
		s.prop11 = kApplicationName;	// Application name
		s.eVar15 = @"D=c15";

#ifdef OMNITURE_DEBUG
        s.debugTracking = YES;
#endif
	}

	return self;
}

// Track a page view with the minimal data being sent to Omniture
- (void)trackPageview:(NSString *)pageName
{
	[self trackPageview:pageName mmcCode:nil sourceId:nil];
}

// Track a page view with an cm_mmc code and sourceId
- (void)trackPageview:(NSString *)pageName mmcCode:(NSString *)mmcCode sourceId:(NSString *)sourceId;
{
	if ( s != nil )
	{
		[self setCommonData:pageName];

		s.eVar34 = mmcCode;
		s.eVar26 = sourceId;
		if ( mmcCode != nil && sourceId != nil )
		{
			s.eVar11 = [NSString stringWithFormat:@"%@|%@", sourceId, mmcCode];
		}
		else
		{
			s.eVar11 = nil;
		}

		// Clear out previous events
		s.events = nil;
		[s track];
	}
}

// Track a page view for purchases with an orderId, Quantity, and Price
- (void)trackPurchase:(NSString *)pageName orderId:(NSString *)orderId quantity:(NSString *)quantity price:(NSString *)price;
{
	if ( s != nil )
	{
		[self setCommonData:pageName];
		s.purchaseID = orderId;
		s.events = @"purchase,event23,event24";
		s.products = [NSString stringWithFormat:@";instoreunit;;;event23=%@,;instorerev;;;event24=%@", quantity, price];
		[s track];
	}
}

// Track a page view for SPM purchases with an orderId, Quantity, and Price
- (void)trackSPMPurchase:(NSString *)pageName orderId:(NSString *)orderId quantity:(NSString *)quantity price:(NSString *)price;
{
	if ( s != nil )
	{
		[self setCommonData:pageName];
		s.purchaseID = orderId;
		s.events = @"purchase,event20,event21,event22,event23,event24,event25";
		s.products = [NSString stringWithFormat:@";;%@;,;shipping charges;;;event21=;shipping discount amount;;;event20=0,;net rev;;;event25=%@,;instoreunit;;;event23=,;instorerev;;;event24=0", quantity, price];
		[s track];
	}
}

// Increments the event counter. eventNamesList is a comma-separated list of events (e.g @"event11,event12,event15)
- (void)trackEvent:(NSString *)pageName eventName:(NSString *)eventNamesList
{
	if ( s != nil )
	{
		[self setCommonData:pageName];
		s.events = eventNamesList;
		[s track];
	}
}

// Adds the common user data required for each tracking call
- (void)setCommonData:(NSString *)pageName
{
	BOOL userLoggedIn = [[UserModel userModel] loggedIn];
	NSString *memberId = [[UserModel userModel] sybaseId];

	s.pageName = pageName;
	s.prop4 = pageName;

	// prop16 is prefixed with the logged in state of the user
	if ( userLoggedIn )
	{
		s.prop16 = [kLoggedInUser stringByAppendingString:pageName];
	}
	else
	{
		s.prop16 = [kAnonymousUser stringByAppendingString:pageName];
	}

	s.prop15 = memberId;
}

// Likely never called, but just in case this class isn't used as a singleton
- (void)dealloc
{
	[s release];
	[super dealloc];
}

+ (AnalyticsModel *)sharedAnalyticsModel
{
	if ( !sharedAnalyticsModel )
	{
		sharedAnalyticsModel = [[AnalyticsModel alloc] init];
	}

	return sharedAnalyticsModel;
}


@end
