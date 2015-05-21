//
//  ShareModel.h
//  MobileApp
//
//  Created by Darron Schall on 11/18/11.
//  Copyright (c) 2011 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ShareModel <NSObject>

- (NSString *)shareURL;

- (NSString *)shareSubjectText;

- (NSString *)shareDescriptionText;

- (NSString *)shareSMSText;

- (NSString *)shareEmailText;

@end
