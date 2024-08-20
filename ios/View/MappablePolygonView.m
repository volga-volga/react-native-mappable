#import <React/RCTComponent.h>

#import <MapKit/MapKit.h>
@import MappableMobile;

#ifndef MAX
#import <NSObjCRuntime.h>
#endif

#import "MappablePolygonView.h"


#define ANDROID_COLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:((c)&0xFF)/255.0  alpha:((c>>24)&0xFF)/255.0]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation MappablePolygonView {
    NSMutableArray<MMKPoint*>* _points;
    NSArray<NSArray<MMKPoint*>*>* innerRings;
    MMKPolygonMapObject* mapObject;
    MMKPolygon* polygon;
    UIColor* fillColor;
    UIColor* strokeColor;
    NSNumber* strokeWidth;
    NSNumber* zIndex;
}

- (instancetype)init {
    self = [super init];
    fillColor = UIColor.blackColor;
    strokeColor = UIColor.blackColor;
    zIndex = [[NSNumber alloc] initWithInt:1];
    strokeWidth = [[NSNumber alloc] initWithInt:1];
    _points = [[NSMutableArray alloc] init];
    innerRings = [[NSMutableArray alloc] init];
    polygon = [MMKPolygon polygonWithOuterRing:[MMKLinearRing linearRingWithPoints:@[]] innerRings:@[]];

    return self;
}

- (void)updatePolygon {
    if (mapObject != nil) {
        [mapObject setGeometry:polygon];
        [mapObject setZIndex:[zIndex floatValue]];
        [mapObject setFillColor:fillColor];
        [mapObject setStrokeColor:strokeColor];
        [mapObject setStrokeWidth:[strokeWidth floatValue]];
    }
}

- (void)setFillColor:(UIColor*)color {
    fillColor = color;
    [self updatePolygon];
}

- (void)setStrokeColor:(UIColor*)color {
    strokeColor = color;
    [self updatePolygon];
}

- (void)setStrokeWidth:(NSNumber*)width {
    strokeWidth = width;
    [self updatePolygon];
}

- (void)setZIndex:(NSNumber*)_zIndex {
    zIndex = _zIndex;
    [self updatePolygon];
}

- (void)updatePolygonGeometry {
    MMKLinearRing* ring = [MMKLinearRing linearRingWithPoints:_points];
    NSMutableArray<MMKLinearRing*>* _innerRings = [[NSMutableArray alloc] init];

    for (int i = 0; i < [innerRings count]; ++i) {
        MMKLinearRing* iRing = [MMKLinearRing linearRingWithPoints:[innerRings objectAtIndex:i]];
        [_innerRings addObject:iRing];
    }
    polygon = [MMKPolygon polygonWithOuterRing:ring innerRings:_innerRings];
}

- (void)setPolygonPoints:(NSMutableArray<MMKPoint*>*)points {
    _points = points;
    [self updatePolygonGeometry];
    [self updatePolygon];
}

- (void)setInnerRings:(NSArray<NSArray<MMKPoint*>*>*)_innerRings {
    innerRings = _innerRings;
    [self updatePolygonGeometry];
    [self updatePolygon];
}

- (void)setMapObject:(MMKPolygonMapObject *)_mapObject {
    mapObject = _mapObject;
    [mapObject addTapListenerWithTapListener:self];
    [self updatePolygon];
}

- (BOOL)onMapObjectTapWithMapObject:(nonnull MMKMapObject*)mapObject point:(nonnull MMKPoint*)point {
    if (self.onPress)
        self.onPress(@{});

    return YES;
}

- (NSMutableArray<MMKPoint*>*)getPoints {
    return _points;
}

- (MMKPolygon*)getPolygon {
    return polygon;
}

- (MMKPolygonMapObject*)getMapObject {
    return mapObject;
}

@end
