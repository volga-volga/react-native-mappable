#import <React/RCTComponent.h>
#import <React/UIView+React.h>

#if TARGET_OS_SIMULATOR
#import <mach-o/arch.h>
#endif

#import <MapKit/MapKit.h>
#import "../Converter/RCTConvert+Mappable.m"
@import MappableMobile;

#ifndef MAX
#import <NSObjCRuntime.h>
#endif

#import "MappablePolygonView.h"
#import "MappablePolylineView.h"
#import "MappableMarkerView.h"
#import "MappableCircleView.h"
#import "RNMView.h"

#define ANDROID_COLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:((c)&0xFF)/255.0  alpha:((c>>24)&0xFF)/255.0]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation RNMView {
    MMKMasstransitSession *masstransitSession;
    MMKMasstransitSession *walkSession;
    MMKMasstransitRouter *masstransitRouter;
    MMKDrivingRouter *drivingRouter;
    MMKDrivingSession *drivingSession;
    MMKPedestrianRouter *pedestrianRouter;
    MMKTransitOptions *transitOptions;
    MMKMasstransitSessionRouteHandler routeHandler;
    NSMutableArray<UIView*> *_reactSubviews;
    NSMutableArray *routes;
    NSMutableArray *currentRouteInfo;
    NSMutableArray<MMKRequestPoint *> *lastKnownRoutePoints;
    MMKUserLocationView *userLocationView;
    NSMutableDictionary *vehicleColors;
    UIImage *userLocationImage;
    NSNumber *userLocationImageScale;
    NSArray *acceptVehicleTypes;
    MMKUserLocationLayer *userLayer;
    MMKTrafficLayer *trafficLayer;
    UIColor *userLocationAccuracyFillColor;
    UIColor *userLocationAccuracyStrokeColor;
    float userLocationAccuracyStrokeWidth;
}

- (instancetype)init {
#if TARGET_OS_SIMULATOR
    NXArchInfo *archInfo = NXGetLocalArchInfo();
    NSString *cpuArch = [NSString stringWithUTF8String:archInfo->description];
    self = [super initWithFrame:CGRectZero vulkanPreferred:[cpuArch hasPrefix:@"ARM64"]];
#else
    self = [super initWithFrame:CGRectZero];
#endif

    _reactSubviews = [[NSMutableArray alloc] init];
    masstransitRouter = [[MMKTransport sharedInstance] createMasstransitRouter];
//    drivingRouter = [[MMK sharedInstance] createDrivingRouter];
    pedestrianRouter = [[MMKTransport sharedInstance] createPedestrianRouter];
    transitOptions = [MMKTransitOptions transitOptionsWithAvoid:MMKFilterVehicleTypesNone timeOptions:[[MMKTimeOptions alloc] init]];    acceptVehicleTypes = [[NSMutableArray<NSString *> alloc] init];
    routes = [[NSMutableArray alloc] init];
    currentRouteInfo = [[NSMutableArray alloc] init];
    lastKnownRoutePoints = [[NSMutableArray alloc] init];
    vehicleColors = [[NSMutableDictionary alloc] init];
    [vehicleColors setObject:@"#59ACFF" forKey:@"bus"];
    [vehicleColors setObject:@"#7D60BD" forKey:@"minibus"];
    [vehicleColors setObject:@"#F8634F" forKey:@"railway"];
    [vehicleColors setObject:@"#C86DD7" forKey:@"tramway"];
    [vehicleColors setObject:@"#3023AE" forKey:@"suburban"];
    [vehicleColors setObject:@"#BDCCDC" forKey:@"underground"];
    [vehicleColors setObject:@"#55CfDC" forKey:@"trolleybus"];
    [vehicleColors setObject:@"#2d9da8" forKey:@"walk"];
    userLocationImageScale = [NSNumber numberWithFloat:1.f];
    userLocationAccuracyFillColor = nil;
    userLocationAccuracyStrokeColor = nil;
    userLocationAccuracyStrokeWidth = 0.f;
    [self.mapWindow.map addCameraListenerWithCameraListener:self];
    [self.mapWindow.map addInputListenerWithInputListener:(id<MMKMapInputListener>) self];
    [self.mapWindow.map setMapLoadedListenerWithMapLoadedListener:self];
    return self;
}

