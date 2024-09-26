import React from 'react';
import {
  Platform,
  requireNativeComponent,
  UIManager,
  findNodeHandle,
  ViewProps,
  ImageSourcePropType,
  NativeSyntheticEvent, NativeModules,
} from 'react-native';
// @ts-ignore
import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource';
import CallbacksManager from '../utils/CallbacksManager';
import {
  Point,
  ScreenPoint,
  DrivingInfo,
  MasstransitInfo,
  RoutesFoundEvent,
  Vehicles,
  CameraPosition,
  VisibleRegion,
  InitialRegion,
  Animation,
  MapLoaded,
  MappableLogoPosition,
  MappableLogoPadding
} from '../interfaces';
import { processColorProps } from '../utils';

const { mappable: NativeMappableModule } = NativeModules;

export interface MappableMapProps extends ViewProps {
  userLocationIcon?: ImageSourcePropType;
  userLocationIconScale?: number;
  showUserPosition?: boolean;
  nightMode?: boolean;
  mapStyle?: string;
  onCameraPositionChange?: (event: NativeSyntheticEvent<CameraPosition>) => void;
  onCameraPositionChangeEnd?: (event: NativeSyntheticEvent<CameraPosition>) => void;
  onMapPress?: (event: NativeSyntheticEvent<Point>) => void;
  onMapLongPress?: (event: NativeSyntheticEvent<Point>) => void;
  onMapLoaded?: (event: NativeSyntheticEvent<MapLoaded>) => void;
  userLocationAccuracyFillColor?: string;
  userLocationAccuracyStrokeColor?: string;
  userLocationAccuracyStrokeWidth?: number;
  scrollGesturesEnabled?: boolean;
  zoomGesturesEnabled?: boolean;
  tiltGesturesEnabled?: boolean;
  rotateGesturesEnabled?: boolean;
  fastTapEnabled?: boolean;
  initialRegion?: InitialRegion;
  maxFps?: number;
  followUser?: boolean;
  logoPosition?: MappableLogoPosition;
  logoPadding?: MappableLogoPadding;
}

const MappableMapNativeComponent = requireNativeComponent<MappableMapProps>('MappableView');

export class MappableMap extends React.Component<MappableMapProps> {
  static defaultProps = {
    showUserPosition: true,
    clusterColor: 'red',
    maxFps: 60
  };

  // @ts-ignore
  map = React.createRef<MappableMapNativeComponent>();

