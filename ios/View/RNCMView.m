#import <React/RCTComponent.h>
#import <React/UIView+React.h>

#import <MapKit/MapKit.h>
#import "../Converter/RCTConvert+Mappable.m"
@import MappableMobile;

#ifndef MAX
#import <NSObjCRuntime.h>
#endif

#import "RNCMView.h"
#import <MappableMarkerView.h>

#define ANDROID_COLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:((c)&0xFF)/255.0  alpha:((c>>24)&0xFF)/255.0]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation RNCMView {
    MMKMasstransitSession *masstransitSession;
    MMKMasstransitSession *walkSession;
    MMKMasstransitRouter *masstransitRouter;
    MMKDrivingRouter* drivingRouter;
    MMKDrivingSession* drivingSession;
    MMKPedestrianRouter *pedestrianRouter;
    MMKTransitOptions *transitOptions;
    MMKMasstransitSessionRouteHandler routeHandler;
    NSMutableArray<UIView*>* _reactSubviews;
    NSMutableArray *routes;
    NSMutableArray *currentRouteInfo;
    NSMutableArray<MMKRequestPoint *>* lastKnownRoutePoints;
    MMKUserLocationView* userLocationView;
    NSMutableDictionary *vehicleColors;
    UIImage* userLocationImage;
    NSArray *acceptVehicleTypes;
    MMKUserLocationLayer *userLayer;
    UIColor* userLocationAccuracyFillColor;
    UIColor* userLocationAccuracyStrokeColor;
    float userLocationAccuracyStrokeWidth;
    MMKClusterizedPlacemarkCollection *clusterCollection;
    UIColor* clusterColor;
    NSMutableArray<MMKPlacemarkMapObject *>* placemarks;
    BOOL userClusters;
    Boolean initializedRegion;
}

- (instancetype)init {
    self = [super init];
    _reactSubviews = [[NSMutableArray alloc] init];
    placemarks = [[NSMutableArray alloc] init];
    clusterColor=nil;
    userClusters=NO;
    clusterCollection = [self.mapWindow.map.mapObjects addClusterizedPlacemarkCollectionWithClusterListener:self];
    initializedRegion = NO;
    return self;
}

- (void)setClusteredMarkers:(NSArray*) markers {
    [placemarks removeAllObjects];
    [clusterCollection clear];
    NSMutableArray<MMKPoint*> *newMarkers = [NSMutableArray new];
    for (NSDictionary *mark in markers) {
        [newMarkers addObject:[MMKPoint pointWithLatitude:[[mark objectForKey:@"lat"] doubleValue] longitude:[[mark objectForKey:@"lon"] doubleValue]]];
    }
    NSArray<MMKPlacemarkMapObject *>* newPlacemarks = [clusterCollection addPlacemarksWithPoints:newMarkers image:[self clusterImage:[NSNumber numberWithFloat:[newMarkers count]]] style:[MMKIconStyle new]];
    [placemarks addObjectsFromArray:newPlacemarks];
    for (int i=0; i<[placemarks count]; i++) {
        if (i<[_reactSubviews count]) {
            UIView *subview = [_reactSubviews objectAtIndex:i];
            if ([subview isKindOfClass:[MappableMarkerView class]]) {
                MappableMarkerView* marker = (MappableMarkerView*) subview;
                [marker setClusterMapObject:[placemarks objectAtIndex:i]];
            }
        }
    }
    [clusterCollection clusterPlacemarksWithClusterRadius:50 minZoom:12];
}

- (void)setClusterColor: (UIColor*) color {
    clusterColor = color;
}

- (void)onObjectRemovedWithView:(nonnull MMKUserLocationView *) view {
}

- (void)onMapTapWithMap:(nonnull MMKMap *) map
                  point:(nonnull MMKPoint *) point {
    if (self.onMapPress) {
        NSDictionary* data = @{
            @"lat": [NSNumber numberWithDouble:point.latitude],
            @"lon": [NSNumber numberWithDouble:point.longitude],
        };
        self.onMapPress(data);
    }
}