- (NSDictionary*)convertDrivingRouteSection:(MMKDrivingRoute*)route withSection:(MMKDrivingSection*)section {
    int routeIndex = 0;
    MMKDrivingWeight *routeWeight = route.metadata.weight;
    NSMutableDictionary *routeMetadata = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *routeWeightData = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *sectionWeightData = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *transports = [[NSMutableDictionary alloc] init];
    NSMutableArray *stops = [[NSMutableArray alloc] init];
    [routeWeightData setObject:routeWeight.time.text forKey:@"time"];
    [routeWeightData setObject:routeWeight.timeWithTraffic.text forKey:@"timeWithTraffic"];
    [routeWeightData setObject:@(routeWeight.distance.value) forKey:@"distance"];
    [sectionWeightData setObject:section.metadata.weight.time.text forKey:@"time"];
    [sectionWeightData setObject:section.metadata.weight.timeWithTraffic.text forKey:@"timeWithTraffic"];
    [sectionWeightData setObject:@(section.metadata.weight.distance.value) forKey:@"distance"];
    [routeMetadata setObject:sectionWeightData forKey:@"sectionInfo"];
    [routeMetadata setObject:routeWeightData forKey:@"routeInfo"];
    [routeMetadata setObject:@(routeIndex) forKey:@"routeIndex"];
    [routeMetadata setObject:stops forKey:@"stops"];
    [routeMetadata setObject:UIColor.darkGrayColor forKey:@"sectionColor"];

    if (section.metadata.weight.distance.value == 0) {
        [routeMetadata setObject:@"waiting" forKey:@"type"];
    } else {
        [routeMetadata setObject:@"car" forKey:@"type"];
    }

    NSMutableDictionary *wTransports = [[NSMutableDictionary alloc] init];

    for (NSString *key in transports) {
        [wTransports setObject:[transports valueForKey:key] forKey:key];
    }

    [routeMetadata setObject:wTransports forKey:@"transports"];
    NSMutableArray* points = [[NSMutableArray alloc] init];
//    MMKPolyline* subpolyline = [MMKSubpolylineHelper subpolylineWithPolyline:route.geometry subpolyline:section.geometry];

//
//    for (int i = 0; i < [subpolyline.points count]; ++i) {
//        MMKPoint* point = [subpolyline.points objectAtIndex:i];
//        NSMutableDictionary* jsonPoint = [[NSMutableDictionary alloc] init];
//        [jsonPoint setValue:[NSNumber numberWithDouble:point.latitude] forKey:@"lat"];
//        [jsonPoint setValue:[NSNumber numberWithDouble:point.longitude] forKey:@"lon"];
//        [points addObject:jsonPoint];
//    }
    [routeMetadata setValue:points forKey:@"points"];

    return routeMetadata;
}

- (NSDictionary *)convertRouteSection:(MMKMasstransitRoute *)route withSection:(MMKMasstransitSection *)section {
    int routeIndex = 0;
    MMKMasstransitWeight* routeWeight = route.metadata.weight;
    MMKMasstransitSectionMetadataSectionData *data = section.metadata.data;
    NSMutableDictionary *routeMetadata = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *routeWeightData = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *sectionWeightData = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *transports = [[NSMutableDictionary alloc] init];
    NSMutableArray *stops = [[NSMutableArray alloc] init];
    [routeWeightData setObject:routeWeight.time.text forKey:@"time"];
    [routeWeightData setObject:@(routeWeight.transfersCount) forKey:@"transferCount"];
    [routeWeightData setObject:@(routeWeight.walkingDistance.value) forKey:@"walkingDistance"];
    [sectionWeightData setObject:section.metadata.weight.time.text forKey:@"time"];
    [sectionWeightData setObject:@(section.metadata.weight.transfersCount) forKey:@"transferCount"];
    [sectionWeightData setObject:@(section.metadata.weight.walkingDistance.value) forKey:@"walkingDistance"];
    [routeMetadata setObject:sectionWeightData forKey:@"sectionInfo"];
    [routeMetadata setObject:routeWeightData forKey:@"routeInfo"];
    [routeMetadata setObject:@(routeIndex) forKey:@"routeIndex"];

    for (MMKMasstransitRouteStop *stop in section.stops) {
        [stops addObject:stop.metadata.stop.name];
    }

    [routeMetadata setObject:stops forKey:@"stops"];

    if (data.transports != nil) {
        for (MMKMasstransitTransport *transport in data.transports) {
            for (NSString *type in transport.line.vehicleTypes) {
                if ([type isEqual: @"suburban"]) continue;
                if (transports[type] != nil) {
                    NSMutableArray *list = transports[type];
                    if (list != nil) {
                        [list addObject:transport.line.name];
                        [transports setObject:list forKey:type];
                    }
                } else {
                    NSMutableArray *list = [[NSMutableArray alloc] init];
                    [list addObject:transport.line.name];
                    [transports setObject:list forKey:type];
                }
                [routeMetadata setObject:type forKey:@"type"];
                UIColor *color;
                if (transport.line.style != nil) {
                    color = UIColorFromRGB([transport.line.style.color integerValue]);
                } else {
                    if ([vehicleColors valueForKey:type] != nil) {
                        color = [RNMView colorFromHexString:vehicleColors[type]];
                    } else {
                        color = UIColor.blackColor;
                    }
                }
                [routeMetadata setObject:[RNMView hexStringFromColor:color] forKey:@"sectionColor"];
            }
        }
    } else {
        [routeMetadata setObject:UIColor.darkGrayColor forKey:@"sectionColor"];
        if (section.metadata.weight.walkingDistance.value == 0) {
            [routeMetadata setObject:@"waiting" forKey:@"type"];
        } else {
            [routeMetadata setObject:@"walk" forKey:@"type"];
        }
    }

    NSMutableDictionary *wTransports = [[NSMutableDictionary alloc] init];

    for (NSString *key in transports) {
        [wTransports setObject:[transports valueForKey:key] forKey:key];
    }

    [routeMetadata setObject:wTransports forKey:@"transports"];
    NSMutableArray *points = [[NSMutableArray alloc] init];
//    MMKPolyline *subpolyline = MMKMakeSubpolyline(route.geometry, section.geometry);
//
//    for (int i = 0; i < [subpolyline.points count]; ++i) {
//        MMKPoint *point = [subpolyline.points objectAtIndex:i];
//        NSMutableDictionary *jsonPoint = [[NSMutableDictionary alloc] init];
//        [jsonPoint setValue:[NSNumber numberWithDouble:point.latitude] forKey:@"lat"];
//        [jsonPoint setValue:[NSNumber numberWithDouble:point.longitude] forKey:@"lon"];
//        [points addObject:jsonPoint];
//    }

    [routeMetadata setValue:points forKey:@"points"];

    return routeMetadata;
}

