import React from 'react';
import { requireNativeComponent, Platform, ImageSourcePropType, UIManager, findNodeHandle, View } from 'react-native';
// @ts-ignore
import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource';
import { Point } from '../interfaces';
import {processColorProps} from '../utils';

export enum DefaultMarkerType {
  SMALL,
  MEDIUM,
  LARGE,
}

export enum DefaultMarkerIcon {
  AIRFIELD,
  AIRPORT,
  AUTO,
  BARS,
  BEACH,
  BUILDING,
  CAFE,
  FAST_FOOD,
  RESTAURANTS,
  WC,
}

export interface DefaultMarkerProps {
  zIndex?: number;
  scale?: number;
  type?: DefaultMarkerType;
  icon?: DefaultMarkerIcon;
  text?: string;
  subText?: string;
  color?: string;
  iconColor?: string;
  rotated?: boolean;
  onPress?: () => void;
  point: Point;
  anchor?: { x: number, y: number };
  visible?: boolean;
  handled?: boolean;
}

const NativeMarkerComponent = requireNativeComponent<DefaultMarkerProps & { pointerEvents: 'none' }>('MappableDefaultMarker');

export class DefaultMarker extends React.Component<DefaultMarkerProps, {}> {
  static defaultProps = {
    rotated: false,
  };

  private getCommand(cmd: string): any {
    if (Platform.OS === 'ios') {
      return UIManager.getViewManagerConfig('MappableDefaultMarker').Commands[cmd];
    } else {
      return cmd;
    }
  }

  private resolveImageUri(img?: ImageSourcePropType) {
    return img ? resolveAssetSource(img).uri : '';
  }

  private getProps() {
    const props = { ...this.props };

    processColorProps(props, 'color' as keyof DefaultMarkerProps);
    processColorProps(props, 'iconColor' as keyof DefaultMarkerProps);

    return props;
  }

  public animatedMoveTo(coords: Point, duration: number) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('animatedMoveTo'),
      [coords, duration]
    );
  }

  public animatedRotateTo(angle: number, duration: number) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      this.getCommand('animatedRotateTo'),
      [angle, duration]
    );
  }

  render() {
    return (
      <NativeMarkerComponent
        {...this.getProps()}
        pointerEvents="none"
      />
    );
  }
}
