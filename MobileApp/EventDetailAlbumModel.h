//
//  EventDetailAlbumModel.h
//  MobileApp
//
//  Created by Peter Traeg on 9/27/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AbstractModel.h"

/*
@class EventDetailAlbumModel;

@protocol EventDetailAlbumDelegate
@optional
	- (void)didLoadEventDetailAlbum:(EventDetailAlbumModel *)model; // Invoked when event album details are loaded
	- (void)didFailEventDetailAlbumWithError:(NSError *)error; // Invoked when event album details fail to load
@end
*/

@interface EventDetailAlbumModel : AbstractModel
{
}
@property ( retain, nonatomic ) NSNumber *albumId;
@property ( retain, nonatomic ) NSString *albumName;
//@property (nonatomic, assign) id <EventDetailAlbumDelegate> eventDetailAlbumDelegate;

- (void)fetchViaURL:(NSString *)eventURL;

@end

