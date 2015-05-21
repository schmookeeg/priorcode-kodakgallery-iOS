//
//  NSString+NSArrayFormatExtension.h
//  MobileApp
//
//  Created by Darron Schall on 9/16/11.
//

#import <Foundation/Foundation.h>

@interface NSString (NSArrayFormatExtension)

+ (id)stringWithFormat:(NSString *)format array:(NSArray *)arguments;

@end