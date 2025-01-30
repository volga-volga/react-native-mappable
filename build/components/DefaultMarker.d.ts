import React from 'react';
import { Point } from '../interfaces';
export declare enum DefaultMarkerType {
    SMALL = 0,
    MEDIUM = 1,
    LARGE = 2
}
export declare enum DefaultMarkerIcon {
    AIRFIELD = 0,
    AIRPORT = 1,
    AUTO = 2,
    BARS = 3,
    BEACH = 4,
    BUILDING = 5,
    CAFE = 6,
    FAST_FOOD = 7,
    RESTAURANTS = 8,
    WC = 9
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
    anchor?: {
        x: number;
        y: number;
    };
    visible?: boolean;
    handled?: boolean;
}
export declare class DefaultMarker extends React.Component<DefaultMarkerProps, {}> {
    static defaultProps: {
        rotated: boolean;
    };
    private getCommand;
    private resolveImageUri;
    private getProps;
    animatedMoveTo(coords: Point, duration: number): void;
    animatedRotateTo(angle: number, duration: number): void;
    render(): React.JSX.Element;
}