- (void)onMapLongTapWithMap:(nonnull MMKMap *) map
                      point:(nonnull MMKPoint *) point {
    if (self.onMapLongPress) {
        NSDictionary* data = @{
            @"lat": [NSNumber numberWithDouble:point.latitude],
            @"lon": [NSNumber numberWithDouble:point.longitude],
        };
        self.onMapLongPress(data);
    }
}

// utils
+ (UIColor*)colorFromHexString:(NSString*) hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString*)hexStringFromColor:(UIColor *) color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255)];
}

// children
- (void)addSubview:(UIView *) view {
    [super addSubview:view];
}

- (void)insertReactSubview:(UIView<RCTComponent>*) subview atIndex:(NSInteger) atIndex {
     if ([subview isKindOfClass:[MappableMarkerView class]]) {
        MappableMarkerView* marker = (MappableMarkerView*) subview;
         if (atIndex<[placemarks count]) {
             [marker setClusterMapObject:[placemarks objectAtIndex:atIndex]];
         }
    }
    [_reactSubviews insertObject:subview atIndex:atIndex];
    [super insertMarkerReactSubview:subview atIndex:atIndex];
}

- (void)removeReactSubview:(UIView<RCTComponent>*) subview {
     if ([subview isKindOfClass:[MappableMarkerView class]] && placemarks.count!=0) {
        MappableMarkerView* marker = (MappableMarkerView*) subview;
        [clusterCollection removeWithMapObject:[marker getMapObject]];
        [placemarks removeObjectIdenticalTo:[marker getMapObject]];
    } else {
        NSArray<id<RCTComponent>> *childSubviews = [subview reactSubviews];
        for (int i = 0; i < childSubviews.count; i++) {
            [self removeReactSubview:(UIView *)childSubviews[i]];
        }
    }
    [_reactSubviews removeObject:subview];
    [super removeMarkerReactSubview:subview];
}

-(UIImage*)clusterImage:(NSNumber*) clusterSize {
    float FONT_SIZE = 45;
    float MARGIN_SIZE = 9;
    float STROKE_SIZE = 9;
    NSString *text = [clusterSize stringValue];
    UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
    CGSize size = [text sizeWithFont:font];
    float textRadius = sqrt(size.height * size.height + size.width * size.width) / 2;
    float internalRadius = textRadius + MARGIN_SIZE;
    float externalRadius = internalRadius + STROKE_SIZE;
    // This function returns a newImage, based on image, that has been:
    // - scaled to fit in (CGRect) rect
    // - and cropped within a circle of radius: rectWidth/2

    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(externalRadius*2, externalRadius*2), NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [clusterColor CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, externalRadius*2, externalRadius*2));
    CGContextSetFillColorWithColor(context, [UIColor.whiteColor CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(STROKE_SIZE, STROKE_SIZE, internalRadius*2, internalRadius*2));
    [text drawInRect:CGRectMake(externalRadius - size.width/2, externalRadius - size.height/2, size.width, size.height) withAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.blackColor }];
       UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
       UIGraphicsEndImageContext();

       return newImage;
}

- (void)onClusterAddedWithCluster:(nonnull MMKCluster *)cluster {
    NSNumber *myNum = @([cluster size]);
    [[cluster appearance] setIconWithImage:[self clusterImage:myNum]];
    [cluster addClusterTapListenerWithClusterTapListener:self];
}

- (BOOL)onClusterTapWithCluster:(nonnull MMKCluster *)cluster {
    NSMutableArray<MMKPoint*>* lastKnownMarkers = [[NSMutableArray alloc] init];
    for (MMKPlacemarkMapObject *placemark in [cluster placemarks]) {
        [lastKnownMarkers addObject:[placemark geometry]];
    }
    [self fitMarkers:lastKnownMarkers];
    return YES;
}

- (void)setInitialRegion:(NSDictionary *)initialParams {
    if (initializedRegion) return;
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
    initializedRegion = YES;
}


@synthesize reactTag;

@end
