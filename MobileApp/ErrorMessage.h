//
//  ErrorModel.h
//  MobileApp
//
//  Created by Darron Schall on 8/30/11.
//

#import <Foundation/Foundation.h>

@interface ErrorMessage : NSObject

@property ( nonatomic, retain ) NSString *detail;
@property ( nonatomic, retain ) NSString *errorCode;

@end
