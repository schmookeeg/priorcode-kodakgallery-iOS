//
//  UserModel.h
//  MobileDemo
//
//  Created by Jon Campbell on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "UserModelDelegate.h"


@interface UserModel : NSObject <UserModelDelegate, RKRequestDelegate>
{
	NSString *_sybaseId;
	NSString *_email;
	NSString *_firstName;
	NSString *_jsessionId;
	NSArray *_cookiesToPersist;
	id <UserModelDelegate> _delegate;
}


+ (UserModel *)userModel;

+ (void)setCurrentUserModel:(UserModel *)userModel;

- (UserModel *)initWithAnonymousSession;

- (void)login:(NSString *)username  password:(NSString *)password delegate:(id <UserModelDelegate>)delegate;

- (void)create:(NSDictionary *)parameters delegate:(id <UserModelDelegate>)delegate;;
- (UserModel *)initWithSavedSessionOrAnonymousSession;

- (void)logout;

- (void)persistCookies;

- (void)sendForgotPasswordEmail:(NSString *)email;

// TOOD: put this elsewhere
+ (void)encodeString:(NSString **)parameter;

+ (BOOL)validateEmail:(NSString *)email;

- (void)setParametersFromCookies:(NSArray *)cookies;

- (NSString *)extractFirstNameFromLoginResponse:(NSString *)responseString;

- (NSString *)extractSybaseIdFromLoginResponse:(NSString *)responseString;

- (NSString *)extractSybaseIdFromXML:(NSString *)xml;

- (NSString *)extractErrorFromJoinResponse:(NSString *)responseString;


@property ( retain, nonatomic ) NSString *sybaseId;
@property ( retain, nonatomic ) NSString *email;
@property ( retain, nonatomic ) NSString *firstName;
@property ( retain, nonatomic ) NSString *jsessionId;
@property ( retain, nonatomic ) id <UserModelDelegate> delegate;
@property ( nonatomic ) BOOL loggedIn;

@end
