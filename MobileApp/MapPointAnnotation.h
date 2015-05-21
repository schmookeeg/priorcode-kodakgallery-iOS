
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class StoreModel;


@interface MapPointAnnotation : NSObject <MKAnnotation> {

@private
    StoreModel *_storeModel;
    CLLocationCoordinate2D _coordinate;

}


@property (nonatomic, retain) StoreModel *storeModel;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithStore:(StoreModel*)store;


@end