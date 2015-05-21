//
//  UserModelDelegate.h
//  MobileApp
//
//  Created by Jon Campbell on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserModel;

@protocol UserModelDelegate <NSObject>

@optional

- (void)didLoginSucceed:(UserModel *)model;

- (void)didLoginFail:(UserModel *)model error:(NSError *)error;

- (void)didRegisterSucceed:(UserModel *)model;

- (void)didRegisterFail:(UserModel *)model error:(NSError *)error;

- (void)didSendForgotPasswordEmailSucceed:(UserModel *)model;

- (void)didSendForgotPasswordEmailFail:(UserModel *)model error:(NSError *)error;


@end