- (void)findRoutes:(NSArray<MMKRequestPoint *> *)_points vehicles:(NSArray<NSString *> *)vehicles withId:(NSString *)_id {
    __weak RNMView *weakSelf = self;

    if ([vehicles count] == 1 && [[vehicles objectAtIndex:0] isEqualToString:@"car"]) {
//        MMKDrivingDrivingOptions *drivingOptions = [[MMKDrivingDrivingOptions alloc] init];
//        MMKDrivingVehicleOptions *vehicleOptions = [[MMKDrivingVehicleOptions alloc] init];
//
//        drivingSession = [drivingRouter requestRoutesWithPoints:_points drivingOptions:drivingOptions
//                                                 vehicleOptions:vehicleOptions routeHandler:^(NSArray<MMKDrivingRoute *> *routes, NSError *error) {
//            RNMView *strongSelf = weakSelf;
//
//            if (error != nil) {
//                [strongSelf onReceiveNativeEvent: @{@"id": _id, @"status": @"error"}];
//                return;
//            }
//
//            NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
//            [response setValue:_id forKey:@"id"];
//            [response setValue:@"status" forKey:@"success"];
//            NSMutableArray* jsonRoutes = [[NSMutableArray alloc] init];
//
//            for (int i = 0; i < [routes count]; ++i) {
//                MMKDrivingRoute *_route = [routes objectAtIndex:i];
//                NSMutableDictionary *jsonRoute = [[NSMutableDictionary alloc] init];
//                [jsonRoute setValue:[NSString stringWithFormat:@"%d", i] forKey:@"id"];
//                NSMutableArray* sections = [[NSMutableArray alloc] init];
//                NSArray<MMKDrivingSection *> *_sections = [_route sections];
//                for (int j = 0; j < [_sections count]; ++j) {
//                    NSDictionary *jsonSection = [self convertDrivingRouteSection:_route withSection: [_sections objectAtIndex:j]];
//                    [sections addObject:jsonSection];
//                }
//                [jsonRoute setValue:sections forKey:@"sections"];
//                [jsonRoutes addObject:jsonRoute];
//            }
//
//            [response setValue:jsonRoutes forKey:@"routes"];
//            [strongSelf onReceiveNativeEvent: response];
//        }];

        return;
    }

    MMKMasstransitSessionRouteHandler _routeHandler = ^(NSArray<MMKMasstransitRoute *> *routes, NSError *error) {
        RNMView *strongSelf = weakSelf;
        if (error != nil) {
            [strongSelf onReceiveNativeEvent: @{@"id": _id, @"status": @"error"}];
            return;
        }
        NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
        [response setValue:_id forKey:@"id"];
        [response setValue:@"status" forKey:@"success"];
        NSMutableArray *jsonRoutes = [[NSMutableArray alloc] init];
        for (int i = 0; i < [routes count]; ++i) {
            MMKMasstransitRoute *_route = [routes objectAtIndex:i];
            NSMutableDictionary *jsonRoute = [[NSMutableDictionary alloc] init];

            [jsonRoute setValue:[NSString stringWithFormat:@"%d", i] forKey:@"id"];
            NSMutableArray *sections = [[NSMutableArray alloc] init];
            NSArray<MMKMasstransitSection *> *_sections = [_route sections];
            for (int j = 0; j < [_sections count]; ++j) {
                NSDictionary *jsonSection = [self convertRouteSection:_route withSection: [_sections objectAtIndex:j]];
                [sections addObject:jsonSection];
            }
            [jsonRoute setValue:sections forKey:@"sections"];
            [jsonRoutes addObject:jsonRoute];
        }
        [response setValue:jsonRoutes forKey:@"routes"];
        [strongSelf onReceiveNativeEvent: response];
    };

    if ([vehicles count] == 0) {
        walkSession = [pedestrianRouter requestRoutesWithPoints:_points timeOptions:[[MMKTimeOptions alloc] init] routeHandler:_routeHandler];
        return;
    }

    MMKTransitOptions *_transitOptions = [MMKTransitOptions transitOptionsWithAvoid:MMKFilterVehicleTypesNone timeOptions:[[MMKTimeOptions alloc] init]];
    masstransitSession = [masstransitRouter requestRoutesWithPoints:_points transitOptions:_transitOptions routeHandler:_routeHandler];
}

