#import <React/RCTComponent.h>

#import <MapKit/MapKit.h>
@import MappableMobile;

#ifndef MAX
#import <NSObjCRuntime.h>
#endif

#import "MappableCircleView.h"


#define ANDROID_COLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:((c)&0xFF)/255.0  alpha:((c>>24)&0xFF)/255.0]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation MappableCircleView {
    MMKPoint* center;
    float radius;
    MMKCircleMapObject* mapObject;
    MMKCircle* circle;
    UIColor* fillColor;
    UIColor* strokeColor;
    NSNumber* strokeWidth;
    NSNumber* zIndex;
    BOOL handled;
}

- (instancetype)init {
    self = [super init];
    fillColor = UIColor.blackColor;
    strokeColor = UIColor.blackColor;
    zIndex = [[NSNumber alloc] initWithInt:1];
    strokeWidth = [[NSNumber alloc] initWithInt:1];
    center = [MMKPoint pointWithLatitude:0 longitude:0];
    radius = 0.f;
    handled = YES;
    circle = [MMKCircle circleWithCenter:center radius:radius];

    return self;
}

- (void)updateCircle {
    if (mapObject != nil) {
        [mapObject setGeometry:circle];
        [mapObject setZIndex:[zIndex floatValue]];
        [mapObject setFillColor:fillColor];
        [mapObject setStrokeColor:strokeColor];
        [mapObject setStrokeWidth:[strokeWidth floatValue]];
    }
}

- (void)setFillColor:(UIColor*)color {
    fillColor = color;
    [self updateCircle];
}

- (void)setStrokeColor:(UIColor*)color {
    strokeColor = color;
    [self updateCircle];
}

- (void)setStrokeWidth:(NSNumber*)width {
    strokeWidth = width;
    [self updateCircle];
}

- (void)setZIndex:(NSNumber*)_zIndex {
    zIndex = _zIndex;
    [self updateCircle];
}

- (void)updateGeometry {
    if (center) {
        circle = [MMKCircle circleWithCenter:center radius:radius];
    }
}

- (void)setCircleCenter:(MMKPoint*)point {
    center = point;
    [self updateGeometry];
    [self updateCircle];
}

- (void)setRadius:(float)_radius {
    radius = _radius;
    [self updateGeometry];
    [self updateCircle];
}

- (void)setMapObject:(MMKCircleMapObject*)_mapObject {
    mapObject = _mapObject;
    [mapObject addTapListenerWithTapListener:self];
    [self updateCircle];
}

- (void)setHandled:(BOOL)_handled {
    handled = _handled;
}

- (MMKCircle*)getCircle {
    return circle;
}

- (BOOL)onMapObjectTapWithMapObject:(nonnull MMKMapObject*)mapObject point:(nonnull MMKPoint*)point {
    if (self.onPress)
        self.onPress(@{});

    return handled;
}

- (MMKCircleMapObject*)getMapObject {
    return mapObject;
}

@end
