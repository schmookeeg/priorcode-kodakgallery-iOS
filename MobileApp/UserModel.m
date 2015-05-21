//
//  UserModel.m
//  MobileDemo
//
//  Created by Jon Campbell on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserModel.h"
#import "AlbumListModel.h"
#import "PushNotificationModel.h"

static UserModel *currentUserModel;

@implementation UserModel

@synthesize sybaseId = _sybaseId, email = _email, firstName = _firstName, jsessionId = _jsessionId;
@synthesize delegate = _delegate;
@synthesize loggedIn;

- (UserModel *)init
{
	self = [super init];

	// Did the superclass's initialization fail? 
	if ( !self )
	{
		return nil;
	}

	_cookiesToPersist = [[NSArray arrayWithObjects:@"EK_E", @"EK_S", @"DYN_EMAIL", @"sid", @"JSESSIONID", nil] retain];
	_sybaseId = nil;
	_email = nil;
	self.loggedIn = NO;

	return self;
}

- (UserModel *)initWithSavedSessionOrAnonymousSession
{
	self = [self init];

	// Did the superclass's initialization fail?
	if ( !self )
	{
		return nil;
	}

	BOOL session = NO;

	NSData *cookieData = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserCookies"];
	if ( [cookieData length] )
	{
		NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookieData];
		NSHTTPCookie *cookie;

		for ( cookie in cookies )
		{
			if ( [[cookie name] isEqualToString:@"sid"] )
			{
				[self setSybaseId:[cookie value]];
			}
			else if ( [[cookie name] isEqualToString:@"fn"] )
			{
				[self setFirstName:[cookie value]];
			}
			else if ( [[cookie name] isEqualToString:@"DYN_EMAIL"] )
			{
				[self setEmail:[cookie value]];
			}
			else if ( [[cookie name] isEqualToString:@"JSESSIONID"] )
			{
				[self setJsessionId:[cookie value]];
			}
			else if ( [[cookie name] isEqualToString:@"EK_E"] )
			{
				self.loggedIn = YES;
			}


			[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
		}

		session = YES;
	}
	if ( session )
	{
		[UserModel setCurrentUserModel:self];
		return self;
	}
	else
	{
		return [self initWithAnonymousSession];
	}
}

- (UserModel *)initWithAnonymousSession
{
	self = [self init];

	// Did the superclass's initialization fail?
	if ( !self )
	{
		return nil;
	}

	self.loggedIn = NO;

	NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kServiceCreateAnonymousAccount];

	RKRequest *authRequest = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];

	RKResponse *response = [authRequest sendSynchronously];

	if ( [response isOK] )
	{
		NSString *xml = [response bodyAsString];


		NSString *sybaseId;

		@try
		{
			sybaseId = [self extractSybaseIdFromXML:xml];

			[self setSybaseId:sybaseId];

			// get email cookie

			NSArray *cookies = [response cookies];

			[self setParametersFromCookies:cookies];
			[self persistCookies];
		}
		@catch ( NSException *ex )
		{

			[[[[UIAlertView alloc] initWithTitle:@"Server Error"
										 message:@"We were unable to create an Guest account. Please restart the application." delegate:self
							   cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];

			return nil;

		}
	}

	[UserModel setCurrentUserModel:self];
	return self;
}


- (void)login:(NSString *)username password:(NSString *)password delegate:(id <UserModelDelegate>)delegate
{
	self.loggedIn = NO;

	[self setDelegate:delegate];

	NSString *authCookie = [NSString stringWithFormat:@"{\"email\":\"%@\",\"password\":\"%@\"}", username, password];
	[UserModel encodeString:&authCookie];

	[self setEmail:username];

	NSString *url = [NSString stringWithFormat:@"/gallery/account/login.jsp?sourceId=%@&uid=%d", kSourceId, arc4random() % 100000000];
	// Force login over https
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitSecureUrl, url];
    
	RKRequest *authRequest = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];

	NSDictionary *headers = [NSMutableDictionary dictionary];

	// Add the custom ssoCookie for authentication and include all the other cookies in our header
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:kRestKitBaseUrl]];
	NSMutableString *cookieHeader = [NSMutableString stringWithFormat:@"ssoCookies=%@;", authCookie];
	for ( NSHTTPCookie *cookie in cookies )
	{
		[cookieHeader appendFormat:@"%@=%@;", [cookie name], [cookie value]];
	}

	[headers setValue:cookieHeader forKey:@"Cookie"];

	[authRequest setAdditionalHTTPHeaders:headers];
	[authRequest setUserData:@"loginRequest"];
	[authRequest send];
}

