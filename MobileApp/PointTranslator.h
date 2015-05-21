//
//  Created by darron on 2/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

@interface PointTranslator : NSObject
{
	CGAffineTransform transform;

	CGRect originalSpace;
	CGRect targetSpace;
}

- (void)setOriginalSpaceRectangle:(CGRect)rect;
- (void)setTargetSpaceRectangle:(CGRect)rect;
- (CGPoint)transformPoint:(CGPoint)point;

- (CGFloat)scaleX;
- (CGFloat)scaleY;

@end