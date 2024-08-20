#ifndef RNCMView_h
#define RNCMView_h
#import <React/RCTComponent.h>

#import <MapKit/MapKit.h>
#import <RNMView.h>
@import MappableMobile;

@class RCTBridge;

@interface RNCMView: RNMView<MMKClusterListener, MMKClusterTapListener>

- (void)setClusterColor:(UIColor*_Nullable)color;
- (void)setClusteredMarkers:(NSArray<MMKRequestPoint*>*_Nonnull)points;
- (void)setInitialRegion:(NSDictionary *_Nullable)initialRegion;

@end

#endif /* RNMView_h */
