//
//  Created by jcampbell on 2/2/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ManagedWebViewController.h"
#import "SelectPhotosViewControllerDelegate.h"
#import "AnonymousSignInModalAlertView.h"

@interface CartManagedWebViewController : ManagedWebViewController <SelectPhotosViewControllerDelegate>
{

}

+(NSString*)printConfigPage;
+(NSString*)reviewPage;
+(NSString*)confirmationPage;
+(NSString*)emptyCartPage;

@property(nonatomic, retain) AnonymousSignInModalAlertView *signInAlertView;


@end