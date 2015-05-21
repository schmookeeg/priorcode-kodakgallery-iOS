//
//  Created by jcampbell on 2/7/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "PhotoModel.h"
#import "AbstractAlbumModel.h"

@protocol SelectPhotosViewControllerDelegate <NSObject>

@optional

// photos is an array of (PhotoModel*)
- (void)selectPhotosDidSelectPhotos:(NSArray *)photos inAlbum:(AbstractAlbumModel*)album;
- (void)selectPhotosDidCancel;

@end