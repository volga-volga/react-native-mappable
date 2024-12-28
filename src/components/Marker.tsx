import React from 'react';
import { requireNativeComponent, Platform, ImageSourcePropType, UIManager, findNodeHandle, View } from 'react-native';
// @ts-ignore
import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource';
import { Point } from '../interfaces';

export interface MarkerProps {
  children?: React.ReactElement;
  zIndex?: number;
  scale?: number;
  rotated?: boolean;
  onPress?: () => void;
  point: Point;
  source?: ImageSourcePropType;
  anchor?: { x: number, y: number };
  visible?: boolean;
  handled?: boolean;
}

const NativeMarkerComponent = requireNativeComponent<MarkerProps & { pointerEvents: 'none' }>('MappableMarker');

interface State {
  recreateKey: boolean;
  children: any;
}

const deepCompareChildren = (nextChildren?: React.ReactElement, prevChildren?: React.ReactElement): boolean => {
  if (!nextChildren || !prevChildren) {
    return nextChildren===prevChildren;
  }
  if (Array.isArray(nextChildren) && Array.isArray(prevChildren)) {
    if (nextChildren.length !== prevChildren.length) {
      return false;
    }
    return nextChildren.every((child, index) =>
      deepCompareChildren(child, prevChildren[index])
    );
  }

  if (React.isValidElement(nextChildren) && React.isValidElement(prevChildren)) {
    if (nextChildren.type !== prevChildren.type) {
      return false;
    }

    if (nextChildren.key !== prevChildren.key) {
      return false;
    }
    // @ts-ignore
    return (deepCompareChildren(nextChildren.props.children, prevChildren.props.children) && JSON.stringify(nextChildren.props) === JSON.stringify(prevChildren.props));
  }

  return false;
};


export class Marker extends React.Component<MarkerProps, State> {
  static defaultProps = {
    rotated: false,
  };

  state = {
    recreateKey: false,
    children: this.props.children,
  };

  private getCommand(cmd: string): any {
    if (Platform.OS === 'ios') {
      return UIManager.getViewManagerConfig('MappableMarker').Commands[cmd];
    } else {
      return cmd;
    }
  }

  static getDerivedStateFromProps(nextProps: MarkerProps, prevState: State): Partial<State> {
    if (!deepCompareChildren(nextProps.children, prevState.children)) {
      return {
        children: nextProps.children,
        recreateKey: !prevState.recreateKey,
      };
    }
    return {
      ...prevState,
      children: nextProps.children,
    }
  }

  private resolveImageUri(img?: ImageSourcePropType) {
    return img ? resolveAssetSource(img).uri : '';
  }

  private getProps() {
    return {
      ...this.props,
      source: this.resolveImageUri(this.props.source),
      children: undefined,
    };
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
    if (Platform.OS === 'ios') {
      return (
        <NativeMarkerComponent
          {...this.getProps()}
          key={String(this.state.recreateKey)}
          pointerEvents="none"
        >
          {this.state.children}
        </NativeMarkerComponent>
      );
    }

    return (
      <NativeMarkerComponent
        {...this.getProps()}
        pointerEvents="none"
      >
        <View key={String(this.state.recreateKey)}>
          {this.props.children}
        </View>
      </NativeMarkerComponent>
    );
  }
}