- (void)create:(NSDictionary *)parameters delegate:(id <UserModelDelegate>)delegate
{
	self.loggedIn = NO;

	[self setDelegate:delegate];

	NSString *email = [parameters objectForKey:@"email"];
	NSString *password = [parameters objectForKey:@"password"];
	NSString *passwordConfirm = [parameters objectForKey:@"passwordConfirm"];
	NSString *firstName = [[parameters objectForKey:@"firstName"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSString *emailNotification = [parameters objectForKey:@"emailNotification"];

	NSString *kodakService = @"true";

	[self setEmail:email];

	NSString *authCookie = [NSString stringWithFormat:@"{\"email\":\"%@\",\"password\":\"%@\",\"passwordConfirm\":\"%@\"}", email, password, passwordConfirm];

	[UserModel encodeString:&authCookie];

	NSString *url = [NSString stringWithFormat:@"/gallery/account/join.jsp?firstName=%@&emailNotification=%@&kodakService=%@&sourceId=%@&uid=%d", firstName, emailNotification, kodakService, kSourceId, arc4random() % 100000000];
	// Force login over https
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitSecureUrl, url];
    
	RKRequest *authRequest = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];

	NSDictionary *headers = [NSMutableDictionary dictionary];

	// Add the custom ssoCookie for authentication and include all the other cookies in our header
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:kRestKitBaseUrl]];
	NSMutableString *cookieHeader = [NSMutableString stringWithFormat:@"ssoCookies=%@;", authCookie];
	for ( NSHTTPCookie *cookie in cookies )
	{
		[cookieHeader appendFormat:@"%@=%@;", [cookie name], [cookie value]];
	}

	[headers setValue:cookieHeader forKey:@"Cookie"];

	[authRequest setAdditionalHTTPHeaders:headers];

	[authRequest setUserData:@"registerRequest"];
	[authRequest send];
}


- (void)logout
{

	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookieStorage cookies];
	for ( NSHTTPCookie *cookie in cookies )
	{
		[cookieStorage deleteCookie:cookie];
	}

	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserCookies"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[[PushNotificationModel sharedModel] unRegisterForNotifications:self.sybaseId];

	self.loggedIn = NO;

	self.sybaseId = nil;
	self.firstName = nil;
	self.email = nil;
	self.jsessionId = nil;

	[[AlbumListModel albumList] setPopulated:NO];

	[self initWithAnonymousSession];
}

