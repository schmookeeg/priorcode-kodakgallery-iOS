//
//  ProductDetailViewController.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "SelectAlbumViewController.h"
#import "FramedPhoto.h"
#import "FramedText.h"
#import "SPMProjectXmlTranslator.h"
#import "SettingsModel.h"
#import "SPMProjectTableItem.h"

@interface ProductDetailViewController (Private)

- (void)applyBackgroundGradient;

- (void)applyPricingInformation;

- (void)showPhotoHoleTip;

- (void)editImageElement:(ImageElement *)imageElement;

- (void)editTextElement:(TextElement *)textElement;

- (void)saveProject;

- (void)processSaveProjectResponse:(RKResponse *)response;

- (void)addToCart;

- (void)processAddToCartResponse:(RKResponse *)response;

@end

@implementation ProductDetailViewController

@synthesize project = _project;
@synthesize photoHoleTipView = _photoHoleTipView;
@synthesize dataSource = _dataSource;

#pragma mark init / dealloc

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
	self = [super initWithNibName:nil bundle:nil];
	if ( self )
	{
		self.title = @"Product Detail";

		// TRICKY Pull the complex data from the dictionary query that was supplied with the
		// action that brought us here.
		self.project = [query objectForKey:@"project"];
        self.dataSource = [query objectForKey:@"dataSource"];
	}

	return self;
}

