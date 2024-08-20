#ifndef MappablePolygonView_h
#define MappablePolygonView_h
#import <React/RCTComponent.h>
@import MappableMobile;

@interface MappablePolygonView: UIView<MMKMapObjectTapListener>

@property (nonatomic, copy) RCTBubblingEventBlock onPress;

// PROPS
- (void)setFillColor:(UIColor*)color;
- (void)setStrokeColor:(UIColor*)color;
- (void)setStrokeWidth:(NSNumber*)width;
- (void)setZIndex:(NSNumber*)_zIndex;
- (void)setPolygonPoints:(NSArray<MMKPoint*>*)_points;
- (void)setInnerRings:(NSArray<NSArray<MMKPoint*>*>*)_innerRings;
- (NSMutableArray<MMKPoint*>*)getPoints;
- (MMKPolygon*)getPolygon;
- (MMKPolygonMapObject*)getMapObject;
- (void)setMapObject:(MMKPolygonMapObject*)mapObject;

@end

#endif /* MappablePoligonView */
