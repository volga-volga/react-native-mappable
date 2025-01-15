#import <React/RCTComponent.h>
#import <React/UIView+React.h>

#import <MapKit/MapKit.h>
@import MappableMobile;

#ifndef MAX
#import <NSObjCRuntime.h>
#endif

#import "MappableMarkerView.h"

#define ANDROID_COLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:((c)&0xFF)/255.0  alpha:((c>>24)&0xFF)/255.0]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define MAP_FRAMES_PER_SECOND 25

@implementation MappableMarkerView {
    MMKPoint* _point;
    MMKPlacemarkMapObject* mapObject;
    NSNumber* zIndex;
    NSNumber* scale;
    NSNumber* rotated;
    NSString* source;
    NSString* lastSource;
    NSValue* anchor;
    NSNumber* visible;
    NSMutableArray<UIView*>* _reactSubviews;
    UIView* _childView;
    BOOL handled;
}

- (instancetype)init {
    self = [super init];
    zIndex = [[NSNumber alloc] initWithInt:1];
    scale = [[NSNumber alloc] initWithInt:1];
    rotated = [[NSNumber alloc] initWithInt:0];
    visible = [[NSNumber alloc] initWithInt:1];
    _reactSubviews = [[NSMutableArray alloc] init];
    handled = YES;
    source = @"";
    lastSource = @"";

    return self;
}

- (void)updateMarker {
    if (mapObject != nil && mapObject.valid) {
        [mapObject setGeometry:_point];
        [mapObject setZIndex:[zIndex floatValue]];
        MMKIconStyle* iconStyle = [[MMKIconStyle alloc] init];
        [iconStyle setScale:scale];
        [iconStyle setVisible:visible];
        if (anchor) {
          [iconStyle setAnchor:anchor];
        }
        [iconStyle setRotationType:rotated];
        if ([_reactSubviews count] == 0) {
            if (![source isEqual:@""]) {
                if (![source isEqual:lastSource]) {
                    [self downloadImageFromURL:source completion:^(UIImage *image, NSError *error) {
                        if (error) {
                            NSLog(@"Error downloading image: %@", error.localizedDescription);
                        } else {
                            // Use the image (e.g., assign it to an UIImageView)
                            [self->mapObject setIconWithImage:image];
                            self->lastSource = self->source;
                            [self->mapObject setIconStyleWithStyle:iconStyle];
                        }
                    }];
                }
            }
        }
    }
}


- (void)updateClusterMarker {
    if (mapObject != nil && mapObject.valid) {
        [mapObject setGeometry:_point];
        [mapObject setZIndex:[zIndex floatValue]];
        MMKIconStyle* iconStyle = [[MMKIconStyle alloc] init];
        [iconStyle setScale:scale];
        [iconStyle setVisible:visible];
        if (anchor) {
            [iconStyle setAnchor:anchor];
        }
        [iconStyle setRotationType:rotated];
        if ([_reactSubviews count] == 0) {
            if (![source isEqualToString:@""] && source != nil) {
                [self downloadImageFromURL:source completion:^(UIImage *image, NSError *error) {
                    if (error) {
                        NSLog(@"Error downloading image: %@", error.localizedDescription);
                    } else {
                        // Use the image (e.g., assign it to an UIImageView)
                        if (image) {
                            [self->mapObject setIconWithImage:image];
                            self->lastSource = self->source;
                        }
                    }
                }];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setChildView];
            });
        }
    }
}

- (void)setScale:(NSNumber*)_scale {
    scale = _scale;
    [self updateMarker];
}
- (void)setRotated:(NSNumber*) _rotated {
    rotated = _rotated;
    [self updateMarker];
}

- (void)setZIndex:(NSNumber*)_zIndex {
    zIndex = _zIndex;
    [self updateMarker];
}

- (void)setVisible:(NSNumber*)_visible {
    visible = _visible;
    [self updateMarker];
}

- (void)setPoint:(MMKPoint*)point {
    _point = point;
    [self updateMarker];
}

- (void)downloadImageFromURL:(NSString *)urlString completion:(void (^)(UIImage *image, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSError *urlError = [NSError errorWithDomain:@"InvalidURLError" code:0 userInfo:@{NSLocalizedDescriptionKey: @"The URL is invalid."}];
        completion(nil, urlError);
        return;
    }

    // Asynchronous download
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error); // Pass the error back
            return;
        }

        // Convert the data into an image
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image, nil); // Pass the image back on the main thread
            });
        } else {
            NSError *imageError = [NSError errorWithDomain:@"ImageErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Failed to convert data to image."}];
            completion(nil, imageError);
        }
    }];

    [dataTask resume]; // Start the task
}

