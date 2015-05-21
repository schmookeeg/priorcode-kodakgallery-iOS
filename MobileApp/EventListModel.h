//
//  EventListModel.h
//  MobileApp
//
//  Created by Darron Schall on 9/15/11.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AbstractModel.h"

@interface EventListModel : AbstractModel
{
	NSArray *_events;
}

@property ( nonatomic, retain ) NSArray *events;
@property ( nonatomic, retain ) NSNumber *unreadEventsCount;

- (void)fetchUsingDelegate:(id <RKObjectLoaderDelegate>)delegate clearBadgeCount:(BOOL)clear;

@end
