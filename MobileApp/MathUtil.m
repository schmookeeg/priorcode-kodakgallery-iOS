#import "MathUtil.h"

CGPoint rotatePoint( CGPoint point, CGPoint origin, CGFloat angle )
{
	CGPoint result = CGPointMake( 0, 0 );

	CGFloat radians = (CGFloat) DEGREES_TO_RADIANS( angle );

	result.x = (CGFloat) ( origin.x + ( point.x - origin.x ) * cos( radians ) + ( point.y - origin.y ) * sin( radians ) );
	result.y = (CGFloat) ( origin.y - ( point.x - origin.x ) * sin( radians ) + ( point.y - origin.y ) * cos( radians ) );

	return result;
}

CGSize fitSizeInSize( CGSize size, CGSize availableSize )
{
	if ( size.width == size.height )
	{
		CGFloat min = MIN( availableSize.width, availableSize.height );
		return CGSizeMake( min, min );
	}
	else if ( size.width < size.height )
	{
		// Portrait - fill height
		return CGSizeMake( availableSize.height / size.height * size.width, availableSize.height );
	}
	else
	{
		// Landscape - fill width
		return CGSizeMake( availableSize.width, availableSize.width / size.width * size.height );
	}
}