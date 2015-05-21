//
//  AnonymousSignInModalAlertView.h
//  MobileApp
//
//  Created by Jon Campbell on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractAlbumModel.h"

@interface AnonymousSignInModalAlertView : UIViewController <UIAlertViewDelegate>
{
	UIAlertView *_alertView;
	AbstractAlbumModel *_album;
	NSString *_alertTitle;
	NSString *_alertMessage;
    SEL cancelSelector;
    id target;
}

- (id)initWithAlbum:(AbstractAlbumModel *)album;
- (id)initWithTarget:(id)aTarget selector:(SEL)aSelector;

- (void)show;

- (void)setFeatureRequiresLoginMessage;


@property ( nonatomic, retain ) UIAlertView *alertView;
@property ( nonatomic, retain ) AbstractAlbumModel *album;
@property ( nonatomic, retain ) NSString *alertTitle;
@property ( nonatomic, retain ) NSString *alertMessage;
@property(nonatomic, assign) SEL cancelSelector;
@property(nonatomic, retain) id target;


@property(nonatomic, copy) NSString *cancelTitle;
@end
