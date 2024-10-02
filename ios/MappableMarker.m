#import <React/RCTViewManager.h>
#import <MapKit/MapKit.h>
#import <math.h>
#import "MappableMarker.h"
#import "RNMappable.h"

#import "View/MappableMarkerView.h"
#import "View/RNMView.h"

#import "Converter/RCTConvert+Mappable.m"

#ifndef MAX
#import <NSObjCRuntime.h>
#endif

@implementation MappableMarker

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
    return [[MappableMarkerView alloc] init];
}

// PROPS
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY (point, MMKPoint, MappableMarkerView) {
    if (json != nil) {
        [view setPoint: [RCTConvert MMKPoint:json]];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(scale, NSNumber, MappableMarkerView) {
    [view setScale: json];
}

RCT_CUSTOM_VIEW_PROPERTY(rotated, NSNumber, MappableMarkerView) {
    [view setRotated: json];
}

RCT_CUSTOM_VIEW_PROPERTY(visible, NSNumber, MappableMarkerView) {
    [view setVisible: json];
}

RCT_CUSTOM_VIEW_PROPERTY(handled, NSNumber, MappableMarkerView) {
    if (json == nil || [json boolValue]) {
        [view setHandled: YES];
    } else {
        [view setHandled: NO];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(anchor, NSDictionary, MappableMarkerView) {
    CGPoint point;

    if (json) {
        CGFloat x = [[json valueForKey:@"x"] doubleValue];
        CGFloat y = [[json valueForKey:@"y"] doubleValue];
        point = CGPointMake(x, y);
    } else {
        point = CGPointMake(0.5, 0.5);
    }

    [view setAnchor: [NSValue valueWithCGPoint:point]];
}

RCT_CUSTOM_VIEW_PROPERTY(zIndex, NSNumber, MappableMarkerView) {
    [view setZIndex: json];
}

RCT_CUSTOM_VIEW_PROPERTY(source, NSString, MappableMarkerView) {
    [view setSource: json];
}

// REF
RCT_EXPORT_METHOD(animatedMoveTo:(nonnull NSNumber*)reactTag json:(NSDictionary*)json duration:(NSNumber*_Nonnull)duration) {
    @try  {
        [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber*, UIView*> *viewRegistry) {
            MappableMarkerView* view = (MappableMarkerView*)viewRegistry[reactTag];

            if (!view || ![view isKindOfClass:[MappableMarkerView class]]) {
                RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
                return;
            }

            MMKPoint* point = [RCTConvert MMKPoint:json];
            [view animatedMoveTo:point withDuration:[duration floatValue]];
        }];
    } @catch (NSException *exception) {
        NSLog(@"Reason: %@ ",exception.reason);
    }
}

RCT_EXPORT_METHOD(animatedRotateTo:(nonnull NSNumber*)reactTag  angle:(NSNumber*_Nonnull)angle duration:(NSNumber*_Nonnull)duration) {
    @try  {
        [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber*, UIView*> *viewRegistry) {
            MappableMarkerView* view = (MappableMarkerView*)viewRegistry[reactTag];

            if (!view || ![view isKindOfClass:[MappableMarkerView class]]) {
                RCTLogError(@"Cannot find NativeView with tag #%@", reactTag);
                return;
            }

            [view animatedRotateTo:[angle floatValue] withDuration:[duration floatValue]];
        }];
    } @catch (NSException *exception) {
        NSLog(@"Reason: %@ ",exception.reason);
    }
}

@end