- (void)dealloc
{
	[lowResolutionBar release];
	[canvasRenderer release];
	[priceLabel release];

	[_project release];
	[_photoHoleTipView release];
    [_dataSource release];

	[_hud release];

	[super dealloc];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Do any additional setup after loading the view from its nib.

	[self applyBackgroundGradient];

	// Create the banner at the top of the view
	UIImageView *shopTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shopTop.png"]];
	[self.view addSubview:shopTop];
	[shopTop release];
    
    // Adjust low res warning down a smidgen to make room for the top banner.
    CGRect lowResolutionFrame = lowResolutionBar.frame;
    lowResolutionFrame.origin.y += shopTop.frame.size.height;
    lowResolutionBar.frame = lowResolutionFrame;

	[self applyPricingInformation];

	canvasRenderer.page = self.project.page;

	// Show the shadow
	canvasRenderer.clipsToBounds = NO;
	canvasRenderer.layer.shadowColor = [UIColor blackColor].CGColor;
	canvasRenderer.layer.shadowOffset = CGSizeMake( -2, 2 );
	canvasRenderer.layer.shadowOpacity = 0.7;

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[canvasRenderer addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];

	UIBarButtonItem *buyNowButton = [[UIBarButtonItem alloc] initWithTitle:@"Buy Now" style:UIBarButtonItemStyleDone target:self action:@selector(addToCartAction:)];
	self.navigationItem.rightBarButtonItem = buyNowButton;
	[buyNowButton release];

	self.navigationItem.title = self.project.productConfiguration.sku.name;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

	// Toggle the low res warning display if the photo hole is low res
	for ( LayoutElement *layoutElement in self.project.page.layout.elements )
	{
		if ( [layoutElement isKindOfClass:[ImageElement class]] )
		{
			ImageElement *imageElement = (ImageElement *) layoutElement;
			if ( imageElement.type == ImageElementTypePhotoHole || imageElement.type == ImageElementTypeTemplateHole )
			{
				lowResolutionBar.hidden = !imageElement.isLowResolution;
				break;
			}
		}
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	// Register to receive touch events
	( (EventInterceptWindow *) self.view.window ).eventInterceptDelegate = self;

	// This works better in view appear because it gives the canvas renderer time to
	// draw itself based on setting the page, so that the tip appears in the right
	// location over the photo hole.
	[self showPhotoHoleTip];
    
    [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Product Detail:Magnet"];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// Deregister from receiving touch events
	( (EventInterceptWindow *) self.view.window ).eventInterceptDelegate = nil;

	[super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view.

	[lowResolutionBar release];
	lowResolutionBar = nil;

	[canvasRenderer release];
	canvasRenderer = nil;

	[priceLabel release];
	priceLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

- (void)applyBackgroundGradient
{
	// Initialize the gradient layer
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];

	// Create a bounding area for the empty space at the bottom
	CGRect bounds = self.view.bounds;
	gradientLayer.bounds = self.view.bounds;
	gradientLayer.position = CGPointMake( CGRectGetMidX( bounds ), CGRectGetMidY( bounds ) );

	UIColor *highColor = [UIColor colorWithRed:0x99 / 255.0 green:0x99 / 255.0 blue:0x99 / 255.0 alpha:1];
	UIColor *lowColor = [UIColor colorWithRed:0xE5 / 255.0 green:0xE5 / 255.0 blue:0xE5 / 255.0 alpha:1];
	NSArray *backgroundGradientColors = [NSArray arrayWithObjects:(id) [highColor CGColor], (id) [lowColor CGColor], nil];
	gradientLayer.colors = backgroundGradientColors;

	[self.view.layer insertSublayer:gradientLayer atIndex:0];
	[gradientLayer release];
}

- (void)applyPricingInformation
{
	SPMSKU *sku = self.project.productConfiguration.sku;

	NSString *priceStr = nil;
	NSString *salePriceStr = nil;

	if ( [sku.priceBulk isEqualToString:@"true"] )
	{
		priceStr = [[[sku.bulkPrices objectAtIndex:0] price] stringValue];
		salePriceStr = [[[sku.bulkPrices objectAtIndex:0] salePrice] stringValue];
	}
	else
	{
		priceStr = [sku.price stringValue];
		salePriceStr = [sku.salePrice stringValue];
	}

	NSMutableAttributedString *text;

	if ( priceStr && salePriceStr )
	{
		//float discount = [priceStr floatValue] - [salePriceStr floatValue];

		text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"$%@ $%@", priceStr, salePriceStr]];

		NSRange priceRange = NSMakeRange( 0, priceStr.length + 1 );
		NSRange salePriceRange = NSMakeRange( priceStr.length + 2, salePriceStr.length + 1 );
		NSRange textRange = NSMakeRange( 0, text.length );

		// Font and size - regular original price
		UIFont *font = [UIFont systemFontOfSize:17.0];
		CTFontRef fontRef = CTFontCreateWithName( (CFStringRef) font.fontName, font.pointSize, nil );
		[text addAttribute:(NSString *) kCTFontAttributeName value:(id) fontRef range:priceRange];
		CFRelease( fontRef );

		// Font and size - bold and bigger sale price
		UIFont *boldFont = [UIFont boldSystemFontOfSize:18.0];
		CTFontRef boldFontRef = CTFontCreateWithName( (CFStringRef) boldFont.fontName, boldFont.pointSize, nil );
		[text addAttribute:(NSString *) kCTFontAttributeName value:(id) boldFontRef range:salePriceRange];
		CFRelease( boldFontRef );

		// Text color - original price in black
		[text addAttribute:(NSString *) kCTForegroundColorAttributeName
					 value:(id) [UIColor blackColor].CGColor
					 range:priceRange];

		// sale price in red
		[text addAttribute:(NSString *) kCTForegroundColorAttributeName
					 value:(id) [UIColor redColor].CGColor
					 range:salePriceRange];

		// Strike-through the original price
		[text addAttribute:kTTTStrikeOutAttributeName value:[NSNumber numberWithBool:YES] range:priceRange];

		// Text alignment
		CTTextAlignment theAlignment = kCTCenterTextAlignment;
		CFIndex theNumberOfSettings = 1;
		CTParagraphStyleSetting theSettings[1] = { { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment } };
		CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate( theSettings, theNumberOfSettings );
		[text addAttribute:(NSString *) kCTParagraphStyleAttributeName value:(id) theParagraphRef range:textRange];
		CFRelease( theParagraphRef );
	}
	else
	{
		text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"$%@", priceStr]];

		NSRange priceRange = NSMakeRange( 0, text.length );

		// Font and size
		UIFont *font = [UIFont systemFontOfSize:18.0];
		CTFontRef fontRef = CTFontCreateWithName( (CFStringRef) font.fontName, font.pointSize, nil );
		[text addAttribute:(NSString *) kCTFontAttributeName value:(id) fontRef range:priceRange];
		CFRelease( fontRef );

		// Text color
		[text addAttribute:(NSString *) kCTForegroundColorAttributeName
					 value:(id) [UIColor blackColor].CGColor
					 range:priceRange];

		// Text alignment
		CTTextAlignment theAlignment = kCTCenterTextAlignment;
		CFIndex theNumberOfSettings = 1;
		CTParagraphStyleSetting theSettings[1] = { { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment } };
		CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate( theSettings, theNumberOfSettings );
		[text addAttribute:(NSString *) kCTParagraphStyleAttributeName value:(id) theParagraphRef range:priceRange];
		CFRelease( theParagraphRef );
	}



	priceLabel.adjustsFontSizeToFitWidth = NO;
	priceLabel.textAlignment = UITextAlignmentCenter;

	priceLabel.text = text;
	[text release];
}

