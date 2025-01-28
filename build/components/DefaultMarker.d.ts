import React from 'react';
import { Point } from '../interfaces';
export interface DefaultMarkerProps {
    zIndex?: number;
    scale?: number;
    type?: number;
    icon?: number;
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
