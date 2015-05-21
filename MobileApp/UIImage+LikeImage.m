//
//  Created by darron on 11/21/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIImage+LikeImage.h"
#import "AlbumAnnotationsModel.h"

@implementation UIImage (LikeImage)

+ (UIImage *)likeImageForPhoto:(NSString *)photoId
{
	if ( [AlbumAnnotationsModel userLikesPhoto:[NSNumber numberWithDouble:[photoId doubleValue]]] )
	{
		return [UIImage imageNamed:kAssetUnlikeIcon];
	}
	else
	{
		return [UIImage imageNamed:kAssetLikeIcon];
	}
}

@end