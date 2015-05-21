//
//  Created by darron on 3/27/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "DDXML.h"
#import "SPMProject.h"

@interface SPMProjectXmlTranslator : NSObject

+ (DDXMLElement*)projectToXmlElement:(SPMProject *)project;

@end