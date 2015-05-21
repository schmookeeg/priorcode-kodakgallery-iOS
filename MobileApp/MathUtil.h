//
//  Created by darron on 2/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define RADIANS_TO_DEGREES(radians) ((radians) * 180.0 / M_PI)


CGPoint rotatePoint( CGPoint point, CGPoint origin, CGFloat angle );

/**
 * Given an available size, this will scale down the size so that it
 * fits within the availableSize yet still maintains its aspect ratio.
 */
CGSize fitSizeInSize( CGSize size, CGSize availableSize );