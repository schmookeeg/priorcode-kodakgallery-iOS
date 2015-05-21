//
//  Created by jcampbell on 2/1/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class AbstractAlbumModel;
@protocol AlbumOptionsActionSheetControllerDelegate;
@protocol SelectPhotosViewControllerDelegate;
@class AnonymousSignInModalAlertView;


@interface AlbumOptionsActionSheetController : NSObject <UIActionSheetDelegate>
{
	AbstractAlbumModel *_album;
	id <AlbumOptionsActionSheetControllerDelegate, SelectPhotosViewControllerDelegate> _delegate;
}

@property ( nonatomic, retain ) AnonymousSignInModalAlertView *signInAlertView;

- (void)showOptions;

- (id)initWithDelegate:(id <AlbumOptionsActionSheetControllerDelegate, SelectPhotosViewControllerDelegate>)delegate  album:(AbstractAlbumModel *)album;

@end
