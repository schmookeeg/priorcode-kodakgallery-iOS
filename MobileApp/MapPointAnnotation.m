#import "MapPointAnnotation.h"
#import "StoreModel.h"


@implementation MapPointAnnotation
@synthesize coordinate = _coordinate;
@synthesize storeModel = _storeModel;


- (id)initWithStore:(StoreModel *)store {
    if ((self = [super init])) {
        self.storeModel = store;
        _coordinate = [store coordinate];
    }
    return self;

}


- (void)dealloc
{
    [_storeModel release];
    _storeModel = nil;

    [super dealloc];
}

@end