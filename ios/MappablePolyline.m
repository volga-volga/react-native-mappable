#import <React/RCTViewManager.h>
#import <MapKit/MapKit.h>
#import <math.h>
#import "MappablePolyline.h"
#import "RNMappable.h"

#import "View/MappablePolylineView.h"
#import "View/RNMView.h"

#import "Converter/RCTConvert+Mappable.m"

#ifndef MAX
#import <NSObjCRuntime.h>
#endif

@implementation MappablePolyline

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

- (UIView *_Nullable)view {
    return [[MappablePolylineView alloc] init];
}

// PROPS
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY (points, NSArray<MMKPoint>, MappablePolylineView) {
    if (json != nil) {
        [view setPolylinePoints: [RCTConvert Points:json]];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(outlineColor, NSNumber, MappablePolylineView) {
    [view setOutlineColor: [RCTConvert UIColor:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(strokeColor, NSNumber, MappablePolylineView) {
    [view setStrokeColor: [RCTConvert UIColor:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(strokeWidth, NSNumber, MappablePolylineView) {
    [view setStrokeWidth: json];
}

RCT_CUSTOM_VIEW_PROPERTY(dashLength, NSNumber, MappablePolylineView) {
    [view setDashLength: json];
}

RCT_CUSTOM_VIEW_PROPERTY(gapLength, NSNumber, MappablePolylineView) {
    [view setGapLength: json];
}

RCT_CUSTOM_VIEW_PROPERTY(dashOffset, NSNumber, MappablePolylineView) {
    [view setDashOffset: json];
}

RCT_CUSTOM_VIEW_PROPERTY(outlineWidth, NSNumber, MappablePolylineView) {
    [view setOutlineWidth: json];
}

RCT_CUSTOM_VIEW_PROPERTY(zIndex, NSNumber, MappablePolylineView) {
    [view setZIndex: json];
}

@end
