"use strict";
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        if (typeof b !== "function" && b !== null)
            throw new TypeError("Class extends value " + String(b) + " is not a constructor or null");
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MappableMap = void 0;
var react_1 = __importDefault(require("react"));
var react_native_1 = require("react-native");
// @ts-ignore
var resolveAssetSource_1 = __importDefault(require("react-native/Libraries/Image/resolveAssetSource"));
var CallbacksManager_1 = __importDefault(require("../utils/CallbacksManager"));
var interfaces_1 = require("../interfaces");
var utils_1 = require("../utils");
var NativeMappableModule = react_native_1.NativeModules.mappable;
var MappableMapNativeComponent = (0, react_native_1.requireNativeComponent)('MappableView');
var MappableMap = /** @class */ (function (_super) {
    __extends(MappableMap, _super);
    function MappableMap() {
        var _this = _super !== null && _super.apply(this, arguments) || this;
        // @ts-ignore
        _this.map = react_1.default.createRef();
        return _this;
    }
    MappableMap.init = function (apiKey) {
        return NativeMappableModule.init(apiKey);
    };
    MappableMap.setLocale = function (locale) {
        return new Promise(function (resolve, reject) {
            NativeMappableModule.setLocale(locale, function () { return resolve(); }, function (err) { return reject(new Error(err)); });
        });
    };
    MappableMap.getLocale = function () {
        return new Promise(function (resolve, reject) {
            NativeMappableModule.getLocale(function (locale) { return resolve(locale); }, function (err) { return reject(new Error(err)); });
        });
    };
    MappableMap.resetLocale = function () {
        return new Promise(function (resolve, reject) {
            NativeMappableModule.resetLocale(function () { return resolve(); }, function (err) { return reject(new Error(err)); });
        });
    };
    MappableMap.prototype.findRoutes = function (points, vehicles, callback) {
        this._findRoutes(points, vehicles, callback);
    };
    MappableMap.prototype.findMasstransitRoutes = function (points, callback) {
        this._findRoutes(points, MappableMap.ALL_MASSTRANSIT_VEHICLES, callback);
    };
    MappableMap.prototype.findPedestrianRoutes = function (points, callback) {
        this._findRoutes(points, [], callback);
    };
    MappableMap.prototype.findDrivingRoutes = function (points, callback) {
        this._findRoutes(points, ['car'], callback);
    };
    MappableMap.prototype.fitAllMarkers = function () {
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('fitAllMarkers'), []);
    };
    MappableMap.prototype.setTrafficVisible = function (isVisible) {
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('setTrafficVisible'), [isVisible]);
    };
    MappableMap.prototype.fitMarkers = function (points) {
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('fitMarkers'), [points]);
    };
    MappableMap.prototype.setCenter = function (center, zoom, azimuth, tilt, duration, animation) {
        if (zoom === void 0) { zoom = center.zoom || 10; }
        if (azimuth === void 0) { azimuth = 0; }
        if (tilt === void 0) { tilt = 0; }
        if (duration === void 0) { duration = 0; }
        if (animation === void 0) { animation = interfaces_1.Animation.SMOOTH; }
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('setCenter'), [center, zoom, azimuth, tilt, duration, animation]);
    };
    MappableMap.prototype.setZoom = function (zoom, duration, animation) {
        if (duration === void 0) { duration = 0; }
        if (animation === void 0) { animation = interfaces_1.Animation.SMOOTH; }
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('setZoom'), [zoom, duration, animation]);
    };
    MappableMap.prototype.getCameraPosition = function (callback) {
        var cbId = CallbacksManager_1.default.addCallback(callback);
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('getCameraPosition'), [cbId]);
    };
    MappableMap.prototype.getVisibleRegion = function (callback) {
        var cbId = CallbacksManager_1.default.addCallback(callback);
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('getVisibleRegion'), [cbId]);
    };
    MappableMap.prototype.getScreenPoints = function (points, callback) {
        var cbId = CallbacksManager_1.default.addCallback(callback);
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('getScreenPoints'), [points, cbId]);
    };
    MappableMap.prototype.getWorldPoints = function (points, callback) {
        var cbId = CallbacksManager_1.default.addCallback(callback);
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('getWorldPoints'), [points, cbId]);
    };
    MappableMap.prototype._findRoutes = function (points, vehicles, callback) {
        var cbId = CallbacksManager_1.default.addCallback(callback);
        var args = react_native_1.Platform.OS === 'ios' ? [{ points: points, vehicles: vehicles, id: cbId }] : [points, vehicles, cbId];
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('findRoutes'), args);
    };
    MappableMap.prototype.getCommand = function (cmd) {
        return react_native_1.Platform.OS === 'ios' ? react_native_1.UIManager.getViewManagerConfig('MappableView').Commands[cmd] : cmd;
    };
    MappableMap.prototype.processRoute = function (event) {
        var _a = event.nativeEvent, id = _a.id, routes = __rest(_a, ["id"]);
        CallbacksManager_1.default.call(id, routes);
    };
    MappableMap.prototype.processCameraPosition = function (event) {
        var _a = event.nativeEvent, id = _a.id, point = __rest(_a, ["id"]);
        CallbacksManager_1.default.call(id, point);
    };
    MappableMap.prototype.processVisibleRegion = function (event) {
        var _a = event.nativeEvent, id = _a.id, visibleRegion = __rest(_a, ["id"]);
        CallbacksManager_1.default.call(id, visibleRegion);
    };
    MappableMap.prototype.processWorldToScreenPointsReceived = function (event) {
        var _a = event.nativeEvent, id = _a.id, screenPoints = __rest(_a, ["id"]);
        CallbacksManager_1.default.call(id, screenPoints);
    };
    MappableMap.prototype.processScreenToWorldPointsReceived = function (event) {
        var _a = event.nativeEvent, id = _a.id, worldPoints = __rest(_a, ["id"]);
        CallbacksManager_1.default.call(id, worldPoints);
    };
    MappableMap.prototype.resolveImageUri = function (img) {
        return img ? (0, resolveAssetSource_1.default)(img).uri : '';
    };
    MappableMap.prototype.getProps = function () {
        var props = __assign(__assign({}, this.props), { onRouteFound: this.processRoute, onCameraPositionReceived: this.processCameraPosition, onVisibleRegionReceived: this.processVisibleRegion, onWorldToScreenPointsReceived: this.processWorldToScreenPointsReceived, onScreenToWorldPointsReceived: this.processScreenToWorldPointsReceived, userLocationIcon: this.props.userLocationIcon ? this.resolveImageUri(this.props.userLocationIcon) : undefined });
        (0, utils_1.processColorProps)(props, 'clusterColor');
        (0, utils_1.processColorProps)(props, 'userLocationAccuracyFillColor');
        (0, utils_1.processColorProps)(props, 'userLocationAccuracyStrokeColor');
        return props;
    };
    MappableMap.prototype.render = function () {
        return (react_1.default.createElement(MappableMapNativeComponent, __assign({}, this.getProps(), { ref: this.map })));
    };
    MappableMap.defaultProps = {
        showUserPosition: true,
        clusterColor: 'red',
        maxFps: 60
    };
    MappableMap.ALL_MASSTRANSIT_VEHICLES = [
        'bus',
        'trolleybus',
        'tramway',
        'minibus',
        'suburban',
        'underground',
        'ferry',
        'cable',
        'funicular',
    ];
    return MappableMap;
}(react_1.default.Component));
exports.MappableMap = MappableMap;
// #import <React/RCTComponent.h>
// #import <React/UIView+React.h>
//
// #import <MapKit/MapKit.h>
// #import "../Converter/RCTConvert+Mappable.m"
// @import MappableMobile;
//
// #ifndef MAX
// #import <NSObjCRuntime.h>
// #endif
//
// #import "MappablePolygonView.h"
// #import "MappablePolylineView.h"
// #import "MappableCircleView.h"
// #import "RNCMView.h"
// #import <MappableMarkerView.h>
//
// #define ANDROID_COLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:((c)&0xFF)/255.0  alpha:((c>>24)&0xFF)/255.0]
//
// #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//
// @implementation RNCMView {
//   MMKMasstransitSession *masstransitSession;
//   MMKMasstransitSession *walkSession;
//   MMKMasstransitRouter *masstransitRouter;
//   MMKDrivingRouter* drivingRouter;
//   MMKDrivingSession* drivingSession;
//   MMKPedestrianRouter *pedestrianRouter;
//   MMKTransitOptions *transitOptions;
//   MMKMasstransitSessionRouteHandler routeHandler;
//   NSMutableArray<UIView*>* _reactSubviews;
//   NSMutableArray *routes;
//   NSMutableArray *currentRouteInfo;
//   NSMutableArray<MMKRequestPoint *>* lastKnownRoutePoints;
//   MMKUserLocationView* userLocationView;
//   NSMutableDictionary *vehicleColors;
//   UIImage* userLocationImage;
//   NSArray *acceptVehicleTypes;
//   MMKUserLocationLayer *userLayer;
//   UIColor* userLocationAccuracyFillColor;
//   UIColor* userLocationAccuracyStrokeColor;
//   float userLocationAccuracyStrokeWidth;
//   MMKClusterizedPlacemarkCollection *clusterCollection;
//   UIColor* clusterColor;
//   NSMutableArray<MMKPlacemarkMapObject *>* placemarks;
//   BOOL userClusters;
//   Boolean initializedRegion;
// }
//
// - (instancetype)init {
//   self = [super init];
//   _reactSubviews = [[NSMutableArray alloc] init];
//   placemarks = [[NSMutableArray alloc] init];
//   clusterColor=nil;
//   userClusters=NO;
//   clusterCollection = [self.mapWindow.map.mapObjects addClusterizedPlacemarkCollectionWithClusterListener:self];
//   initializedRegion = NO;
//   return self;
// }
//
// - (void)setClusteredMarkers:(NSArray*) markers {
//   [placemarks removeAllObjects];
//   [clusterCollection clear];
//   NSMutableArray<MMKPoint*> *newMarkers = [NSMutableArray new];
//   for (NSDictionary *mark in markers) {
//     [newMarkers addObject:[MMKPoint pointWithLatitude:[[mark objectForKey:@"lat"] doubleValue] longitude:[[mark objectForKey:@"lon"] doubleValue]]];
//   }
//   NSArray<MMKPlacemarkMapObject *>* newPlacemarks = [clusterCollection addPlacemarksWithPoints:newMarkers image:[self clusterImage:[NSNumber numberWithFloat:[newMarkers count]]] style:[MMKIconStyle new]];
//   [placemarks addObjectsFromArray:newPlacemarks];
//   for (int i=0; i<[placemarks count]; i++) {
//     if (i<[_reactSubviews count]) {
//       UIView *subview = [_reactSubviews objectAtIndex:i];
//       if ([subview isKindOfClass:[MappableMarkerView class]]) {
//         MappableMarkerView* marker = (MappableMarkerView*) subview;
//         [marker setClusterMapObject:[placemarks objectAtIndex:i]];
//       }
//     }
//   }
//   [clusterCollection clusterPlacemarksWithClusterRadius:50 minZoom:12];
// }
//
// - (void)setClusterColor: (UIColor*) color {
//   clusterColor = color;
// }
//
// - (void)onObjectRemovedWithView:(nonnull MMKUserLocationView *) view {
// }
//
// - (void)onMapTapWithMap:(nonnull MMKMap *) map
// point:(nonnull MMKPoint *) point {
//   if (self.onMapPress) {
//     NSDictionary* data = @{
//       @"lat": [NSNumber numberWithDouble:point.latitude],
//   @"lon": [NSNumber numberWithDouble:point.longitude],
//   };
//     self.onMapPress(data);
//   }
// }
//
// - (void)onMapLongTapWithMap:(nonnull MMKMap *) map
// point:(nonnull MMKPoint *) point {
//   if (self.onMapLongPress) {
//     NSDictionary* data = @{
//       @"lat": [NSNumber numberWithDouble:point.latitude],
//   @"lon": [NSNumber numberWithDouble:point.longitude],
//   };
//     self.onMapLongPress(data);
//   }
// }
//
// // utils
// + (UIColor*)colorFromHexString:(NSString*) hexString {
//   unsigned rgbValue = 0;
//   NSScanner *scanner = [NSScanner scannerWithString:hexString];
//   [scanner setScanLocation:1];
//   [scanner scanHexInt:&rgbValue];
//   return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
// }
//
// + (NSString*)hexStringFromColor:(UIColor *) color {
//   const CGFloat *components = CGColorGetComponents(color.CGColor);
//   CGFloat r = components[0];
//   CGFloat g = components[1];
//   CGFloat b = components[2];
//   return [NSString stringWithFormat:@"#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255)];
// }
//
// // children
// - (void)addSubview:(UIView *) view {
//   [super addSubview:view];
// }
//
// - (void)insertReactSubview:(UIView<RCTComponent>*) subview atIndex:(NSInteger) atIndex {
//   if ([subview isKindOfClass:[MappableMarkerView class]]) {
//     MappableMarkerView* marker = (MappableMarkerView*) subview;
//     if (atIndex<[placemarks count]) {
//       [marker setClusterMapObject:[placemarks objectAtIndex:atIndex]];
//     }
//   } else  if ([subview isKindOfClass:[MappablePolygonView class]]) {
//     MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
//     MappablePolygonView *polygon = (MappablePolygonView *) subview;
//     MMKPolygonMapObject *obj = [objects addPolygonWithPolygon:[polygon getPolygon]];
//     [polygon setMapObject:obj];
//   } else if ([subview isKindOfClass:[MappablePolylineView class]]) {
//     MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
//     MappablePolylineView *polyline = (MappablePolylineView*) subview;
//     MMKPolylineMapObject *obj = [objects addPolylineWithPolyline:[polyline getPolyline]];
//     [polyline setMapObject:obj];
//   } else if ([subview isKindOfClass:[MappableCircleView class]]) {
//     MMKMapObjectCollection *objects = self.mapWindow.map.mapObjects;
//     MappableCircleView *circle = (MappableCircleView*) subview;
//     MMKCircleMapObject *obj = [objects addCircleWithCircle:[circle getCircle]];
//     [circle setMapObject:obj];
//   } else {
//     NSArray<id<RCTComponent>> *childSubviews = [subview reactSubviews];
//     for (int i = 0; i < childSubviews.count; i++) {
//       [self insertReactSubview:(UIView *)childSubviews[i] atIndex:atIndex];
//     }
//   }
//   [_reactSubviews insertObject:subview atIndex:atIndex];
//   [super insertMarkerReactSubview:subview atIndex:atIndex];
// }
//
// - (void)removeReactSubview:(UIView<RCTComponent>*) subview {
//   if ([subview isKindOfClass:[MappableMarkerView class]] && placemarks.count!=0) {
//     MappableMarkerView* marker = (MappableMarkerView*) subview;
//     [clusterCollection removeWithMapObject:[marker getMapObject]];
//     [placemarks removeObjectIdenticalTo:[marker getMapObject]];
//   } else {
//     NSArray<id<RCTComponent>> *childSubviews = [subview reactSubviews];
//     for (int i = 0; i < childSubviews.count; i++) {
//       [self removeReactSubview:(UIView *)childSubviews[i]];
//     }
//   }
//   [_reactSubviews removeObject:subview];
//   [super removeMarkerReactSubview:subview];
// }
//
// -(UIImage*)clusterImage:(NSNumber*) clusterSize {
//   float FONT_SIZE = 45;
//   float MARGIN_SIZE = 9;
//   float STROKE_SIZE = 9;
//   NSString *text = [clusterSize stringValue];
//   UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
//   CGSize size = [text sizeWithFont:font];
//   float textRadius = sqrt(size.height * size.height + size.width * size.width) / 2;
//   float internalRadius = textRadius + MARGIN_SIZE;
//   float externalRadius = internalRadius + STROKE_SIZE;
//   // This function returns a newImage, based on image, that has been:
//   // - scaled to fit in (CGRect) rect
//   // - and cropped within a circle of radius: rectWidth/2
//
//   //Create the bitmap graphics context
//   UIGraphicsBeginImageContextWithOptions(CGSizeMake(externalRadius*2, externalRadius*2), NO, 1.0);
//   CGContextRef context = UIGraphicsGetCurrentContext();
//   CGContextSetFillColorWithColor(context, [clusterColor CGColor]);
//   CGContextFillEllipseInRect(context, CGRectMake(0, 0, externalRadius*2, externalRadius*2));
//   CGContextSetFillColorWithColor(context, [UIColor.whiteColor CGColor]);
//   CGContextFillEllipseInRect(context, CGRectMake(STROKE_SIZE, STROKE_SIZE, internalRadius*2, internalRadius*2));
//   [text drawInRect:CGRectMake(externalRadius - size.width/2, externalRadius - size.height/2, size.width, size.height) withAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.blackColor }];
//   UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//   UIGraphicsEndImageContext();
//
//   return newImage;
// }
//
// - (void)onClusterAddedWithCluster:(nonnull MMKCluster *)cluster {
//   NSNumber *myNum = @([cluster size]);
//   [[cluster appearance] setIconWithImage:[self clusterImage:myNum]];
//   [cluster addClusterTapListenerWithClusterTapListener:self];
// }
//
// - (BOOL)onClusterTapWithCluster:(nonnull MMKCluster *)cluster {
//   NSMutableArray<MMKPoint*>* lastKnownMarkers = [[NSMutableArray alloc] init];
//   for (MMKPlacemarkMapObject *placemark in [cluster placemarks]) {
//     [lastKnownMarkers addObject:[placemark geometry]];
//   }
//   [self fitMarkers:lastKnownMarkers];
//   return YES;
// }
//
// - (void)setInitialRegion:(NSDictionary *)initialParams {
//   if (initializedRegion) return;
//   if ([initialParams valueForKey:@"lat"] == nil || [initialParams valueForKey:@"lon"] == nil) return;
//
//   float initialZoom = 10.f;
//   float initialAzimuth = 0.f;
//   float initialTilt = 0.f;
//
//   if ([initialParams valueForKey:@"zoom"] != nil) initialZoom = [initialParams[@"zoom"] floatValue];
//
//   if ([initialParams valueForKey:@"azimuth"] != nil) initialTilt = [initialParams[@"azimuth"] floatValue];
//
//   if ([initialParams valueForKey:@"tilt"] != nil) initialTilt = [initialParams[@"tilt"] floatValue];
//
//   MMKPoint *initialRegionCenter = [RCTConvert MMKPoint:@{@"lat" : [initialParams valueForKey:@"lat"], @"lon" : [initialParams valueForKey:@"lon"]}];
//   MMKCameraPosition *initialRegioPosition = [MMKCameraPosition cameraPositionWithTarget:initialRegionCenter zoom:initialZoom azimuth:initialAzimuth tilt:initialTilt];
//   [self.mapWindow.map moveWithCameraPosition:initialRegioPosition];
//   initializedRegion = YES;
// }
//
//
// @synthesize reactTag;
//
// @end
//# sourceMappingURL=Mappable.js.map