- (UIImage*)resolveUIImage:(NSString*)uri {
    UIImage *icon;

    if ([uri rangeOfString:@"http://"].location == NSNotFound && [uri rangeOfString:@"https://"].location == NSNotFound) {
        if ([uri rangeOfString:@"file://"].location != NSNotFound){
            NSString *file = [uri substringFromIndex:8];
            icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:file]]];
        } else {
            icon = [UIImage imageNamed:uri];
        }
    } else {
        icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:uri]]];
    }

    return icon;
}

- (void)onReceiveNativeEvent:(NSDictionary *)response {
    if (self.onRouteFound)
        self.onRouteFound(response);
}

- (void)removeAllSections {
    [self.mapWindow.map.mapObjects clear];
}

// REF
- (void)setCenter:(MMKCameraPosition *)position withDuration:(float)duration withAnimation:(int)animation {
    if (duration > 0) {
        MMKAnimationType anim = animation == 0 ? MMKAnimationTypeSmooth : MMKAnimationTypeLinear;
        [self.mapWindow.map moveWithCameraPosition:position animation:[MMKAnimation animationWithType:anim duration: duration] cameraCallback:^(BOOL completed) {}];
    } else {
        [self.mapWindow.map moveWithCameraPosition:position];
    }
}

- (void)setZoom:(float)zoom withDuration:(float)duration withAnimation:(int)animation {
    MMKCameraPosition *prevPosition = self.mapWindow.map.cameraPosition;
    MMKCameraPosition *position = [MMKCameraPosition cameraPositionWithTarget:prevPosition.target zoom:zoom azimuth:prevPosition.azimuth tilt:prevPosition.tilt];
    [self setCenter:position withDuration:duration withAnimation:animation];
}

- (void)setMapType:(NSString *)type {
    if ([type isEqual:@"none"]) {
        self.mapWindow.map.mapType = MMKMapTypeNone;
    } else if ([type isEqual:@"raster"]) {
        self.mapWindow.map.mapType = MMKMapTypeMap;
    } else {
        self.mapWindow.map.mapType = MMKMapTypeVectorMap;
    }
}

- (void)setInitialRegion:(NSDictionary *)initialParams {
    if ([initialParams valueForKey:@"lat"] == nil || [initialParams valueForKey:@"lon"] == nil) return;

    float initialZoom = 10.f;
    float initialAzimuth = 0.f;
    float initialTilt = 0.f;

    if ([initialParams valueForKey:@"zoom"] != nil) initialZoom = [initialParams[@"zoom"] floatValue];

    if ([initialParams valueForKey:@"azimuth"] != nil) initialTilt = [initialParams[@"azimuth"] floatValue];

    if ([initialParams valueForKey:@"tilt"] != nil) initialTilt = [initialParams[@"tilt"] floatValue];

    MMKPoint *initialRegionCenter = [RCTConvert MMKPoint:@{@"lat" : [initialParams valueForKey:@"lat"], @"lon" : [initialParams valueForKey:@"lon"]}];
    MMKCameraPosition *initialRegioPosition = [MMKCameraPosition cameraPositionWithTarget:initialRegionCenter zoom:initialZoom azimuth:initialAzimuth tilt:initialTilt];
    [self.mapWindow.map moveWithCameraPosition:initialRegioPosition];
}

- (void)setTrafficVisible:(BOOL)traffic {
    MMKMapKit *inst = [MMKMapKit sharedInstance];

    if (trafficLayer == nil) {
        trafficLayer = [inst createTrafficLayerWithMapWindow:self.mapWindow];
    }

    if (traffic) {
        [trafficLayer setTrafficVisibleWithOn:YES];
        [trafficLayer addTrafficListenerWithTrafficListener:self];
    } else {
        [trafficLayer setTrafficVisibleWithOn:NO];
        [trafficLayer removeTrafficListenerWithTrafficListener:self];
    }
}

