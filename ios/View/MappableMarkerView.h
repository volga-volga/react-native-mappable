#ifndef MappableMarkerView_h
#define MappableMarkerView_h
#import <React/RCTComponent.h>
@import MappableMobile;

@class RCTBridge;

@interface MappableMarkerView: UIView<MMKMapObjectTapListener, RCTComponent>

@property (nonatomic, copy) RCTBubblingEventBlock onPress;

// PROPS
- (void)setZIndex:(NSNumber*)_zIndex;
- (void)setScale:(NSNumber*)_scale;
- (void)setRotated:(NSNumber*)_rotation;
- (void)setSource:(NSString*)_source;
- (void)setPoint:(MMKPoint*)_points;
- (void)setAnchor:(NSValue*)_anchor;
- (void)setVisible:(NSNumber*)_visible;

// REF
- (void)animatedMoveTo:(MMKPoint*)point withDuration:(float)duration;
- (void)animatedRotateTo:(float)angle withDuration:(float)duration;
- (MMKPoint*)getPoint;
- (MMKPlacemarkMapObject*)getMapObject;
- (void)setMapObject:(MMKPlacemarkMapObject*)mapObject;
- (void)setClusterMapObject:(MMKPlacemarkMapObject*)mapObject;

@end

#endif /* MappableMarkerView_h */
