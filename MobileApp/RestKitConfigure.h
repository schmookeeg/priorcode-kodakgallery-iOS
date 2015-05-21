//
//  RestKitConfigure.h
//  MobileApp
//
//  Created by Jon Campbell on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>


@interface RestKitConfigure : NSObject

+ (void)initializeMappings;
+ (void)initializeCartMappings:(RKObjectManager *)objectManager;

@end