- (void)setSource:(NSString*)_source {
    source = _source;
    [self updateMarker];
}

- (void)setMapObject:(MMKPlacemarkMapObject *)_mapObject {
    mapObject = _mapObject;
    [mapObject addTapListenerWithTapListener:self];
    [self updateMarker];
}

- (void)setClusterMapObject:(MMKPlacemarkMapObject *)_mapObject {
    mapObject = _mapObject;
    [mapObject addTapListenerWithTapListener:self];
    [self updateMarker];
}

- (void)setHandled:(BOOL)_handled {
    handled = _handled;
}

// object tap listener
- (BOOL)onMapObjectTapWithMapObject:(nonnull MMKMapObject*)_mapObject point:(nonnull MMKPoint*)point {
    if (self.onPress)
        self.onPress(@{});

    return handled;
}

- (MMKPoint*)getPoint {
    return _point;
}

- (void)setAnchor:(NSValue*)_anchor {
    anchor = _anchor;
}

- (MMKPlacemarkMapObject*)getMapObject {
    return mapObject;
}

- (void)setChildView {
    if ([_reactSubviews count] > 0) {
        _childView = [_reactSubviews objectAtIndex:0];
        if (_childView != nil) {
            [_childView setOpaque:false];
            MRTViewProvider* v = [[MRTViewProvider alloc] initWithUIView:_childView];
            if (v != nil) {
                if (mapObject.isValid) {
                    [mapObject setViewWithView:v];
                    [self updateMarker];
                }
            }
        }
    } else {
        _childView = nil;
    }
}

- (void)didUpdateReactSubviews {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setChildView];
    });
}

- (void)insertReactSubview:(UIView*)subview atIndex:(NSInteger)atIndex {
    [_reactSubviews insertObject:subview atIndex: atIndex];
    [super insertReactSubview:subview atIndex:atIndex];
}

- (void)removeReactSubview:(UIView*)subview {
    [_reactSubviews removeObject:subview];
    [super removeReactSubview: subview];
}

- (void)moveAnimationLoop:(NSInteger)frame withTotalFrames:(NSInteger)totalFrames withDeltaLat:(double)deltaLat withDeltaLon:(double)deltaLon {
    @try  {
        MMKPlacemarkMapObject *placemark = [self getMapObject];
        MMKPoint* p = placemark.geometry;
        placemark.geometry = [MMKPoint pointWithLatitude:p.latitude + deltaLat/totalFrames
                                            longitude:p.longitude + deltaLon/totalFrames];

        if (frame < totalFrames) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / MAP_FRAMES_PER_SECOND), dispatch_get_main_queue(), ^{
                [self moveAnimationLoop: frame+1 withTotalFrames:totalFrames withDeltaLat:deltaLat withDeltaLon:deltaLon];
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"Reason: %@ ",exception.reason);
    }
}

- (void)rotateAnimationLoop:(NSInteger)frame withTotalFrames:(NSInteger)totalFrames withDelta:(double)delta {
    @try  {
        MMKPlacemarkMapObject *placemark = [self getMapObject];
        float dir = placemark.direction;
        float nextDir = placemark.direction+(delta / totalFrames);
        placemark.direction = nextDir;
        if (frame < totalFrames) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / MAP_FRAMES_PER_SECOND), dispatch_get_main_queue(), ^{
                [self rotateAnimationLoop: frame+1 withTotalFrames:totalFrames withDelta:delta];
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"Reason: %@ ",exception.reason);
    }
}

- (void)animatedMoveTo:(MMKPoint*)point withDuration:(float)duration {
    @try  {
        MMKPlacemarkMapObject* placemark = [self getMapObject];
        MMKPoint* p = placemark.geometry;
        double deltaLat = point.latitude - p.latitude;
        double deltaLon = point.longitude - p.longitude;
        [self moveAnimationLoop: 0 withTotalFrames:[@(duration / MAP_FRAMES_PER_SECOND) integerValue] withDeltaLat:deltaLat withDeltaLon:deltaLon];
    } @catch (NSException *exception) {
        NSLog(@"Reason: %@ ",exception.reason);
    }
}

- (void)animatedRotateTo:(float)angle withDuration:(float)duration {
    @try  {
        MMKPlacemarkMapObject* placemark = [self getMapObject];
        double delta = angle - placemark.direction;
        [self rotateAnimationLoop: 0 withTotalFrames:[@(duration / MAP_FRAMES_PER_SECOND) integerValue] withDelta:delta];
    } @catch (NSException *exception) {
        NSLog(@"Reason: %@ ",exception.reason);
    }
}

@synthesize reactTag;

@end
