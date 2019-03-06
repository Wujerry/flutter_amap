#import <Flutter/Flutter.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface FlutterAmapPlugin : NSObject<FlutterPlugin>

@property (nonatomic, strong) AMapSearchAPI        *search;
@property (nonatomic, strong) AMapGeoFenceManager        *geoFenceManager;
@end