- (NSDictionary *)cameraPositionToJSON:(MMKCameraPosition *)position reason:(MMKCameraUpdateReason)reason finished:(BOOL)finished {
    return @{
        @"azimuth": [NSNumber numberWithFloat:position.azimuth],
        @"tilt": [NSNumber numberWithFloat:position.tilt],
        @"zoom": [NSNumber numberWithFloat:position.zoom],
        @"point": @{
            @"lat": [NSNumber numberWithDouble:position.target.latitude],
            @"lon": [NSNumber numberWithDouble:position.target.longitude]
        },
        @"reason": reason == 0 ? @"GESTURES" : @"APPLICATION",
        @"finished": @(finished)
    };
}

- (NSDictionary *)worldPointToJSON:(MMKPoint *)point {
    return @{
        @"lat": [NSNumber numberWithDouble:point.latitude],
        @"lon": [NSNumber numberWithDouble:point.longitude]
    };
}

- (NSDictionary *)screenPointToJSON:(MMKScreenPoint *)point {
    return @{
        @"x": [NSNumber numberWithFloat:point.x],
        @"y": [NSNumber numberWithFloat:point.y]
    };
}

- (NSDictionary *)visibleRegionToJSON:(MMKVisibleRegion *)region {
    return @{
        @"bottomLeft": @{
            @"lat": [NSNumber numberWithDouble:region.bottomLeft.latitude],
            @"lon": [NSNumber numberWithDouble:region.bottomLeft.longitude]
        },
        @"bottomRight": @{
            @"lat": [NSNumber numberWithDouble:region.bottomRight.latitude],
            @"lon": [NSNumber numberWithDouble:region.bottomRight.longitude]
        },
        @"topLeft": @{
            @"lat": [NSNumber numberWithDouble:region.topLeft.latitude],
            @"lon": [NSNumber numberWithDouble:region.topLeft.longitude]
        },
        @"topRight": @{
            @"lat": [NSNumber numberWithDouble:region.topRight.latitude],
            @"lon": [NSNumber numberWithDouble:region.topRight.longitude]
        }
    };
}

- (void)emitCameraPositionToJS:(NSString *)_id {
    MMKCameraPosition *position = self.mapWindow.map.cameraPosition;
    NSDictionary *cameraPosition = [self cameraPositionToJSON:position reason:1 finished:YES];
    NSMutableDictionary *response = [NSMutableDictionary dictionaryWithDictionary:cameraPosition];
    [response setValue:_id forKey:@"id"];

    if (self.onCameraPositionReceived) {
        self.onCameraPositionReceived(response);
    }
}

- (void)emitVisibleRegionToJS:(NSString *)_id {
    MMKVisibleRegion *region = self.mapWindow.map.visibleRegion;
    NSDictionary *visibleRegion = [self visibleRegionToJSON:region];
    NSMutableDictionary *response = [NSMutableDictionary dictionaryWithDictionary:visibleRegion];
    [response setValue:_id forKey:@"id"];

    if (self.onVisibleRegionReceived) {
        self.onVisibleRegionReceived(response);
    }
}

- (void)emitWorldToScreenPoint:(NSArray<MMKPoint *> *)worldPoints withId:(NSString *)_id {
    NSMutableArray *screenPoints = [[NSMutableArray alloc] init];

    for (int i = 0; i < [worldPoints count]; ++i) {
        MMKScreenPoint *screenPoint = [self.mapWindow worldToScreenWithWorldPoint:[worldPoints objectAtIndex:i]];
        [screenPoints addObject:[self screenPointToJSON:screenPoint]];
    }

    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
    [response setValue:_id forKey:@"id"];
    [response setValue:screenPoints forKey:@"screenPoints"];

    if (self.onWorldToScreenPointsReceived) {
        self.onWorldToScreenPointsReceived(response);
    }
}

- (void)emitScreenToWorldPoint:(NSArray<MMKScreenPoint *> *)screenPoints withId:(NSString *)_id {
    NSMutableArray *worldPoints = [[NSMutableArray alloc] init];

    for (int i = 0; i < [screenPoints count]; ++i) {
        MMKPoint *worldPoint = [self.mapWindow screenToWorldWithScreenPoint:[screenPoints objectAtIndex:i]];
        [worldPoints addObject:[self worldPointToJSON:worldPoint]];
    }

    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
    [response setValue:_id forKey:@"id"];
    [response setValue:worldPoints forKey:@"worldPoints"];

    if (self.onScreenToWorldPointsReceived) {
        self.onScreenToWorldPointsReceived(response);
    }
}

