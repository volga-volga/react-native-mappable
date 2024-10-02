#ifndef MappableCircleView_h
#define MappableCircleView_h
#import <React/RCTComponent.h>
@import MappableMobile;

@interface MappableCircleView: UIView<MMKMapObjectTapListener>

@property (nonatomic, copy) RCTBubblingEventBlock onPress;

// PROPS
- (void)setFillColor:(UIColor*)color;
- (void)setStrokeColor:(UIColor*)color;
- (void)setStrokeWidth:(NSNumber*)width;
- (void)setZIndex:(NSNumber*)_zIndex;
- (void)setCircleCenter:(MMKPoint*)center;
- (void)setRadius:(float)radius;
- (MMKCircle*)getCircle;
- (MMKPolygonMapObject*)getMapObject;
- (void)setMapObject:(MMKCircleMapObject*)mapObject;
- (void)setHandled:(BOOL)_handled;

@end

#endif /* MappableCircleView */
