//
//  Created by darron on 3/22/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ManagedWebViewController.h"
#import "SPMProject.h"



@interface SPMCartManagedWebViewController : ManagedWebViewController
{
}

@property ( nonatomic, retain ) SPMProject *project;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query;

+ (NSString *)cartPage;


@end