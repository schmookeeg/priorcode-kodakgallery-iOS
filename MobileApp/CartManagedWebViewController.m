//
//  Created by jcampbell on 2/2/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Three20/Three20.h>
#import <RestKit/Support/NSDictionary+RKAdditions.h>
#import "CartManagedWebViewController.h"
#import "CartModel.h"
#import "StoreModel.h"
#import "SelectAlbumViewController.h"
#import "UserModel.h"
#import "AnonymousSignInModalAlertView.h"


@interface CartManagedWebViewController (Private)

- (void)handleCartUpdatedNotification:(NSNotification *)notification;

@end

@implementation CartManagedWebViewController

@synthesize signInAlertView = _signInAlertView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.urlToLoad = [CartManagedWebViewController printConfigPage];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCartUpdatedNotification:)
                                                 name:@"CartUpdated"
                                               object:nil];

    return self;
}

+ (NSString *)printConfigPage {
    return [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, @"/gallery/mobile/app/buyPrints/printConfig.html"];
}

+ (NSString *)reviewPage {
    return [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, @"/gallery/mobile/app/buyPrints/checkout.html"];
}

+ (NSString *)confirmationPage {
    return [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, @"/gallery/mobile/app/buyPrints/confirmation.html"];
}

+ (NSString *)emptyCartPage {
    return [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, @"/gallery/mobile/app/buyPrints/empty.html"];
}


- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedObject:(NSDictionary *)object fromWebView:(UIWebView *)webView {

    NSString *command = [object objectForKey:@"command"];
    NSString *value = [object objectForKey:@"value"];
    NSString *callback = [object objectForKey:@"callback"];
    NSString *qty = [object objectForKey:@"qty"];
    NSString *orderId = [object objectForKey:@"orderId"];

    if ([command isEqualToString:@"launchAlbumChooser"]) {
        self.suppressPageReload = YES;
        self.navigationItem.title = @"Prints";
        self.callbackAction = callback;

        SelectAlbumViewController *selectAlbumViewController = (SelectAlbumViewController *)[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://selectAlbum"] applyAnimated:YES]];
		selectAlbumViewController.selectPhotosDelegate = self;
    }
    else if ([command isEqualToString:@"launchLocationChooser"]) {
        self.suppressPageReload = YES;
        self.callbackAction = callback;
        [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://buyPrints/selectLocation"] applyAnimated:YES]];
    }
    else if ([command isEqualToString:@"getLocation"]) {
        NSDictionary *location = [[[CartModel cartModel] store] serializeToDictionary];
        if (location != nil) {
            [self sendObject:[NSDictionary dictionaryWithKeysAndObjects:
                    @"command", callback,
                    @"location", location,
                    nil]];
        }
    }
    else if ([command isEqualToString:@"getPhotos"]) {
        NSMutableArray *photos = [[CartModel cartModel] serializePhotosToDictionary];
		[[CartModel cartModel] clearLastAddedPhotos];
        [self sendObject:[NSDictionary dictionaryWithKeysAndObjects:
                @"command", callback,
                @"photos", photos,
                nil]];
    }
    else if ([command isEqualToString:@"getLastAddedPhotos"]) {
            NSMutableArray *photos = [[CartModel cartModel] serializeLastAddedPhotosToDictionary];
            [[CartModel cartModel] clearLastAddedPhotos];
            [self sendObject:[NSDictionary dictionaryWithKeysAndObjects:
                    @"command", callback,
                    @"photos", photos,
                    nil]];
        }
    else if ([command isEqualToString:@"removePhoto"]) {
        [[CartModel cartModel] removePhoto:value];
    }
    else if ([command isEqualToString:@"removeAllPhotos"]) {
        [[CartModel cartModel] clearCart];
    }
    else if ([command isEqualToString:@"emptyCart"]) {
        [[CartModel cartModel] clearCart];
    }
    else if ([command isEqualToString:@"confirmOrderComplete"]) {
        self.navigationItem.hidesBackButton = YES;
    }
    else if ([command isEqualToString:@"checkClearCart"]) {
        if ([[CartModel cartModel] clearWebCart]) {
            [self sendObject:[NSDictionary dictionaryWithKeysAndObjects:
                    @"command", callback,
                    nil]];
        }

        [[CartModel cartModel] setClearWebCart:NO];
    }
    else if ([command isEqualToString:@"emptyCartAndReturnToAlbums"])
    {
        [[CartModel cartModel] clearCart];
        
        // Back to the "Shop" landing page in the shop tab.
        [[self navigationController] popToRootViewControllerAnimated:NO];
        
        // Back to the albums tab
        [[TTNavigator navigator].visibleViewController.tabBarController setSelectedIndex:0];
	}
	else if ([command isEqualToString:@"trackPurchase"]) {
			[[AnalyticsModel sharedAnalyticsModel] trackPurchase:@"m:Prints:Cart:StorePickup:ConfirmOrder" 
														 orderId:orderId 
														quantity:qty 
														   price:value];
    } else {
        [super javascriptBridge:bridge receivedObject:object fromWebView:webView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    BOOL isLoggedIn = [[UserModel userModel] loggedIn];

    if (!isLoggedIn) {
        self.signInAlertView = [[[AnonymousSignInModalAlertView alloc] initWithTarget:self selector:@selector(signInAlertViewDidCancel)] autorelease];
        [self.signInAlertView setFeatureRequiresLoginMessage];
        [self.signInAlertView show];
    }
}

- (void)signInAlertViewDidCancel
{
    // Bring the user back to the shop tab
    [[TTNavigator navigator].visibleViewController.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_signInAlertView release];


    [super dealloc];
}

- (void)handleCartUpdatedNotification:(NSNotification *)notification
{
// The JS should control whether or not something is in the cart and, as a result,
// what page to display.  But, per PBB-2902, we need some code here to catch a
// problem where the cart erroneously goes to the empty page even if it is not empty.

// This was the old logic that didn't seem to work quite right...
//    BOOL itemsInCart = [self.navigationController.viewControllers containsObject:self];
    BOOL itemsInCart = [CartModel cartModel].photos.count > 0;
    
    if ( itemsInCart )
    {
        self.urlToLoad = [CartManagedWebViewController printConfigPage];
    }
    else
    {
        self.urlToLoad = [CartManagedWebViewController emptyCartPage];
    }
}

#pragma mark SelectPhotosViewControllerDelegate

- (void)selectPhotosDidSelectPhotos:(NSArray *)photos inAlbum:(AbstractAlbumModel *)album
{
	// User has selected photos, so add them to the cart...
	[[CartModel cartModel] addPhotos:photos];

	// ... and then get navigate back to the cart view (popping off the selection screens).
	[self.navigationController popToViewController:self animated:YES];
}


@end
