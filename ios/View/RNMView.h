#ifndef RNYMView_h
#define RNYMView_h
#import <React/RCTComponent.h>
#import <MapKit/MapKit.h>
@import MappableMobile;

@class RCTBridge;

@interface RNMView: MMKMapView<MMKUserLocationObjectListener, MMKMapCameraListener, RCTComponent, MMKMapLoadedListener, MMKTrafficDelegate>

@property (nonatomic, assign) CGRect mapFrame;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onRouteFound;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onCameraPositionReceived;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onVisibleRegionReceived;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onCameraPositionChange;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onCameraPositionChangeEnd;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onMapPress;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onMapLongPress;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onMapLoaded;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onWorldToScreenPointsReceived;
@property (nonatomic, copy) RCTBubblingEventBlock _Nullable onScreenToWorldPointsReceived;

// REF
- (void)emitCameraPositionToJS:(NSString *_Nonnull)_id;
- (void)emitVisibleRegionToJS:(NSString *_Nonnull)_id;
- (void)setCenter:(MMKCameraPosition *_Nonnull)position withDuration:(float)duration withAnimation:(int)animation;
- (void)setZoom:(float)zoom withDuration:(float)duration withAnimation:(int)animation;
- (void)fitAllMarkers;
- (void)fitMarkers:(NSArray<MMKPoint *> *_Nonnull)points;
- (void)findRoutes:(NSArray<MMKRequestPoint *> *_Nonnull)points vehicles:(NSArray<NSString *> *_Nonnull)vehicles withId:(NSString *_Nonnull)_id;
- (void)setTrafficVisible:(BOOL)traffic;
- (void)emitWorldToScreenPoint:(NSArray<MMKPoint *> *_Nonnull)points withId:(NSString*_Nonnull)_id;
- (void)emitScreenToWorldPoint:(NSArray<MMKScreenPoint *> *_Nonnull)points withId:(NSString*_Nonnull)_id;
- (MMKBoundingBox *_Nonnull)calculateBoundingBox:(NSArray<MMKPoint *> *_Nonnull)points;

// PROPS
- (void)setNightMode:(BOOL)nightMode;
- (void)setClusters:(BOOL)userClusters;
- (void)setListenUserLocation:(BOOL)listen;
- (void)setUserLocationIcon:(NSString *_Nullable)iconSource;
- (void)setUserLocationIconScale:(NSNumber *_Nullable)iconScale;
- (void)setUserLocationAccuracyFillColor:(UIColor *_Nullable)color;
- (void)setUserLocationAccuracyStrokeColor:(UIColor *_Nullable)color;
- (void)setUserLocationAccuracyStrokeWidth:(float)width;
- (void)setMapType:(NSString *_Nullable)type;
- (void)setInitialRegion:(NSDictionary *_Nullable)initialRegion;
- (void)setMaxFps:(float)maxFps;
- (void)setInteractive:(BOOL)interactive;
- (void)insertMarkerReactSubview:(UIView *_Nullable)subview atIndex:(NSInteger)atIndex;
- (void)removeMarkerReactSubview:(UIView *_Nullable)subview;
- (void)setFollowUser:(BOOL)follow;
- (void)setLogoPosition:(NSDictionary *_Nullable)logoPosition;
- (void)setLogoPadding:(NSDictionary *_Nullable)logoPadding;

@end

#endif /* RNYMView_h */
