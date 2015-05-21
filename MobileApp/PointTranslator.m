//
//  Created by darron on 2/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PointTranslator.h"

@interface PointTranslator (Private)

- (void)calculateTransform;

@end

@implementation PointTranslator


- (void)setOriginalSpaceRectangle:(CGRect)rect
{
	originalSpace = rect;

//	CGFloat a, b, c, d, tx, ty;
//			CGAffineTransform transform = CGAffineTransformMake(a, b, c, d, tx, ty );
//
//			CGPointApplyAffineTransform(<#(CGPoint)point#>, <#(CGAffineTransform)t#>)
}

- (void)setTargetSpaceRectangle:(CGRect)rect
{
	targetSpace = rect;
	
	[self calculateTransform];
}

- (void)calculateTransform
{
	CGFloat originalWidth = originalSpace.size.width - originalSpace.origin.x;
	CGFloat targetWidth = targetSpace.size.width - targetSpace.origin.x;
	CGFloat scaleX = targetWidth / originalWidth;

	CGFloat originalHeight = originalSpace.size.height - originalSpace.origin.y;
	CGFloat targetHeight = targetSpace.size.height - targetSpace.origin.y;
	CGFloat scaleY = targetHeight / originalHeight;

	// Take the smaller of the two scale values because we want to maintain
	// the aspect ratio
	if ( scaleX > scaleY )
	{
		scaleX = scaleY;
	}
	else
	{
		scaleY = scaleX;
	}

	CGFloat translationX = -1 * originalSpace.origin.x * scaleX;
	CGFloat translationY = -1 * originalSpace.origin.y * scaleY;

	transform = CGAffineTransformMakeScale(  scaleX, scaleY );
	CGAffineTransformTranslate( transform, translationX, translationY );
}

- (CGPoint)transformPoint:(CGPoint)point
{
	return CGPointApplyAffineTransform( point, transform );
}

- (CGFloat)scaleX
{
	return transform.a;
}

- (CGFloat)scaleY
{
	return transform.d;
}

@end