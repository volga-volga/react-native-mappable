#import <React/RCTViewManager.h>
#import <MapKit/MapKit.h>
#import <math.h>
#import "MappablePolygon.h"
#import "RNMappable.h"

#import "View/MappablePolygonView.h"
#import "View/RNMView.h"

#import "Converter/RCTConvert+Mappable.m"

#ifndef MAX
#import <NSObjCRuntime.h>
#endif

@implementation MappablePolygon

RCT_EXPORT_MODULE()

- (NSArray<NSString*>*)supportedEvents {
    return @[@"onPress"];
}

- (instancetype)init {
    self = [super init];

    return self;
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (UIView* _Nullable)view {
    return [[MappablePolygonView alloc] init];
}

// PROPS
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY (points, NSArray<MMKPoint>, MappablePolygonView) {
    if (json != nil) {
        [view setPolygonPoints: [RCTConvert Points:json]];
    }
}

RCT_CUSTOM_VIEW_PROPERTY (innerRings, NSArray<NSArray<MMKPoint>>, MappablePolygonView) {
    NSMutableArray* innerRings = [[NSMutableArray alloc] init];

    if (json != nil) {
        for (int i = 0; i < [(NSArray *)json count]; ++i) {
            [innerRings addObject:[RCTConvert Points:[json objectAtIndex:i]]];
        }
    }

    [view setInnerRings: innerRings];
}

RCT_CUSTOM_VIEW_PROPERTY(fillColor, NSNumber, MappablePolygonView) {
    [view setFillColor: [RCTConvert UIColor:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(strokeColor, NSNumber, MappablePolygonView) {
    [view setStrokeColor: [RCTConvert UIColor:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(strokeWidth, NSNumber, MappablePolygonView) {
    [view setStrokeWidth: json];
}

RCT_CUSTOM_VIEW_PROPERTY(zIndex, NSNumber, MappablePolygonView) {
    [view setZIndex: json];
}

@end
