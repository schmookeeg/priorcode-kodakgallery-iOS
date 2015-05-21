//
//  EventNavigationController.h
//  MobileApp
//
//  Created by Darron Schall on 9/19/11.
//

#import <Foundation/Foundation.h>
#import "EventModel.h"
#import "EventDetailAlbumModel.h"

@interface EventNavigationController : NSObject <AbstractModelDelegate>
{
	EventModel *_navigationEvent;
	EventDetailAlbumModel *_eventDetailAlbumModel;
}

- (void)navigateToEvent:(EventModel *)event;

- (void)navigateToNotification:(NSDictionary *)notification;

@end
