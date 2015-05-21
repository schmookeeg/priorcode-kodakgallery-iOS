//
//  Created by jcampbell on 1/31/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SelectThumbsTableViewCell.h"
#import "PhotoModel.h"


@implementation SelectThumbsTableViewCell

@synthesize delegate;

- (void)thumbTouched:(TTThumbView *)thumbView {
    NSUInteger thumbViewIndex = [_thumbViews indexOfObject:thumbView];
    NSInteger offsetIndex = _photo.index + thumbViewIndex;
    id <TTPhoto> photo = [_photo.photoSource photoAtIndex:offsetIndex];

    if ([self.delegate respondsToSelector:@selector(thumbsTableViewCell:didSelectPhoto:withThumbView:)]) {
        // invoke the inherited method
        [self.delegate thumbsTableViewCell:self didSelectPhoto:photo withThumbView:thumbView];
    } else {
        [self.delegate thumbsTableViewCell:self didSelectPhoto:photo];
    }
}

- (void)assignPhotoAtIndex:(int)photoIndex toView:(TTThumbView *)thumbView {
    PhotoModel *photo = (PhotoModel *) [_photo.photoSource photoAtIndex:photoIndex];
    if (photo) {
        thumbView.thumbURL = [photo URLForVersion:TTPhotoVersionThumbnail];
        thumbView.hidden = NO;

        if (photo.selected && thumbView.subviews.count == 0) {
            CGRect viewFrames = CGRectMake(0, 0, 75, 75);

            UIImageView *overlayView = [[[UIImageView alloc] initWithFrame:viewFrames] autorelease];
            [overlayView setImage:[UIImage imageNamed:@"Overlay.png"]];
            [overlayView setHidden:NO];

            [thumbView addSubview:overlayView];
        }
        else if (!photo.selected && thumbView.subviews.count > 0) {
            UIView *view = [thumbView.subviews objectAtIndex:0];
            [view removeFromSuperview];
        }


    } else {
        thumbView.thumbURL = nil;
        thumbView.hidden = YES;
    }
}

@end