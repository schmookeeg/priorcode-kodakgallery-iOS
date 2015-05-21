//
//  Created by jcampbell on 2/1/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

/**
 Implementors of this delegate should be the UIViewController that has album options
 */
@class AlbumShareActionSheetController;

@protocol  AlbumOptionsActionSheetControllerDelegate <NSObject>

/** The view in which to show the action sheet */
- (UIView *)view;
- (AlbumShareActionSheetController *)albumShareActionSheetController;
@optional

/** The navigation controller that we use to grab the view from to display an MBProgressHUD */
- (UINavigationController *)navigationController;

@end
