//
//  IncomingURLHandler.h
//  MobileApp
//
//  Created by Jon Campbell on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlbumModelDelegate.h"
#import "AlbumListModelDelegate.h"
#import "AbstractAlbumModel.h"
#import "AnonymousSignInModalAlertView.h"

@interface IncomingURLHandler : NSObject <AlbumModelDelegate, AlbumListModelDelegate>
{
	AbstractAlbumModel *_album;
	AnonymousSignInModalAlertView *_signInAlertView;
}

- (id)initWithURL:(NSURL *)url;

- (void)handleURL:(NSURL *)url;

@property ( nonatomic, retain ) AbstractAlbumModel *album;
@property ( nonatomic, retain ) AnonymousSignInModalAlertView *signInAlertView;

@end
