//
//  SPMProjectTableItem.m
//  MobileApp
//
//  Created by Darron Schall on 2/28/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "SPMProjectTableItem.h"

@implementation SPMProjectTableItem

@synthesize project1 = _project1;
@synthesize project2 = _project2;

#pragma mark init / dealloc

+ itemWithProject1:(SPMProject *)project1 project2:(SPMProject *)project2
{
    SPMProjectTableItem* item = [[[self alloc] init] autorelease];
    item.project1 = project1;
    item.project2 = project2;
    return item;
}

- (id)init
{
    self = [super init];
    if ( self )
    {
        
    }
    return self;
}

- (void)dealloc
{
    [_project1 release];
    _project1 = nil;
    [_project2 release];
    _project2 = nil;
    
    [super dealloc];
}

@end
