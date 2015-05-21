//
//  PushNotificationModel.h
//  MobileApp
//
//  Created by mikeb on 7/1/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface PushNotificationModel : NSObject
{
	NSNumber *_enabledTypes;
	NSString *_deviceToken;
}

+ (PushNotificationModel *)sharedModel;

@property ( nonatomic, retain ) NSNumber *enabledTypes;
@property ( nonatomic, retain ) NSString *deviceToken;

- (void)checkEnabledTypes;

- (void)checkDeviceTokenAndRegister;

- (void)registerForNotifications:(NSString *)memberId;

- (void)unRegisterForNotifications:(NSString *)memberId;

- (void)updateNotifications:(NSString *)memberId;

@end
