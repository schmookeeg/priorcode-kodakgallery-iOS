//
//  Created by jcampbell on 2/8/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AlbumListTableViewController.h"
#import "SelectPhotosViewControllerDelegate.h"

@interface SelectAlbumViewController : AlbumListTableViewController {

}

@property ( nonatomic, assign ) BOOL allowMultiplePhotoSelection;
@property ( nonatomic, assign ) id<SelectPhotosViewControllerDelegate> selectPhotosDelegate;

@end