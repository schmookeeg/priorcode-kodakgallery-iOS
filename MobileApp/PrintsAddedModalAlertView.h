//
//  Created by jcampbell on 2/7/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface PrintsAddedModalAlertView : UIViewController <UIAlertViewDelegate>
{
	UIAlertView *_alertView;
	NSString *_alertTitle;
	NSString *_alertMessage;
}

- (id)initWithPhotoCount:(int)photoCount;
- (void)show;

@property ( nonatomic, retain ) UIImageView *imageView;
@property ( nonatomic, retain ) UIAlertView *alertView;
@property ( nonatomic, retain ) NSString *alertTitle;
@property ( nonatomic, retain ) NSString *alertMessage;

@end
