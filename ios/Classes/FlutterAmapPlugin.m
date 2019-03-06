#import "FlutterAmapPlugin.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import "AMapViewManager.h"
#import "AMapView.h"
#import <CoreLocation/CLLocation.h>

@interface FlutterAmapPlugin()<AMapSearchDelegate,AMapGeoFenceManagerDelegate>
{
    NSMutableDictionary* _dic;
}
@property (nonatomic, assign) UIViewController *root;
@property (nonatomic, assign) FlutterMethodChannel *channel;
@property (nonatomic,retain) AMapViewManager *manager;

@property (nonatomic,weak) UIViewController* mapViewController;

@end

@implementation FlutterAmapPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"flutter_amap" binaryMessenger:[registrar messenger]];
    
    UIViewController *root = UIApplication.sharedApplication.delegate.window.rootViewController;
    FlutterAmapPlugin* instance = [[FlutterAmapPlugin alloc] initWithRoot:root channel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}
/*
 -(void)dealloc{
 NSLog(@"self dealloc");
 }
 */



- (id)initWithRoot:(UIViewController *)root channel:(FlutterMethodChannel *)channel {
    if (self = [super init]) {
        self.root = root;
        self.channel = channel;
        self.manager = [[AMapViewManager alloc]initWithMessageChannel:channel];
        _dic = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* method = call.method;
    if ([@"setApiKey" isEqualToString:method]) {
        [AMapServices sharedServices].apiKey = call.arguments;
        result(@YES);
    } else if ([@"show" isEqualToString:method]){
        NSDictionary *args = call.arguments;
        NSDictionary* mapView = args[@"mapView"];
        NSString* title = args[@"id"];
        
        [self show:mapView key:title];
        result(@YES);
        
    }else if ([@"poiSearch" isEqualToString:method]){
        NSDictionary *args = call.arguments;
        [self poiSearch:args[@"id"] lat:args[@"lat"] lng:args[@"lng"] keyword:args[@"keyword"]];
    }else if ([@"moveCamera" isEqualToString:method]){
        NSDictionary *args = call.arguments;
        [self moveCamera:args[@"id"] lat:args[@"lat"] lng:args[@"lng"]];
    }else if([@"dismiss" isEqualToString:method ]) {
        [self dismiss];
        result(@YES);
    }else if([@"rect" isEqualToString:method ]) {
        
        NSDictionary *args = call.arguments;
        double x = [args[@"x"] doubleValue];
        double y = [args[@"y"] doubleValue];
        double width = [args[@"width"] doubleValue];
        double height = [args[@"height"] doubleValue];
        NSString* key = args[@"id"];
        
        UIView* view = _dic[key];
        view.frame = CGRectMake(x, y, width, height);
    }else if([@"remove" isEqualToString:method ]) {
        NSDictionary *args = call.arguments;
        NSString* key = args[@"id"];
        [self remove: key ];
        result(@YES);
    }else if([@"hide" isEqualToString:method ]) {
        NSDictionary *args = call.arguments;
        NSString* key = args[@"id"];
        BOOL hide = [args[@"hide"]boolValue];
        UIView* view = _dic[key];
        view.hidden = hide;
        result(@YES);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

-(void)dismiss{
    if(self.mapViewController){
        [self.root dismissViewControllerAnimated:true completion:nil];
        self.mapViewController = nil;
    }
}

-(void)updateViewProps:(NSDictionary*)mapView amapView:(AMapView*)amapView{
    amapView.showsScale = [mapView[@"showsScale"]boolValue];
    amapView.showsLabels =[mapView[@"showsLabels"]boolValue];
    amapView.showsCompass =[mapView[@"showsCompass"]boolValue];
    amapView.showsBuildings =[mapView[@"showsBuildings"]boolValue];
    amapView.showsIndoorMap =[mapView[@"showsIndoorMap"]boolValue];
    amapView.showsUserLocation =[mapView[@"showsUserLocation"]boolValue];
    amapView.showsIndoorMapControl =[mapView[@"showsIndoorMapControl"]boolValue];
    amapView.userTrackingMode = MAUserTrackingModeFollow;
    
    
    amapView.zoomEnabled =[mapView[@"zoomEnabled"]boolValue];
    amapView.distanceFilter =[mapView[@"distanceFilter"]doubleValue];
    
    amapView.zoomLevel =[mapView[@"zoomLevel"]doubleValue];
    amapView.minZoomLevel =[mapView[@"minZoomLevel"]doubleValue];
    amapView.maxZoomLevel =[mapView[@"maxZoomLevel"]doubleValue];
    amapView.rotateEnabled =[mapView[@"rotateEnabled"]boolValue];
    amapView.rotationDegree =[mapView[@"rotationDegree"]doubleValue];
    amapView.scrollEnabled =[mapView[@"scrollEnabled"]boolValue];
    
    amapView.mapType =[mapView[@"mapType"]integerValue];
    
    
    NSDictionary* centerCoordinate = [mapView objectForKey:@"centerCoordinate"];
    if(centerCoordinate && centerCoordinate!=(id)[NSNull null]){
        CLLocationCoordinate2D center = (CLLocationCoordinate2D){
            [centerCoordinate[@"latitude"]doubleValue], [centerCoordinate[@"longitude"]doubleValue]
        };
        amapView.centerCoordinate = center;
    }
    
    NSDictionary* geoFence = [mapView objectForKey:@"geoFence"];
    if(geoFence && geoFence!=(id)[NSNull null]){
        self.geoFenceManager = [[AMapGeoFenceManager alloc] init];
        self.geoFenceManager.delegate = self;
        self.geoFenceManager.activeAction = AMapGeoFenceActiveActionInside | AMapGeoFenceActiveActionOutside | AMapGeoFenceActiveActionStayed; //设置希望侦测的围栏触发行为，默认是侦测用户进入围栏的行为，即AMapGeoFenceActiveActionInside，这边设置为进入，离开，停留（在围栏内10分钟以上），都触发回调
        self.geoFenceManager.allowsBackgroundLocationUpdates = YES;  //允许后台定位
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([geoFence[@"lat"]doubleValue],[geoFence[@"lng"]doubleValue]);
        [self.geoFenceManager addCircleRegionForMonitoringWithCenter:coordinate radius:[geoFence[@"radius"]doubleValue] customID:geoFence[@"customID"]];
        
    }
    
    NSDictionary* limitRegion = [mapView objectForKey:@"limitRegion"];
    if(limitRegion && limitRegion!=(id)[NSNull null]){
        amapView.limitRegion = MACoordinateRegionMake(
                                                      (CLLocationCoordinate2D){[limitRegion[@"latitude"]doubleValue], [limitRegion[@"longitude"]doubleValue]},
                                                      (MACoordinateSpan){ [limitRegion[@"latitudeDelta"]doubleValue], [limitRegion[@"longitudeDelta"]doubleValue]
                                                      }
                                                      );
    }
    
    NSDictionary* region = [mapView objectForKey:@"region"];
    if(region && region!=(id)[NSNull null]){
        amapView.region = MACoordinateRegionMake(
                                                 (CLLocationCoordinate2D){[region[@"latitude"]doubleValue], [region[@"longitude"]doubleValue]},
                                                 (MACoordinateSpan){ [region[@"latitudeDelta"]doubleValue], [region[@"longitudeDelta"]doubleValue]
                                                 }
                                                 );
    }
    
}

- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didAddRegionForMonitoringFinished:(NSArray<AMapGeoFenceRegion *> *)regions customID:(NSString *)customID error:(NSError *)error {
    if (error) {
        NSLog(@"创建失败 %@",error);
    } else {
        NSLog(@"创建成功");
    }
}

- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didGeoFencesStatusChangedForRegion:(AMapGeoFenceRegion *)region customID:(NSString *)customID error:(NSError *)error {
    if (error) {
        NSLog(@"status changed error %@",error);
    }else{
        NSLog(@"status changed success %@",[region description]);
        [self.channel invokeMethod:@"geoFenceChange" arguments:@{
                                                                 @"id":customID,
                                                                 @"status":@(region.fenceStatus)
                                                                 }];
        
    }
}

-(void)show:(NSDictionary*)mapView key:(NSString*)key{
    NSLog(@"%lf", kCLDistanceFilterNone);
    //将属性映射到view上面
    AMapView* amapView = (AMapView*)[self.manager view];
    amapView.key = key;
    [self updateViewProps:mapView amapView:amapView];
    _dic[key]  = amapView;
    //初始化POI搜索
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    // navController.navigationBar.translucent = NO;
    [self.root.view addSubview:amapView];
    
}


-(void)remove : (NSString*) key{
    AMapView* view = _dic[key] ;
    [view removeFromSuperview];
    [_dic removeObjectForKey:key];
    
}

-(void)moveCamera: (NSString*) key lat:(NSNumber*)lat lng:(NSNumber*)lng{
    AMapView* view = _dic[key] ;
    CLLocationCoordinate2D center = (CLLocationCoordinate2D){
        [lat doubleValue], [lng doubleValue]
    };
    view.centerCoordinate = center;
}

-(void)poiSearch: (NSString*) key lat:(NSNumber*)lat lng:(NSNumber*)lng keyword:(NSString*)keyword{
    
//    self.mapPOIKey = key;
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location            = [AMapGeoPoint locationWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
    request.keywords            = keyword;
    /* 按照距离排序. */
    request.sortrule            = 0;
    request.requireExtension    = YES;
    request.offset = 10;
    [self.search AMapPOIAroundSearch:request];
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < response.pois.count; i ++) {
        NSDictionary* _dic;
        _dic = @{
                 @"title": response.pois[i].name,
                 @"lat": @(response.pois[i].location.latitude),
                 @"lng": @(response.pois[i].location.longitude),
                 @"address": response.pois[i].address
                 };
        [arr addObject:_dic];
    }
    NSArray *arrResult = [arr copy];
    NSDictionary* result = @{
//                             @"id": self.mapPOIKey,
                             @"list": arrResult,};
    [self.channel invokeMethod:@"poiResult" arguments:result];
    
    //解析response获取POI信息，具体解析见 Demo
}



@end
