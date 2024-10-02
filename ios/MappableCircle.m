#import <React/RCTViewManager.h>
#import <MapKit/MapKit.h>
#import <math.h>
#import "MappableCircle.h"
#import "RNMappable.h"

#import "View/MappableCircleView.h"
#import "View/RNMView.h"

#import "Converter/RCTConvert+Mappable.m"

#ifndef MAX
#import <NSObjCRuntime.h>
#endif

@implementation MappableCircle

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
    return [[MappableCircleView alloc] init];
}

// PROPS
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY (center, MMKPoint, MappableCircleView) {
   if (json != nil) {
       MMKPoint* point = [RCTConvert MMKPoint:json];
       [view setCircleCenter: point];
   }
}

RCT_CUSTOM_VIEW_PROPERTY (radius, NSNumber, MappableCircleView) {
   [view setRadius: [json floatValue]];
}

RCT_CUSTOM_VIEW_PROPERTY(fillColor, NSNumber, MappableCircleView) {
    [view setFillColor: [RCTConvert UIColor:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(strokeColor, NSNumber, MappableCircleView) {
    [view setStrokeColor: [RCTConvert UIColor:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(strokeWidth, NSNumber, MappableCircleView) {
    [view setStrokeWidth: json];
}

RCT_CUSTOM_VIEW_PROPERTY(zIndex, NSNumber, MappableCircleView) {
    [view setZIndex: json];
}

RCT_CUSTOM_VIEW_PROPERTY(handled, NSNumber, MappableCircleView) {
    if (json == nil || [json boolValue]) {
        [view setHandled: YES];
    } else {
        [view setHandled: NO];
    }
}

@end
