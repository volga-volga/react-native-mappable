#ifndef MappablePolylineView_h
#define MappablePolylineView_h
#import <React/RCTComponent.h>
@import MappableMobile;

@interface MappablePolylineView: UIView<MMKMapObjectTapListener>

@property (nonatomic, copy) RCTBubblingEventBlock onPress;

// PROPS
- (void)setOutlineColor:(UIColor*)color;
- (void)setStrokeColor:(UIColor*)color;
- (void)setStrokeWidth:(NSNumber*)width;
- (void)setDashLength:(NSNumber*)length;
- (void)setGapLength:(NSNumber*)length;
- (void)setDashOffset:(NSNumber*)offset;
- (void)setOutlineWidth:(NSNumber*)width;
- (void)setZIndex:(NSNumber*)_zIndex;
- (void)setHandled:(BOOL)_handled;
- (void)setPolylinePoints:(NSArray<MMKPoint*>*)_points;
- (NSMutableArray<MMKPoint*>*)getPoints;
- (MMKPolyline*)getPolyline;
- (MMKPolylineMapObject*)getMapObject;
- (void)setMapObject:(MMKPolylineMapObject*)mapObject;

@end

#endif /* MappablePolylineView */
