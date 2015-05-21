//
//  Created by darron on 3/22/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SinglePhotoViewController.h"
#import "SelectPhotosViewControllerDelegate.h"


@interface SelectSinglePhotoViewController : SinglePhotoViewController
{
	UIBarButtonItem *_rotateLeftBarButton;
}

@property ( nonatomic, assign ) id<SelectPhotosViewControllerDelegate> selectPhotosDelegate;

@end