  static ALL_MASSTRANSIT_VEHICLES: Vehicles[] = [
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

  public static init(apiKey: string): Promise<void> {
    return NativeMappableModule.init(apiKey);
  }

  public static setLocale(locale: string): Promise<void> {
    return new Promise((resolve, reject) => {
      NativeMappableModule.setLocale(locale, () => resolve(), (err: string) => reject(new Error(err)));
    });
  }

  public static getLocale(): Promise<string> {
    return new Promise((resolve, reject) => {
      NativeMappableModule.getLocale((locale: string) => resolve(locale), (err: string) => reject(new Error(err)));
    });
  }

  public static resetLocale(): Promise<void> {
    return new Promise((resolve, reject) => {
      NativeMappableModule.resetLocale(() => resolve(), (err: string) => reject(new Error(err)));
    });
  }

  public findRoutes(points: Point[], vehicles: Vehicles[], callback: (event: RoutesFoundEvent<DrivingInfo | MasstransitInfo>) => void) {
    this._findRoutes(points, vehicles, callback);
  }

  public findMasstransitRoutes(points: Point[], callback: (event: RoutesFoundEvent<MasstransitInfo>) => void) {
    this._findRoutes(points, MappableMap.ALL_MASSTRANSIT_VEHICLES, callback);
  }

  public findPedestrianRoutes(points: Point[], callback: (event: RoutesFoundEvent<MasstransitInfo>) => void) {
    this._findRoutes(points, [], callback);
  }

  public findDrivingRoutes(points: Point[], callback: (event: RoutesFoundEvent<DrivingInfo>) => void) {
    this._findRoutes(points, ['car'], callback);
  }

  public fitAllMarkers() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('fitAllMarkers'),
      []
    );
  }

  public setTrafficVisible(isVisible: boolean) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('setTrafficVisible'),
      [isVisible]
    );
  }

  public fitMarkers(points: Point[]) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('fitMarkers'),
      [points]
    );
  }

  public setCenter(center: { lon: number, lat: number, zoom?: number }, zoom: number = center.zoom || 10, azimuth: number = 0, tilt: number = 0, duration: number = 0, animation: Animation = Animation.SMOOTH) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('setCenter'),
      [center, zoom, azimuth, tilt, duration, animation]
    );
  }

  public setZoom(zoom: number, duration: number = 0, animation: Animation = Animation.SMOOTH) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('setZoom'),
      [zoom, duration, animation]
    );
  }

  public getCameraPosition(callback: (position: CameraPosition) => void) {
    const cbId = CallbacksManager.addCallback(callback);
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('getCameraPosition'),
      [cbId]
    );
  }

  public getVisibleRegion(callback: (VisibleRegion: VisibleRegion) => void) {
    const cbId = CallbacksManager.addCallback(callback);
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('getVisibleRegion'),
      [cbId]
    );
  }

  public getScreenPoints(points: Point[], callback: (screenPoint: ScreenPoint) => void) {
    const cbId = CallbacksManager.addCallback(callback);
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('getScreenPoints'),
      [points, cbId]
    );
  }

  public getWorldPoints(points: ScreenPoint[], callback: (point: Point) => void) {
    const cbId = CallbacksManager.addCallback(callback);
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('getWorldPoints'),
      [points, cbId]
    );
  }

  private _findRoutes(points: Point[], vehicles: Vehicles[], callback: ((event: RoutesFoundEvent<DrivingInfo | MasstransitInfo>) => void) | ((event: RoutesFoundEvent<DrivingInfo>) => void) | ((event: RoutesFoundEvent<MasstransitInfo>) => void)) {
    const cbId = CallbacksManager.addCallback(callback);
    const args = Platform.OS === 'ios' ? [{ points, vehicles, id: cbId }] : [points, vehicles, cbId];

    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('findRoutes'),
      args
    );
  }

  private getCommand(cmd: string): any {
    return Platform.OS === 'ios' ? UIManager.getViewManagerConfig('MappableView').Commands[cmd] : cmd;
  }

  private processRoute(event: NativeSyntheticEvent<{ id: string } & RoutesFoundEvent<DrivingInfo | MasstransitInfo>>) {
    const { id, ...routes } = event.nativeEvent;
    CallbacksManager.call(id, routes);
  }

  private processCameraPosition(event: NativeSyntheticEvent<{ id: string } & CameraPosition>) {
    const { id, ...point } = event.nativeEvent;
    CallbacksManager.call(id, point);
  }

  private processVisibleRegion(event: NativeSyntheticEvent<{ id: string } & VisibleRegion>) {
    const { id, ...visibleRegion } = event.nativeEvent;
    CallbacksManager.call(id, visibleRegion);
  }

  private processWorldToScreenPointsReceived(event: NativeSyntheticEvent<{ id: string } & ScreenPoint[]>) {
    const { id, ...screenPoints } = event.nativeEvent;
    CallbacksManager.call(id, screenPoints);
  }

  private processScreenToWorldPointsReceived(event: NativeSyntheticEvent<{ id: string } & Point[]>) {
    const { id, ...worldPoints } = event.nativeEvent;
    CallbacksManager.call(id, worldPoints);
  }

  private resolveImageUri(img: ImageSourcePropType) {
    return img ? resolveAssetSource(img).uri : '';
  }

  private getProps() {
    const props = {
      ...this.props,
      onRouteFound: this.processRoute,
      onCameraPositionReceived: this.processCameraPosition,
      onVisibleRegionReceived: this.processVisibleRegion,
      onWorldToScreenPointsReceived: this.processWorldToScreenPointsReceived,
      onScreenToWorldPointsReceived: this.processScreenToWorldPointsReceived,
      userLocationIcon: this.props.userLocationIcon ? this.resolveImageUri(this.props.userLocationIcon) : undefined
    };

    processColorProps(props, 'clusterColor' as keyof MappableMapProps);
    processColorProps(props, 'userLocationAccuracyFillColor' as keyof MappableMapProps);
    processColorProps(props, 'userLocationAccuracyStrokeColor' as keyof MappableMapProps);

    return props;
  }

  render() {
    return (
      <MappableMapNativeComponent
        {...this.getProps()}
        ref={this.map}
      />
    );
  }
}