- (void)onCameraPositionChangedWithMap:(nonnull MMKMap*)map
                        cameraPosition:(nonnull MMKCameraPosition*)cameraPosition
                    cameraUpdateReason:(MMKCameraUpdateReason)cameraUpdateReason
                              finished:(BOOL)finished {
    if (self.onCameraPositionChange) {
        self.onCameraPositionChange([self cameraPositionToJSON:cameraPosition reason:cameraUpdateReason finished:finished]);
    }

    if (self.onCameraPositionChangeEnd && finished) {
        self.onCameraPositionChangeEnd([self cameraPositionToJSON:cameraPosition reason:cameraUpdateReason finished:finished]);
    }
}

- (void)setNightMode:(BOOL)nightMode {
    [self.mapWindow.map setNightModeEnabled:nightMode];
}


- (void)setListenUserLocation:(BOOL) listen {
    MMKMapKit *inst = [MMKMapKit sharedInstance];

    if (userLayer == nil) {
        userLayer = [inst createUserLocationLayerWithMapWindow:self.mapWindow];
    }

    if (listen) {
        [userLayer setVisibleWithOn:YES];
        [userLayer setObjectListenerWithObjectListener:self];
    } else {
        [userLayer setVisibleWithOn:NO];
        [userLayer setObjectListenerWithObjectListener:nil];
    }
}

- (void)setFollowUser:(BOOL)follow {
    if (userLayer == nil) {
        [self setListenUserLocation: follow];
    }

    if (follow) {
        CGFloat scale = UIScreen.mainScreen.scale;
        [userLayer setAnchorWithAnchorNormal:CGPointMake(0.5 * self.mapWindow.width, 0.5 * self.mapWindow.height) anchorCourse:CGPointMake(0.5 * self.mapWindow.width, 0.83 * self.mapWindow.height )];
        [userLayer setAutoZoomEnabled:YES];
    } else {
        [userLayer setAutoZoomEnabled:NO];
        [userLayer resetAnchor];
    }
}

- (void)fitAllMarkers {
    NSMutableArray<MMKPoint *> *lastKnownMarkers = [[NSMutableArray alloc] init];

    for (int i = 0; i < [_reactSubviews count]; ++i) {
        UIView *view = [_reactSubviews objectAtIndex:i];

        if ([view isKindOfClass:[MappableMarkerView class]]) {
            MappableMarkerView *marker = (MappableMarkerView *)view;
            [lastKnownMarkers addObject:[marker getPoint]];
        }
    }

    [self fitMarkers:lastKnownMarkers];
}

- (NSArray<MMKPoint *> *)mapPlacemarksToPoints:(NSArray<MMKPlacemarkMapObject *> *)placemarks {
    NSMutableArray<MMKPoint *> *points = [[NSMutableArray alloc] init];

    for (int i = 0; i < [placemarks count]; ++i) {
        [points addObject:[[placemarks objectAtIndex:i] geometry]];
    }

    return points;
}

- (MMKBoundingBox *)calculateBoundingBox:(NSArray<MMKPoint *> *) points {
    double minLon = [points[0] longitude], maxLon = [points[0] longitude];
    double minLat = [points[0] latitude], maxLat = [points[0] latitude];

    for (int i = 0; i < [points count]; i++) {
        if ([points[i] longitude] > maxLon) maxLon = [points[i] longitude];
        if ([points[i] longitude] < minLon) minLon = [points[i] longitude];
        if ([points[i] latitude] > maxLat) maxLat = [points[i] latitude];
        if ([points[i] latitude] < minLat) minLat = [points[i] latitude];
    }

    MMKPoint *southWest = [MMKPoint pointWithLatitude:minLat longitude:minLon];
    MMKPoint *northEast = [MMKPoint pointWithLatitude:maxLat longitude:maxLon];
    MMKBoundingBox *boundingBox = [MMKBoundingBox boundingBoxWithSouthWest:southWest northEast:northEast];
    return boundingBox;
}

- (void)fitMarkers:(NSArray<MMKPoint *> *) points {
    if ([points count] == 1) {
        MMKPoint *center = [points objectAtIndex:0];
        [self.mapWindow.map moveWithCameraPosition:[MMKCameraPosition cameraPositionWithTarget:center zoom:15 azimuth:0 tilt:0]];
        return;
    }
    MMKCameraPosition *cameraPosition = [self.mapWindow.map cameraPositionWithGeometry:[MMKGeometry geometryWithBoundingBox:[self calculateBoundingBox:points]]];
    cameraPosition = [MMKCameraPosition cameraPositionWithTarget:cameraPosition.target zoom:cameraPosition.zoom - 0.8f azimuth:cameraPosition.azimuth tilt:cameraPosition.tilt];
    [self.mapWindow.map moveWithCameraPosition:cameraPosition animation:[MMKAnimation animationWithType:MMKAnimationTypeSmooth duration:1.0] cameraCallback:^(BOOL completed){}];
}