- (void)showPhotoHoleTip
{
	// Hide an existing tip
	[self.photoHoleTipView dismissAnimated:NO];

	if ( ![SettingsModel settings].tipDisplayedPhotoHole )
	{
		// Create the new tip
		CMPopTipView *tipView = [[CMPopTipView alloc] initWithMessage:@"Tap on the photo to\nzoom and crop."];
		tipView.backgroundColor = POPTIP_BACKGROUND_COLOR;
		tipView.textColor = POPTIP_TEXT_COLOR;
		tipView.delegate = self;
		tipView.animation = CMPopTipAnimationPop;

		// Find the framed photo that is displaying the photo hole image element.
		// TODO: This assumes way too much knowledge about the internal structure of the
		// canvas renderer - better to ask the renderer for [canvasRenderer viewForPhotoHole]
		// isntead.
		FramedPhoto *photoHoleDisplay = nil;
		for ( UIView *view in canvasRenderer.subviews )
		{
			if ( [view isKindOfClass:[FramedPhoto class]] )
			{
				ImageElementType type = ( (FramedPhoto *) view ).imageElement.type;
				if ( type == ImageElementTypePhotoHole || type == ImageElementTypeTemplateHole )
				{
					photoHoleDisplay = (FramedPhoto *) view;
					break;
				}
			}
		}

		if ( photoHoleDisplay )
		{
			[tipView presentPointingAtView:photoHoleDisplay inView:canvasRenderer animated:YES];
		}

		self.photoHoleTipView = tipView;
		[tipView release];
	}
	else
	{
		self.photoHoleTipView = nil;
	}
}


#pragma mark - Handling

- (void)handleTap:(UITapGestureRecognizer *)sender
{
	if ( sender.state == UIGestureRecognizerStateEnded )
	{
		CGPoint tapPoint = [sender locationInView:canvasRenderer];

		// Loop *backwards* over the subviews so that the top-most view gets
		// to respond to the tap (this is great for when images and text
		// overlap each other)
		for ( UIView *subview in [canvasRenderer.subviews reverseObjectEnumerator] )
		{
			// Did the tap happen inside of the subviews bounds?
			if ( CGRectContainsPoint( subview.frame, tapPoint ) )
			{
				if ( [subview isKindOfClass:[FramedPhoto class]] )
				{
					ImageElement *imageElement = ( (FramedPhoto *) subview ).imageElement;

					// Only photo holes are editable by the zoom/crop
					if ( imageElement.type == ImageElementTypePhotoHole || imageElement.type == ImageElementTypeTemplateHole )
					{
						[self editImageElement:imageElement];
						return;
					}
				}
				else if ( [subview isKindOfClass:[FramedText class]] )
				{
					[self editTextElement:( (FramedText *) subview ).textElement];
					return;
				}
			}
		}
	}
}

- (void)editImageElement:(ImageElement *)imageElement
{
    [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Product Detail:Edit Photo"];

    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageElement, @"imageElement", self, @"delegate", nil];
	TTURLAction *actionUrl = [[[TTURLAction actionWithURLPath:@"tt://editImageElement"] applyAnimated:YES] applyQuery:dictionary];

	[[TTNavigator navigator] openURLAction:actionUrl];
}

- (void)editTextElement:(TextElement *)textElement
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:textElement, @"textElement", self, @"delegate", nil];
	TTURLAction *actionUrl = [[[TTURLAction actionWithURLPath:@"tt://editTextElement"] applyAnimated:YES] applyQuery:dictionary];

	[[TTNavigator navigator] openURLAction:actionUrl];
}

#pragma mark EditImageElementViewControllerDelegate

- (void)imageElementEditor:(EditImageElementViewController *)editor didFinishEditing:(ImageElement *)imageElement
{
	imageElement.resolutionIndependentCrop = editor.resolutionIndependentCrop;
	imageElement.tintType = editor.tintType;
}