- (void)persistCookies
{
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSHTTPCookie *newCookie = nil;
	NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:kRestKitBaseUrl]];
	NSMutableArray *array = [NSMutableArray array];
	for ( NSHTTPCookie *cookie in cookies )
	{
		if ( [_cookiesToPersist containsObject:[cookie name]] )
		{
			NSMutableDictionary *props = [NSMutableDictionary dictionary];
			[props setValue:kCookieBaseUrl forKey:NSHTTPCookieDomain];
			[props setValue:[cookie value] forKey:NSHTTPCookieValue];
			[props setValue:[cookie name] forKey:NSHTTPCookieName];
			[props setValue:[cookie path] forKey:NSHTTPCookiePath];

			newCookie = [NSHTTPCookie cookieWithProperties:props];
			[array insertObject:newCookie atIndex:[array count]];
		}
	}

	NSMutableDictionary *props = [NSMutableDictionary dictionary];

	if ( [self firstName] != nil && newCookie != nil )
	{
		[props setValue:kCookieBaseUrl forKey:NSHTTPCookieDomain];
		[props setValue:[self firstName] forKey:NSHTTPCookieValue];
		[props setValue:@"fn" forKey:NSHTTPCookieName];
		[props setValue:[newCookie path] forKey:NSHTTPCookiePath];

		newCookie = [NSHTTPCookie cookieWithProperties:props];

		[array insertObject:newCookie atIndex:[array count]];
	}

	props = [NSMutableDictionary dictionary];

	if ( [self sybaseId] != nil && newCookie != nil )
	{
		[props setValue:kCookieBaseUrl forKey:NSHTTPCookieDomain];
		[props setValue:[self sybaseId] forKey:NSHTTPCookieValue];
		[props setValue:@"sid" forKey:NSHTTPCookieName];
		[props setValue:[newCookie path] forKey:NSHTTPCookiePath];
		newCookie = [NSHTTPCookie cookieWithProperties:props];

		[array insertObject:newCookie atIndex:[array count]];
	}

	for ( NSHTTPCookie *cookie in array )
	{
		[cookieStorage setCookie:cookie];
	}

	NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:array];


	[[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"UserCookies"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	NSError *error = nil;

	if ( [[request userData] isEqualToString:@"loginRequest"] )
	{
		if ( [response isOK] )
		{
			NSString *responseString = [response bodyAsString];

			// see if it's invalid
			if ( [responseString rangeOfString:@"invalidCredentials"].location != NSNotFound )
			{
				NSDictionary *details = [NSDictionary dictionaryWithKeysAndObjects:
						NSLocalizedDescriptionKey, @"invalidCredentials",
						@"email", [self email],
						nil];
				error = [NSError errorWithDomain:@"login" code:001 userInfo:details];
			}
			else if ( [responseString rangeOfString:@"callSignInFailure"].location != NSNotFound )
			{
				NSDictionary *details = [NSDictionary dictionaryWithKeysAndObjects:
						NSLocalizedDescriptionKey, @"callSignInFailure",
						@"email", [self email],
						nil];

				error = [NSError errorWithDomain:@"login" code:002 userInfo:details];
			}
			else
			{
				[self setParametersFromCookies:[response cookies]];
				[self setFirstName:[self extractFirstNameFromLoginResponse:responseString]];
				[self setSybaseId:[self extractSybaseIdFromLoginResponse:responseString]];
				self.loggedIn = YES;
				[self persistCookies];

				// Register for remote notifications for the user
				[[PushNotificationModel sharedModel] registerForNotifications:[self sybaseId]];
			}
		}
		else
		{
			error = [response failureError];
		}

		if ( error )
		{
			if ( [_delegate respondsToSelector:@selector(didLoginFail:error:)] )
			{
				[_delegate didLoginFail:self error:error];
			}
		}
		else
		{
			if ( [_delegate respondsToSelector:@selector(didLoginSucceed:)] )
			{
				[_delegate didLoginSucceed:self];
			}

		}
	}
	else if ( [[request userData] isEqualToString:@"registerRequest"] )
	{
		if ( [response isOK] )
		{
			NSString *responseString = [response bodyAsString];

			// see if it's invalid
			if ( [responseString rangeOfString:@"callJoinFailure"].location != NSNotFound )
			{
				NSString *errorMessage = [self extractErrorFromJoinResponse:responseString];
				NSDictionary *details = [NSDictionary dictionaryWithKeysAndObjects:
						NSLocalizedDescriptionKey, @"callJoinFailure",
						@"message", errorMessage,
						nil];
				error = [NSError errorWithDomain:@"register" code:( errorMessage ) ? 2 : 1 userInfo:details];
			}
			else
			{
				[self setParametersFromCookies:[response cookies]];
				[self setFirstName:[self extractFirstNameFromLoginResponse:responseString]];
				[self setSybaseId:[self extractSybaseIdFromLoginResponse:responseString]];
				self.loggedIn = YES;
				[self persistCookies];
				[[PushNotificationModel sharedModel] registerForNotifications:[self sybaseId]];
			}
		}
		else
		{
			error = [response failureError];
		}

		if ( error )
		{
			if ( [_delegate respondsToSelector:@selector(didRegisterFail:error:)] )
			{
				[_delegate didRegisterFail:self error:error];
			}
		}
		else
		{
			if ( [_delegate respondsToSelector:@selector(didRegisterSucceed:)] )
			{
				[_delegate didRegisterSucceed:self];
			}
		}
	}
	else if ( [[request userData] isEqualToString:@"forgotPasswordRequest"] )
	{
		if ( [response isOK] )
		{
			if ( [_delegate respondsToSelector:@selector(didSendForgotPasswordEmailSucceed:)] )
			{
				[_delegate didSendForgotPasswordEmailSucceed:self];
			}
		}
		else
		{
			error = [response failureError];
			if ( [_delegate respondsToSelector:@selector(didSendForgotPasswordEmailFail:error:)] )
			{
				[_delegate didSendForgotPasswordEmailFail:self error:error];
			}
		}
	}

}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
	if ( [[request userData] isEqualToString:@"loginRequest"] )
	{
		if ( [_delegate respondsToSelector:@selector(didLoginFail:error:)] )
		{
			[_delegate didLoginFail:self error:error];
		}
	}

	else if ( [[request userData] isEqualToString:@"registerRequest"] )
	{
		if ( [_delegate respondsToSelector:@selector(didRegisterFail:error:)] )
		{
			[_delegate didRegisterFail:self error:error];
		}
	}
	else if ( [[request userData] isEqualToString:@"forgotPasswordRequest"] )
	{
		if ( [_delegate respondsToSelector:@selector(didSendForgotPasswordEmailFail:error:)] )
		{
			[_delegate didSendForgotPasswordEmailFail:self error:error];
		}
	}

}

