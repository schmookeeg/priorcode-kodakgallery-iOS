//
//  SPMProject.m
//  MobileApp
//
//  Created by Darron Schall on 2/28/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "SPMProject.h"

@implementation SPMProject

@synthesize projectId = _projectId;
@synthesize productConfiguration = _productConfiguration;
@synthesize page = _page;
@synthesize projectXml = _projectXml;

#pragma mark init / dealloc

- (id)init
{
	self = [super init];
	if ( self )
	{

	}
	return self;
}

- (void)dealloc
{
	[_projectId release];
	[_productConfiguration release];
	[_page release];
	[_projectXml release];

	[super dealloc];
}

#pragma mark -

- (void)createPageUsingPhoto:(PhotoModel *)photo
{
	[_page release];

	_page = [[Page alloc] init];

	SPMLayout *layout = _productConfiguration.layout;

	// FIXME: We still need to get these actual values somehow.  For now we just default everything
	// to the layout information.
	_page.x = layout.x;
	_page.y = layout.y;
	_page.width = layout.width;
	_page.height = layout.height;
	_page.finishedLayoutArea = CGRectMake( [_page.x floatValue], [_page.y floatValue], [_page.width floatValue], [_page.height floatValue] );

	_page.layout = layout;
	for ( ImageElement *imageElement in layout.photoHoles )
	{
		imageElement.photo = photo;
		[imageElement centerCropToFillUsingRotation:0];
	}

	// TODO: Background
	//NSLog(@"Page Layout siteServicesCanvasId: %@", [_productConfiguration.layout siteServicesCanvasId]);

	// Background, covers entire page area - hardcore a bg asset for now
//	PhotoModel *backgroundPhoto = [[PhotoModel alloc] init];
//	backgroundPhoto.albUrl = @"http://assets.kodakgallery.com//A/products/SPM/assets/mag_10_hearts_V_1P.jpg";
//	backgroundPhoto.sumoUrl = backgroundPhoto.albUrl;
//	backgroundPhoto.bgUrl = backgroundPhoto.albUrl;
//	backgroundPhoto.smUrl = backgroundPhoto.albUrl;
//
//	imageElement = [[ImageElement alloc] initWithType:ImageElementTypeBackground];
//	imageElement.x = [NSNumber numberWithDouble:0];
//	imageElement.y = [NSNumber numberWithDouble:0];
//	imageElement.width = [NSNumber numberWithDouble:2.375];
//	imageElement.height = [NSNumber numberWithDouble:3.375];
//	imageElement.photo = backgroundPhoto;
//	page.background = imageElement;
//	[imageElement release];
//	[backgroundPhoto release];
}

- (void)populateProjectTemplate
{
    NSError *err = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"SPMProjectTemplate" ofType: @"xml"];
    NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&err];
    
    if (err)
        NSLog(@"Error in loading SPMProjectTemplate.xml file: %@", err);
    
    DDXMLDocument *projDoc = [[[DDXMLDocument alloc] autorelease] initWithData:data options:0 error:nil];
    self.projectXml = [projDoc rootElement];
    
    SPMSKU *sku = [self.productConfiguration.product.skus objectAtIndex:0];

	NSString *urlStr = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kServiceSpmProjectTemplate, sku.siteServicesProductId]];
    NSLog(@"Getting project template from url: %@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (url)
    {
        RKRequest *request = [RKRequest requestWithURL:url delegate:self];
        request.backgroundPolicy = RKRequestBackgroundPolicyNone;
        request.method = RKRequestMethodGET;
        
        // Flag the request as GetProjectTemplate so when the response comes back we know how to act
        request.userData = @"GetProjectTemplate";

		// FIXME: Synchronous server calls are a bad idea (they block the run loop).
        RKResponse *response = [request sendSynchronously];
        [self processGetProjectResponse:response];
    }
}


- (void)processGetProjectResponse:(RKResponse *)response
{
    NSLog(@"Processing response: %@", response);
	BOOL showError = false;
    
	if ( [response isOK] )
	{
		NSError *error = nil;
		NSData *data = [response body];
        
		DDXMLElement *root = [[[[DDXMLDocument alloc] initWithData:data options:0 error:&error] autorelease] rootElement];
        NSLog( @"Response XML: %@", [root XMLString] );
        
		if ( error )
		{
			NSLog( @"Error reading project response: %@", error );
            
			showError = true;
		}
		else
		{
            NSString *templateId = [((DDXMLElement *)[[root elementsForName:@"id"] objectAtIndex:0]) stringValue];
            [((DDXMLElement *)[[self.projectXml elementsForName:@"templateId"] objectAtIndex:0]) setStringValue:templateId];
		}
	}
	else
	{
		NSLog( @"Could not save project, response:. %@", [response bodyAsString] );

		showError = true;
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
    
    // Doing nothing right now, since the only call we are making here is a synchronous call.
    /*
	if ( [userData isEqualToString:@"GetProjectTemplate"] )
	{
		//[self processGetProjectResponse:response];
	}
     */
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
	NSString *userData = [request userData];
    
	if ( [userData isEqualToString:@"GetProjectTemplate"] )
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


@end
