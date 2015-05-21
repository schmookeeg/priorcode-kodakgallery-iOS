//
//  AnalyticsModel.h
//  MobileApp
//
//  Created by Jon Campbell on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMeasurement.h"

@interface AnalyticsModel : NSObject
{
	// Normally 's' is a bad name, but it is the Omniture convention
	AppMeasurement *s;
}

+ (AnalyticsModel *)sharedAnalyticsModel;

- (void)trackPageview:(NSString *)pageName;

- (void)trackPageview:(NSString *)pageName mmcCode:(NSString *)mmcCode sourceId:(NSString *)sourceId;

- (void)trackPurchase:(NSString *)pageName orderId:(NSString *)orderId quantity:(NSString *)quantity price:(NSString *)price;

- (void)trackSPMPurchase:(NSString *)pageName orderId:(NSString *)orderId quantity:(NSString *)quantity price:(NSString *)price;

- (void)trackEvent:(NSString *)pageName eventName:(NSString *)eventName;

- (void)setCommonData:(NSString *)pageName;

@end