- (void)setParametersFromCookies:(NSArray *)cookies
{
	for ( NSHTTPCookie *cookie in cookies )
	{
		NSString *name = [cookie name];
		NSString *value = [cookie value];
		if ( [name isEqualToString:@"DYN_EMAIL"] )
		{
			[self setEmail:value];
			if ( [self.email rangeOfString:@"anon_mem"].location != NSNotFound )
			{
				[self setFirstName:value];
			}
		}
		else if ( [name isEqualToString:@"JSESSIONID"] )
		{
			[self setJsessionId:value];
		}
	}
}

- (NSString *)extractErrorFromJoinResponse:(NSString *)responseString
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"error:\"(.+)\""
																		   options:0 error:&error];

	NSTextCheckingResult *result = [regex firstMatchInString:responseString options:0 range:NSMakeRange( 0, [responseString length] )];

	if ( [result numberOfRanges] == 0 )
	{
		return @"Unknown join error";
	}

	NSRange range = [result rangeAtIndex:1];

	NSString *errorStr = [responseString substringWithRange:range];
	return errorStr;
}

- (NSString *)extractFirstNameFromLoginResponse:(NSString *)responseString
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"esg\\.ident\\.model\\.firstName\\s=\\s\"(.+)\";"
																		   options:0 error:&error];

	NSTextCheckingResult *result = [regex firstMatchInString:responseString options:0 range:NSMakeRange( 0, [responseString length] )];
	NSRange range = [result rangeAtIndex:1];

	NSString *firstName = [responseString substringWithRange:range];
	return firstName;
}

- (NSString *)extractSybaseIdFromLoginResponse:(NSString *)responseString
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"esg\\.ident\\.model\\.ssId\\s=\\s'(.+)';"
																		   options:0 error:&error];

	NSTextCheckingResult *result = [regex firstMatchInString:responseString options:0 range:NSMakeRange( 0, [responseString length] )];
	NSRange range = [result rangeAtIndex:1];

	NSString *sybaseId = [responseString substringWithRange:range];
	return sybaseId;
}