- (void)setLogoPosition:(NSDictionary *)logoPosition {
    MMKLogoHorizontalAlignment *horizontalAlignment = MMKLogoHorizontalAlignmentRight;
    MMKLogoVerticalAlignment *verticalAlignment = MMKLogoVerticalAlignmentBottom;

    if ([[logoPosition valueForKey:@"horizontal"] isEqual:@"left"]) {
        horizontalAlignment = MMKLogoHorizontalAlignmentLeft;
    } else if ([[logoPosition valueForKey:@"horizontal"] isEqual:@"center"]) {
        horizontalAlignment = MMKLogoHorizontalAlignmentCenter;
    }

    if ([[logoPosition valueForKey:@"vertical"] isEqual:@"top"]) {
        verticalAlignment = MMKLogoVerticalAlignmentTop;
    }

    [self.mapWindow.map.logo setAlignmentWithAlignment:[MMKLogoAlignment alignmentWithHorizontalAlignment:horizontalAlignment verticalAlignment:verticalAlignment]];
}

- (void)setLogoPadding:(NSDictionary *)logoPadding {
    NSUInteger horizontalPadding = [logoPadding valueForKey:@"horizontal"] != nil ? [RCTConvert NSUInteger:logoPadding[@"horizontal"]] : 0;
    NSUInteger verticalPadding = [logoPadding valueForKey:@"vertical"] != nil ? [RCTConvert NSUInteger:logoPadding[@"vertical"]] : 0;

    MMKLogoPadding *padding = [MMKLogoPadding paddingWithHorizontalPadding:horizontalPadding verticalPadding:verticalPadding];
    [self.mapWindow.map.logo setPaddingWithPadding:padding];
}

// PROPS
- (void)setUserLocationIcon:(NSString *)iconSource {
    userLocationImage = [self resolveUIImage:iconSource];
    [self updateUserIcon];
}

- (void)setUserLocationIconScale:(NSNumber *)iconScale {
    userLocationImageScale = iconScale;
    [self updateUserIcon];
}

- (void)setUserLocationAccuracyFillColor:(UIColor *)color {
    userLocationAccuracyFillColor = color;
    [self updateUserIcon];
}

- (void)setUserLocationAccuracyStrokeColor:(UIColor *)color {
    userLocationAccuracyStrokeColor = color;
    [self updateUserIcon];
}

- (void)setUserLocationAccuracyStrokeWidth:(float)width {
    userLocationAccuracyStrokeWidth = width;
    [self updateUserIcon];
}

- (void)updateUserIcon {
    if (userLocationView != nil) {
        if (userLocationImage) {
            MMKIconStyle *userIconStyle = [[MMKIconStyle alloc] init];
            [userIconStyle setScale:userLocationImageScale];

            [userLocationView.pin setIconWithImage:userLocationImage style:userIconStyle];
            [userLocationView.arrow setIconWithImage:userLocationImage style:userIconStyle];
        }

        MMKCircleMapObject* circle = userLocationView.accuracyCircle;

        if (userLocationAccuracyFillColor) {
            [circle setFillColor:userLocationAccuracyFillColor];
        }

        if (userLocationAccuracyStrokeColor) {
            [circle setStrokeColor:userLocationAccuracyStrokeColor];
        }

        [circle setStrokeWidth:userLocationAccuracyStrokeWidth];
    }
}

- (void)onObjectAddedWithView:(nonnull MMKUserLocationView *)view {
    userLocationView = view;
    [self updateUserIcon];
}

- (void)onObjectRemovedWithView:(nonnull MMKUserLocationView *)view {
}

- (void)onObjectUpdatedWithView:(nonnull MMKUserLocationView *)view event:(nonnull MMKObjectEvent *)event {
    userLocationView = view;
    [self updateUserIcon];
}

- (void)onMapTapWithMap:(nonnull MMKMap *)map
                  point:(nonnull MMKPoint *)point {
    if (self.onMapPress) {
        NSDictionary *data = @{
            @"lat": [NSNumber numberWithDouble:point.latitude],
            @"lon": [NSNumber numberWithDouble:point.longitude]
        };
        self.onMapPress(data);
    }
}

- (void)onMapLongTapWithMap:(nonnull MMKMap *)map
                      point:(nonnull MMKPoint *)point {
    if (self.onMapLongPress) {
        NSDictionary *data = @{
            @"lat": [NSNumber numberWithDouble:point.latitude],
            @"lon": [NSNumber numberWithDouble:point.longitude]
        };
        self.onMapLongPress(data);
    }
}

// UTILS
+ (UIColor*)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255)];
}

// CHILDREN
- (void)addSubview:(UIView *)view {
    [super addSubview:view];
}

