//
//  SPMProjectTableItem.h
//  MobileApp
//
//  Created by Darron Schall on 2/28/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "SPMProject.h"

@interface SPMProjectTableItem : TTTableLinkedItem

@property ( nonatomic, retain ) SPMProject *project1;
@property ( nonatomic, retain ) SPMProject *project2;

+ itemWithProject1:(SPMProject *)project1 project2:(SPMProject *)project2;

@end