- (NSString *)extractSybaseIdFromXML:(NSString *)xml
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<sybaseId>(\\d+)</sybaseId>"
																		   options:0 error:&error];

	NSTextCheckingResult *result = [regex firstMatchInString:xml options:0 range:NSMakeRange( 0, [xml length] )];
	NSRange range = [result rangeAtIndex:1];


	NSString *sybaseId = [xml substringWithRange:range];
	return sybaseId;
}


+ (NSDictionary *)elementToPropertyMappings
{
	return [NSDictionary dictionaryWithKeysAndObjects:

			nil];
}


+ (NSDictionary *)elementToRelationshipMappings
{
	return [NSDictionary dictionaryWithKeysAndObjects:

			nil];
}


+ (NSString *)primaryKeyProperty
{
	return @"sybaseId";
}

+ (void)encodeString:(NSString **)parameter
{
	*parameter = (NSString *) CFURLCreateStringByAddingPercentEscapes(
			NULL,
			(CFStringRef) *parameter,
			NULL,
			(CFStringRef) @"!*'\"();:@&=+$,/?%#[]%",
			kCFStringEncodingUTF8 );
	[*parameter autorelease];
}


- (void)dealloc
{
	[_sybaseId release];
	[_email release];
	[_firstName release];
	[_jsessionId release];
	[_cookiesToPersist release];
	[_delegate release];

	[super dealloc];
}

+ (UserModel *)userModel
{
	if ( !currentUserModel )
	{
		currentUserModel = [[UserModel alloc] initWithAnonymousSession];
	}

	return currentUserModel;
}

+ (void)setCurrentUserModel:(UserModel *)userModel
{
	if ( currentUserModel != userModel )
	{
		[currentUserModel release];
		currentUserModel = userModel;
		[currentUserModel retain];
	}
}

+ (BOOL)validateEmail:(NSString *)email
{
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

	return [emailTest evaluateWithObject:email];
}

- (void)sendForgotPasswordEmail:(NSString *)email
{
	RKParams *params = [RKParams params];

	[params setValue:email forParam:@"profileEmail"];
	[params setValue:@"_dyncharset" forParam:@"ISO-8859-1"];
	[params setValue:@"" forParam:@"_D:profileEmail"];
	[params setValue:@"Continue" forParam:@"/kodak/userprofiling/ProfileFormHandler.forgotPassword"];
	[params setValue:@"" forParam:@"_D:/kodak/userprofiling/ProfileFormHandler.forgotPassword"];
	[params setValue:@"ProfileFormHandler.forgotPasswordSuccessURL.A" forParam:@"/kodak/userprofiling/ProfileFormHandler.forgotPasswordSuccessURL"];
	[params setValue:@"" forParam:@"_D:/kodak/userprofiling/ProfileFormHandler.forgotPasswordSuccessURL"];
	[params setValue:@"ProfileFormHandler.forgotPasswordErrorURL.A" forParam:@"/kodak/userprofiling/ProfileFormHandler.forgotPasswordErrorURL"];
	[params setValue:@"" forParam:@"_D:/kodak/userprofiling/ProfileFormHandler.forgotPasswordErrorURL"];
	[params setValue:@"" forParam:@"/kodak/userprofiling/ProfileFormHandler.forgotPasswordSybaseId"];
	[params setValue:@"" forParam:@"_D:/kodak/userprofiling/ProfileFormHandler.forgotPasswordSybaseId"];
	[params setValue:@"" forParam:@"/kodak/userprofiling/ProfileFormHandler.forgotPasswordProjectId"];
	[params setValue:@"" forParam:@"_D:/kodak/userprofiling/ProfileFormHandler.forgotPasswordProjectId"];
	[params setValue:@"/gallery/ma_reset_password.jsp" forParam:@"_DARGS"];

	NSString *urlString = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kServiceForgetPassword];

	RKRequest *passRequest = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];

	[passRequest setMethod:RKRequestMethodPOST];
	[passRequest setParams:params];
	[passRequest setUserData:@"forgotPasswordRequest"];
	[passRequest send];
}

@end


