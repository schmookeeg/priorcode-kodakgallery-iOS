//
//  SPMProject.h
//  MobileApp
//
//  Created by Darron Schall on 2/28/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPMProductConfiguration.h"
#import "Page.h"
#import "PhotoModel.h"
#import <RestKit/RestKit.h>


/**
 * An SPM Project is the combination of the SPM Product Configuration data with
 * the user's own informatin (photos and text).
 */
@interface SPMProject : NSObject <RKRequestDelegate>
{
    Page *_page;
}


/**
 * Project Id
 */
@property (nonatomic, retain ) NSNumber *projectId;

/**
 * The details of the product itself.
 */
@property ( nonatomic, retain ) SPMProductConfiguration *productConfiguration;

/**
 * The user-configured page data (photos, text).
 */
@property ( nonatomic, readonly ) Page *page;

/**
 * XML representation of this project.
 */
@property ( nonatomic, retain ) DDXMLElement *projectXml;


/**
 * Given a photo, converts information form the product configuration into
 * a page that can be displayed by the CanvasRenderer.
 */
- (void)createPageUsingPhoto:(PhotoModel *)photo;

- (void) populateProjectTemplate;

- (void) processGetProjectResponse:(RKResponse *) response;

@end
