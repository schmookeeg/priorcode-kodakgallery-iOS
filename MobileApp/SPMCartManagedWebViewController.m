//
//  Created by darron on 3/22/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SPMCartManagedWebViewController.h"
#import <Three20/Three20.h>

@implementation SPMCartManagedWebViewController

@synthesize project = _project;

+ (NSString *)cartPage
{
    NSString *url = [kRestKitSecureUrl stringByAppendingString:@"/gallery/mobile/app/spm/cart.jsp"];
    return url;
}

#pragma mark init / dealloc

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
	self = [super initWithNibName:nil bundle:nil];
	if ( self )
	{
		self.project = [query objectForKey:@"project"];
	}
    
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		self.urlToLoad = [SPMCartManagedWebViewController cartPage];

	}
	return self;
}

- (void)dealloc
{
    [_project release];
    _project = nil;
	[super dealloc];
}

#pragma mark View Lifecucle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(leftBarButtonAction:)] autorelease];
    
    // Create the banner at the top of the view
    UIImageView *shopTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shopTop.png"]];
	[self.view addSubview:shopTop];
	[shopTop release];
    
    // Shift the web view down to make room for the banner at the top
	CGRect webViewFrame = _webView.frame;
	webViewFrame.origin.y += shopTop.frame.size.height;
	webViewFrame.size.height -= shopTop.frame.size.height;
	_webView.frame = webViewFrame;
    
    self.urlToLoad = [SPMCartManagedWebViewController cartPage];
    
    self.navigationItem.title = @"Cart";
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Place Order" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [rightBarButtonItem release];
}

#pragma mark Cart page locations

#pragma mark JavaScript Bridge

- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedObject:(NSDictionary *)object fromWebView:(UIWebView *)webView
{
	NSString *command = [object objectForKey:@"command"];
	NSObject *value = [object objectForKey:@"value"];

    NSLog(@"MyJavascriptBridgeDelegate received message: %@", command);
    
    if ([command isEqualToString:@"showPlaceOrderBtn"] ) {
        self.navigationItem.title = @"Cart";
        self.navigationItem.rightBarButtonItem.title = @"Place Order";
	}
	if ([command isEqualToString:@"enableRightButton"] ) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.hud hide:YES];
	}
    else if ([command isEqualToString:@"disableRightButton"] ) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
	}
    else if ([command isEqualToString:@"showHUD"]) {
        self.hud.labelText = @"Loading..";
        [self.hud show:YES];
    }
    else if ([command isEqualToString:@"hideHUD"]) {
        [self.hud hide:YES];
    }
    else if([command isEqualToString:@"placeOrderComplete"]) {
        self.navigationItem.title = @"Order Complete";
        self.navigationItem.leftBarButtonItem = NULL;
        self.navigationItem.rightBarButtonItem.title = @"Shop More";
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if([command isEqualToString:@"showAddressList"]) {
        self.navigationItem.title = @"Addresses";
        self.navigationItem.rightBarButtonItem.title = @"Done";
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if([command isEqualToString:@"showAddressForm"]) {
        self.navigationItem.title = @"New Address";
        self.navigationItem.rightBarButtonItem.title = @"Add";
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if([command isEqualToString:@"showCreditCards"]) {
        self.navigationItem.title = @"Credit Cards";
        self.navigationItem.rightBarButtonItem.title = @"Done";
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if([command isEqualToString:@"showCreditCardForm"]) {
        self.navigationItem.title = @"New Credit Card";
        self.navigationItem.rightBarButtonItem.title = @"Add";
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if([command isEqualToString:@"trackPageview"]) {
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:(NSString *)value];
    }
    else if([command isEqualToString:@"trackPurchase"]) {
        NSDictionary *valueDic = (NSDictionary *) value;
        NSString *qty = [valueDic objectForKey:@"qty"];
        NSString *orderId = [valueDic objectForKey:@"orderId"];
        NSString *amount = [valueDic objectForKey:@"value"];

        [[AnalyticsModel sharedAnalyticsModel] trackSPMPurchase:@"m:Cart:ConfirmOrder" orderId:orderId quantity:qty price:amount];
    }
}

- (void)rightBarButtonAction:(id)sender
{
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Place Order"]) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"placeOrderClicked" forKey:@"command"]];
        if (self.project) {
            // Let's clear the project id once we have placed the order
            self.project.projectId = nil;
            self.project.projectXml = nil;
        }
    }
    else if([self.navigationItem.title isEqualToString:@"Addresses"]) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"goToCart" forKey:@"command"]];
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Addresses:Done"];
    }
    else if([self.navigationItem.title isEqualToString:@"New Address"]) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"addAddressClicked" forKey:@"command"]];
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:NewAddress:Add"];
    }
    else if([self.navigationItem.title isEqualToString:@"Credit Cards"]) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"goToCart" forKey:@"command"]];
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:CreditCards:Done"];
    }
    else if([self.navigationItem.title isEqualToString:@"New Credit Card"]) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"addCreditCardClicked" forKey:@"command"]];
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:NewCreditCard:Add"];
    }
    else if([self.navigationItem.title isEqualToString:@"Order Complete"]) {
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Thankyou:Shop More"];
        
        [self dismissModalViewControllerAnimated:YES];
        
        [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://shop"] applyAnimated:YES]];
    }
}

- (void)leftBarButtonAction:(id)sender
{
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Place Order"]) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else if([self.navigationItem.title isEqualToString:@"Addresses"]) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"goToCart" forKey:@"command"]];
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Addresses:Cancel"];
    }
    else if([self.navigationItem.title isEqualToString:@"New Address"]) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"showSavedAddresses" forKey:@"command"]];
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:NewAddress:Cancel"];
    }
    else if([self.navigationItem.title isEqualToString:@"Credit Cards"]) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"goToCart" forKey:@"command"]];
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:CreditCards:Cancel"];
    }
    else if([self.navigationItem.title isEqualToString:@"New Credit Card"]) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"showSavedCreditCards" forKey:@"command"]];
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:NewCreditCard:Cancel"];
    }
}


@end