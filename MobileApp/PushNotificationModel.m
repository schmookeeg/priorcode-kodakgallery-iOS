//
//  PushNotificationModel.m
//  MobileApp
//
//  Created by Peter Traeg on 7/1/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "PushNotificationModel.h"
#import "UserModel.h"
#import "SettingsModel.h"
#import "MobileAppAppDelegate.h"

NSString *const kDomainTokenKey = @"deviceNotificationToken";
NSString *const kDomainDeviceTypesKey = @"deviceEnabledTypes";

@implementation PushNotificationModel

@synthesize enabledTypes = _enabledTypes;
@synthesize deviceToken = _deviceToken;


+ (PushNotificationModel *)sharedModel
{
	static dispatch_once_t once;
	static PushNotificationModel *instance = nil;
	dispatch_once( &once, ^
	{
		instance = [[self alloc] init];
	} );
	return instance;
}

- (id)init
{
	self = [super init];
	if ( self )
	{

	}
	return self;
}

- (void)setDeviceToken:(NSString *)deviceToken
{
	// This will typically be called when the Apple remote notification registration service responds via didRegisterForRemoteNotificationsWithDeviceToken
	[deviceToken retain];
	[_deviceToken release];
	_deviceToken = deviceToken;
	[[NSUserDefaults standardUserDefaults] setObject:_deviceToken forKey:kDomainTokenKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setEnabledTypes:(NSNumber *)enabledTypes
{
	[enabledTypes retain];
	[_enabledTypes release];
	_enabledTypes = enabledTypes;
	[[NSUserDefaults standardUserDefaults] setObject:_enabledTypes forKey:kDomainDeviceTypesKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkDeviceTokenAndRegister
{
	NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:kDomainTokenKey];
	if ( savedToken == nil )
	{
		// Set the default notification types
		UIRemoteNotificationType enabledTypes = ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert );
		[self setEnabledTypes:[NSNumber numberWithInt:enabledTypes]];

		// Call Apple to get one a device token for notifications because we don't have one.
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:enabledTypes];

	}
	else
	{
		[self setDeviceToken:savedToken];
	}
}

- (void)checkEnabledTypes
{
	// set enabled types
	NSNumber *enabledTypes = [NSNumber numberWithInteger:[[[NSUserDefaults standardUserDefaults] stringForKey:kDomainDeviceTypesKey] integerValue]];

	if ( enabledTypes == nil )
	{
		enabledTypes = [NSNumber numberWithInt:[[UIApplication sharedApplication] enabledRemoteNotificationTypes]];
	}

	[self setEnabledTypes:enabledTypes];
}

- (void)registerForNotifications:(NSString *)memberId
{
	if ( _deviceToken == nil || _enabledTypes == nil || ![[UserModel userModel] loggedIn] )
	{
		return;
	}

	NSLog( @"Attempting to register device token: %@  for types: %@", _deviceToken, _enabledTypes );

	NSString *url = [NSString stringWithFormat:@"/site/rest/v1.0/mobile/register/apns/user/%@?alt=json", memberId];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, url];

	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];

	[request setMethod:RKRequestMethodPOST];

	SettingsModel *settings = [SettingsModel settings];

	int enabledNotifications = [settings notificationBitMask];

	NSString *postBody = [NSString stringWithFormat:@"{\"Register\": {\"personId\": %@, \"registrationId\" : \"%@\", \"platform\" : \"iOS\", \"platformVersion\" : \"%@\",  \"appName\" : \"%@\", \"appVersion\" : \"%@\", \"flags\" : %@, \"prefs\": %d } }",
													memberId, _deviceToken, [[UIDevice currentDevice] systemVersion], kApplicationName, [MobileAppAppDelegate applicationVersion], _enabledTypes, enabledNotifications];

	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"application/json" forKey:@"Content-Type"];
	[request setAdditionalHTTPHeaders:headers];

	NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
	[request.URLRequest setHTTPBody:data];
	[request setUserData:@"registerDevice"];

	[request send];
}



// Call the service to delete the device token for this user 
- (void)unRegisterForNotifications:(NSString *)memberId
{
	if ( _deviceToken == nil || ![[UserModel userModel] loggedIn] )
	{
		return;
	}

	NSLog( @"Attempting to unregister device token: %@ for user: %@", _deviceToken, memberId );

	NSString *url = [NSString stringWithFormat:@"/site/rest/v1.0/mobile/register/apns/user/%@/%@?alt=json", memberId, _deviceToken];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, url];

	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];

	[request setMethod:RKRequestMethodDELETE];

	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"application/json" forKey:@"Content-Type"];
	[request setAdditionalHTTPHeaders:headers];

	[request setUserData:@"unRegisterDevice"];

	[request send];
}

- (void)updateNotifications:(NSString *)memberId
{
	if ( _deviceToken == nil || _enabledTypes == nil || ![[UserModel userModel] loggedIn] )
	{
		return;
	}

	NSLog( @"Attempting to update push notification registration for device token: %@  for types: %@", _deviceToken, _enabledTypes );

	NSString *url = [NSString stringWithFormat:@"/site/rest/v1.0/mobile/register/apns/user/%@?alt=json", memberId];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, url];

	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];

	[request setMethod:RKRequestMethodPUT];

	SettingsModel *settings = [SettingsModel settings];

	int enabledNotifications = [settings notificationBitMask];

	NSString *postBody = [NSString stringWithFormat:@"{\"Register\": {\"personId\": %@, \"registrationId\" : \"%@\", \"platform\" : \"iOS\", \"platformVersion\" : \"%@\",  \"appName\" : \"%@\", \"appVersion\" : \"%@\", \"flags\" : %@, \"prefs\": %d } }",
													memberId, _deviceToken, [[UIDevice currentDevice] systemVersion], kApplicationName, [MobileAppAppDelegate applicationVersion], _enabledTypes, enabledNotifications];

	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"application/json" forKey:@"Content-Type"];
	[request setAdditionalHTTPHeaders:headers];

	NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
	[request.URLRequest setHTTPBody:data];
	[request setUserData:@"updateNotifications"];

	[request send];
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_enabledTypes)
	TT_RELEASE_SAFELY(_deviceToken)

	[super dealloc];
}

@end