- (void)insertReactSubview:(UIView<RCTComponent> *)subview atIndex:(NSInteger)atIndex {
    if ([subview isKindOfClass:[MappablePolygonView class]]) {
        MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
        MappablePolygonView *polygon = (MappablePolygonView *) subview;
        MMKPolygonMapObject *obj = [objects addPolygonWithPolygon:[polygon getPolygon]];
        [polygon setMapObject:obj];
    } else if ([subview isKindOfClass:[MappablePolylineView class]]) {
        MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
        MappablePolylineView *polyline = (MappablePolylineView*) subview;
        MMKPolylineMapObject *obj = [objects addPolylineWithPolyline:[polyline getPolyline]];
        [polyline setMapObject:obj];
    } else if ([subview isKindOfClass:[MappableMarkerView class]]) {
        MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
        MappableMarkerView *marker = (MappableMarkerView *) subview;
        MMKPlacemarkMapObject *obj = [objects addPlacemark];
        [marker setMapObject:obj];
    } else if ([subview isKindOfClass:[MappableCircleView class]]) {
        MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
        MappableCircleView *circle = (MappableCircleView*) subview;
        MMKCircleMapObject *obj = [objects addCircleWithCircle:[circle getCircle]];
        [circle setMapObject:obj];
    } else {
        NSArray<id<RCTComponent>> *childSubviews = [subview reactSubviews];
        for (int i = 0; i < childSubviews.count; i++) {
            [self insertReactSubview:(UIView *)childSubviews[i] atIndex:atIndex];
        }
    }

    [_reactSubviews insertObject:subview atIndex:atIndex];
    [super insertReactSubview:subview atIndex:atIndex];
}

- (void)insertMarkerReactSubview:(UIView<RCTComponent> *) subview atIndex:(NSInteger) atIndex {
    [_reactSubviews insertObject:subview atIndex:atIndex];
    [super insertReactSubview:subview atIndex:atIndex];
}

- (void)removeMarkerReactSubview:(UIView<RCTComponent> *) subview {
    [_reactSubviews removeObject:subview];
    [super removeReactSubview: subview];
}

- (void)removeReactSubview:(UIView<RCTComponent> *)subview {
    if ([subview isKindOfClass:[MappablePolygonView class]]) {
        MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
        MappablePolygonView *polygon = (MappablePolygonView *) subview;
        [objects removeWithMapObject:[polygon getMapObject]];
    } else if ([subview isKindOfClass:[MappablePolylineView class]]) {
        MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
        MappablePolylineView *polyline = (MappablePolylineView *) subview;
        [objects removeWithMapObject:[polyline getMapObject]];
    } else if ([subview isKindOfClass:[MappableMarkerView class]]) {
        MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
        MappableMarkerView *marker = (MappableMarkerView *) subview;
        [objects removeWithMapObject:[marker getMapObject]];
    } else if ([subview isKindOfClass:[MappableCircleView class]]) {
        MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
        MappableCircleView *circle = (MappableCircleView *) subview;
        [objects removeWithMapObject:[circle getMapObject]];
    } else {
        NSArray<id<RCTComponent>> *childSubviews = [subview reactSubviews];
        for (int i = 0; i < childSubviews.count; i++) {
            [self removeReactSubview:(UIView *)childSubviews[i]];
        }
    }

    [_reactSubviews removeObject:subview];
    [super removeReactSubview: subview];
}

- (void)onMapLoadedWithStatistics:(MMKMapLoadStatistics*)statistics {
    if (self.onMapLoaded) {
        NSDictionary *data = @{
            @"renderObjectCount": @(statistics.renderObjectCount),
            @"curZoomModelsLoaded": @(statistics.curZoomModelsLoaded),
            @"curZoomPlacemarksLoaded": @(statistics.curZoomPlacemarksLoaded),
            @"curZoomLabelsLoaded": @(statistics.curZoomLabelsLoaded),
            @"curZoomGeometryLoaded": @(statistics.curZoomGeometryLoaded),
            @"tileMemoryUsage": @(statistics.tileMemoryUsage),
            @"delayedGeometryLoaded": @(statistics.delayedGeometryLoaded),
            @"fullyAppeared": @(statistics.fullyAppeared),
            @"fullyLoaded": @(statistics.fullyLoaded),
        };
        self.onMapLoaded(data);
    }
}

- (void)reactSetFrame:(CGRect)frame {
    self.mapFrame = frame;
    [super reactSetFrame:frame];
}

- (void)layoutMarginsDidChange {
    [super reactSetFrame:self.mapFrame];
}

- (void)setMaxFps:(float)maxFps {
//    [self.mapWindow setMaxFpsWithFps:maxFps];
}

- (void)setInteractive:(BOOL)interactive {
    [self setNoninteractive:!interactive];
}


@synthesize reactTag;

@end
