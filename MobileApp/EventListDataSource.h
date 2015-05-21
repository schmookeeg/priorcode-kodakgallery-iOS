//
//  EventListDataSource.h
//  MobileApp
//
//  Created by Darron Schall on 9/15/11.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "EventListModel.h"

@interface EventListDataSource : TTListDataSource <AbstractModelDelegate>
{
	BOOL _isLoaded;
	EventListModel *_eventList;

	NSMutableArray *_delegates;
}

@property ( nonatomic, retain ) EventListModel *eventList;

- (void)populateDataSourceFromModel;

- (NSDate *)loadedTime;

@end
