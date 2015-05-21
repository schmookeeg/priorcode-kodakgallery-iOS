//
//  NSStringUrlEncode.h
//  MobileApp
//
//  Created by mikeb on 8/11/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URL)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end


