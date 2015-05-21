//
//  GroupMemberModel.h
//  MobileApp
//
//  Created by Jon Campbell on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AbstractModel.h"

@interface GroupMemberModel : AbstractModel <RKRequestDelegate>
{
	NSString *_firstName;
	NSString *_email;
	NSString *_role;
	NSString *_status;
	NSString *_memberAvatarLink;
	NSString *_joinDate;
	NSNumber *_uploadCount;
}

- (BOOL)isAnonymous;

- (void)setFirstName:(NSString *)name;

- (NSString *)firstName;

@property ( nonatomic, retain ) NSString *email;
@property ( nonatomic, retain ) NSString *role;
@property ( nonatomic, retain ) NSString *status;
@property ( nonatomic, retain ) NSString *memberAvatarLink;
@property ( nonatomic, retain ) NSString *joinDate;
@property ( nonatomic, retain ) NSNumber *uploadCount;


@end