#pragma mark EditTextElementViewControllerDelegate

- (void)textElementEditor:(EditTextElementViewController *)editor didFinishEditing:(TextElement *)textElement
{
	textElement.currentFont = editor.fontInstance;
	textElement.text = editor.text;
}

#pragma mark SelectPhotosViewControllerDelegate

- (void)selectPhotosDidSelectPhotos:(NSArray *)photos inAlbum:(AbstractAlbumModel *)album
{
	// Because we only allow single photo selection, we're guarantreed that photos is an
	// array consistenting of one element, and the element is a PhotoModel* instance.
	PhotoModel *photo = [photos objectAtIndex:0];
    
    // Change the photo in the product list
    [self.dataSource changePhotoToPhotoId:photo.photoId inAlbumId:album.albumId];

	// Exit out of the modal select album flow.
	[[[TTNavigator navigator] visibleViewController] dismissModalViewControllerAnimated:YES];
}

- (void)selectPhotosDidCancel
{
	[[TTNavigator navigator].visibleViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark Actions

- (IBAction)addToCartAction:(id)sender
{
    @try
    {
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Product Detail:Buy"];
        
        [self saveProject];
    }
    @catch (NSException *e) 
    {
        [_hud hide:YES];
        
		[[[[UIAlertView alloc] initWithTitle:@"Server Error"
									 message:@"We are having difficulties performing your request. Please try again."
									delegate:self
						   cancelButtonTitle:@"OK"
						   otherButtonTitles:nil] autorelease] show];

    }
}

- (void)changePhotoAction:(id)sender
{
    [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Product Detail:Change Photo"];
    
	// The first step for shopping for a photo gift is moving through the select album flow
	TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://selectAlbumModal"] applyAnimated:YES];
	SelectAlbumViewController *viewController = (SelectAlbumViewController *) [[TTNavigator navigator] openURLAction:action];

	// The product list is only single photos at the moment.
	viewController.allowMultiplePhotoSelection = NO;

	// When the selection completes, notify ourselves so that we can move on to the next step in
	// the process without having to hard-code any product-related logic into the photo selection.
	viewController.selectPhotosDelegate = self;  
}

#pragma mark Save Project

- (void)saveProject
{
	NSString *urlSuffix = @"";
	NSNumber *projectId = self.project.projectId;
	if ( projectId == nil )
	{
		projectId = [NSNumber numberWithLong:0];
	}
	else
	{
		urlSuffix = @"?action=put";
	}

	// Substitute the project id placeholder with the project id to save
	NSString *strUrl = [NSString stringWithFormat:@"%@%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kServiceSpmProjectSave, projectId], urlSuffix];
	NSURL *url = [NSURL URLWithString:strUrl];

	NSLog( @"Saving project to url: %@", strUrl );

	if ( url )
	{
		// Configure the url request to save the project
		RKRequest *request = [RKRequest requestWithURL:url delegate:self];
		request.backgroundPolicy = RKRequestBackgroundPolicyNone;
		request.method = RKRequestMethodPOST;

		// We're going to send a block of XML as the data, configure the headers as such.
		NSDictionary *headers = [NSMutableDictionary dictionary];
		[headers setValue:@"text/xml" forKey:@"Content-Type"];
		request.additionalHTTPHeaders = headers;

		// Convert the project to XML, then to String
		DDXMLElement *projectXml = [SPMProjectXmlTranslator projectToXmlElement:self.project];
		NSString *projectXmlString = [projectXml XMLString];

		NSLog( @"Project XML: %@", projectXmlString );

		// Include the project XML String in the url body request
		NSData *data = [projectXmlString dataUsingEncoding:NSUTF8StringEncoding];
		request.URLRequest.HTTPBody = data;

		// Flag the request as SaveProject so when the response comes back we know how to act
		request.userData = @"SaveProject";

		[request send];

		// Show the loading progress dialog

		self.hud.labelText = @"Loading...";
		[self.hud show:YES];
	}
}

- (void)processSaveProjectResponse:(RKResponse *)response
{
	BOOL showError = NO;

	if ( [response isOK] )
	{
		NSError *error = nil;
		NSData *data = [response body];

		DDXMLElement *root = [[[[DDXMLDocument alloc] initWithData:data options:0 error:&error] autorelease] rootElement];

		if ( error )
		{
			NSLog( @"Error reading save project response: %@", error );

			showError = YES;
		}
		else
		{
			DDXMLElement *projectIdElement = [[root elementsForName:@"id"] objectAtIndex:0];
			NSNumber *projectId = [NSNumber numberWithDouble:[[projectIdElement stringValue] doubleValue]];

			NSLog( @"Project Id = %@, %f, %i, %ld", projectId, [projectId doubleValue], [projectId intValue], [projectId longValue] );

			if ( [projectId doubleValue] > 0 )
			{
				NSLog( @"Saved project, project id = %@", projectId );

				self.project.projectXml = root;
				self.project.projectId = projectId;
				// Add the project to the cart now that it's saved
				[self addToCart];
			}
			else
			{
				NSLog( @"Could not read project id from save project response." );

				showError = YES;
			}
		}

	}
	else
	{
		NSLog( @"Could not save project, response:. %@", [response bodyAsString] );

		showError = YES;
	}

	if ( showError )
	{
		// Only hide the Loading screen on error because the next step in the process
		// is to immediately call add to cart.
		[_hud hide:YES];

		[[[[UIAlertView alloc] initWithTitle:@"Server Error"
									 message:@"We are having difficulties performing your request. Please try again."
									delegate:self
						   cancelButtonTitle:@"OK"
						   otherButtonTitles:nil] autorelease] show];
	}
}

#pragma mark Add To Cart

- (void)addToCart
{
    // cart JSON format
    //{"cart":{"spm":{"pid":"proSpm0601111102","sid":"skuSpm0601111101","qty":1,"thurl":"http://uqma-gallery.qa.ofoto.com/imaging-site/services/doc/1050:68555416106/jpeg/BG/async","projid":"97555416106","projurl":"http://localhost:8080/site/rest/v1.0/page/28555416106/svg","preurl":"xx3","lid":"4800012"},"edit":false},"shipping":{"shippingMethod":"en_US_gallery_3-10business-daydelivery"}}
    
    NSMutableDictionary *cart = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *spm = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *cartData = [NSMutableDictionary dictionaryWithCapacity:7];
    
    SPMSKU *sku = [self.project.productConfiguration.product.skus objectAtIndex:0];

    DDXMLElement *projSection = (DDXMLElement *)[[self.project.projectXml elementsForName:@"section"] objectAtIndex:0];
    DDXMLElement *projPage = (DDXMLElement *)[[projSection elementsForName:@"page"] objectAtIndex:0];
    NSString *svgFulfillmentUrl = [(DDXMLElement *)[[projPage elementsForName:@"svgFulfillmentUrl"] objectAtIndex:0] stringValue];
    NSString *thumbUrl = [(DDXMLElement *)[[self.project.projectXml elementsForName:@"thumbnailUrl"] objectAtIndex:0] stringValue];
    
    
    [cartData setValue:self.project.productConfiguration.product.productId forKey:@"pid"];
    [cartData setValue:sku.skuId forKey:@"sid"];
    [cartData setValue:@"1" forKey:@"qty"];
    [cartData setValue:thumbUrl forKey:@"thurl"];
    [cartData setValue:[self.project.projectId stringValue] forKey:@"projid"];
    [cartData setValue:svgFulfillmentUrl forKey:@"projurl"];
    [cartData setValue:@"xx3" forKey:@"preurl"];
    [cartData setValue:[(SPMLayout *)[sku.layouts objectAtIndex:0] layoutId] forKey:@"lid"];

    [spm setValue:cartData forKey:@"spm"];
    [spm setValue:@"false" forKey:@"edit"];
    [spm setValue:@"" forKey:@"gid"];
    [spm setValue:@"" forKey:@"litmid"];
    [cart setValue:spm forKey:@"cart"];
    
    /*
    NSString *escapedCartData = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)[cart JSONRepresentation],
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8);
     NSString *cartQueryParameters = [NSString stringWithFormat:@"?mobileFlow=true&cartXml=%@", escapedCartXml];
     
     */
    
	// FIXME: If we're in update cart we pass different args:
	// var cartQueryParameters:String = "?projectId=" + projectId + "&skuId=" + skuId  + "&thumbnailUrl=" + thumbnailUrl + "&mediumUrl=" + mediumThumbnailUrl;

	NSString *strUrl = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kServiceAddToCart, kMobileSourceId]];

	// Might only need to pass the commerceItemId through if we're in the update cart scenario
	NSString *commerceItemId = nil;
	if ( commerceItemId )
	{
		strUrl = [strUrl stringByAppendingString:[NSString stringWithFormat:@"&commerceItemId=%@", commerceItemId]];
	}

	NSURL *url = [NSURL URLWithString:strUrl];

	NSLog( @"Adding project to cart via url: %@", strUrl );
    
	if ( url )
	{
		RKRequest *request = [RKRequest requestWithURL:url delegate:self];
		request.backgroundPolicy = RKRequestBackgroundPolicyNone;
		request.method = RKRequestMethodPOST;
		NSData *data = [[@"cartXml=" stringByAppendingString:[cart JSONRepresentation]] dataUsingEncoding:NSUTF8StringEncoding];
		request.URLRequest.HTTPBody = data;

		// Flag the request as AddToCart so when the response comes back we know how to act
		request.userData = @"AddToCart";

		[request send];

		// Show the loading progress dialog

		self.hud.labelText = @"Loading...";
		[self.hud show:YES];
	}
}

- (void)processAddToCartResponse:(RKResponse *)response
{
	[_hud hide:YES];

	BOOL showError = NO;

	if ( [response isOK] )
	{
		// Success, navigate to cart page.
		//[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://spm/cart"] applyAnimated:YES]];
        
        // Create a query to pass complex data into the view.
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.project, @"project", nil];
        
        // Navigate to the product details, passing the project information along
        TTURLAction *actionUrl = [[[TTURLAction actionWithURLPath:@"tt://spm/cart"] applyAnimated:YES] applyQuery:dictionary];
        [[TTNavigator navigator] openURLAction:actionUrl];

	}
	else
	{
		NSLog( @"Could not add to cart, response:. %@", [response bodyAsString] );

		showError = YES;
	}

	if ( showError )
	{
		[[[[UIAlertView alloc] initWithTitle:@"Server Error"
									 message:@"We are having difficulties performing your request. Please try again."
									delegate:self
						   cancelButtonTitle:@"OK"
						   otherButtonTitles:nil] autorelease] show];
	}
}

#pragma mark RKRequestDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	NSString *userData = [request userData];

	// Respond to the request based on which request it was
	if ( [userData isEqualToString:@"SaveProject"] )
	{
		[self processSaveProjectResponse:response];
	}
	else if ( [userData isEqualToString:@"AddToCart"] )
	{
		[self processAddToCartResponse:response];
	}
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
	[_hud hide:YES];

	NSString *userData = [request userData];

	if ( [userData isEqualToString:@"SaveProject"] || [userData isEqualToString:@"AddToCart"] )
	{
		// Convert the error to an error message we can use for logging purposes
		ErrorMessage *errorMessage = [[ErrorMessage alloc] init];
		errorMessage.detail = [error debugDescription];
		errorMessage.errorCode = [[NSNumber numberWithInt:error.code] stringValue];

		// Show a message to the user that the operation failed
		[AbstractModel uncaughtFailureWithErrorMessage:errorMessage];
		[errorMessage release];
	}
}

#pragma mark MBProgressHUD

- (MBProgressHUD *)hud
{
	if ( !_hud )
	{
		_hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		_hud.delegate = self;
		_hud.removeFromSuperViewOnHide = YES;
		[self.navigationController.view addSubview:_hud];
	}

	return _hud;
}

- (void)hudWasHidden
{
	// Free up memory when the hud goes away by release it safely (which prevents
	// a dual-release in dealloc as well)
	[_hud release];
	_hud = nil;
}

#pragma mark CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
	// User can tap CMPopTipView to dismiss it
	[self.photoHoleTipView dismissAnimated:YES];
	self.photoHoleTipView = nil;
}

#pragma mark EventInterceptWindowDelegate

- (BOOL)interceptEvent:(UIEvent *)event
{
	if ( self.photoHoleTipView.targetObject )
	{
		[self popTipViewWasDismissedByUser:self.photoHoleTipView];

		[SettingsModel settings].tipDisplayedPhotoHole = YES;
	}
	return NO;
}

@end
