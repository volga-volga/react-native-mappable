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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Marker = void 0;
var react_1 = __importDefault(require("react"));
var react_native_1 = require("react-native");
// @ts-ignore
var resolveAssetSource_1 = __importDefault(require("react-native/Libraries/Image/resolveAssetSource"));
var NativeMarkerComponent = (0, react_native_1.requireNativeComponent)('MappableMarker');
var deepCompareChildren = function (nextChildren, prevChildren) {
    try {
        if (!nextChildren || !prevChildren) {
            return nextChildren === prevChildren;
        }
        if (Array.isArray(nextChildren) && Array.isArray(prevChildren)) {
            if (nextChildren.length !== prevChildren.length) {
                return false;
            }
            return nextChildren.every(function (child, index) {
                return deepCompareChildren(child, prevChildren[index]);
            });
        }
        if (react_1.default.isValidElement(nextChildren) && react_1.default.isValidElement(prevChildren)) {
            if (nextChildren.type !== prevChildren.type) {
                return false;
            }
            if (nextChildren.key !== prevChildren.key) {
                return false;
            }
            var nextChildrenProps_1 = Object.fromEntries(Object.entries(nextChildren).filter(function (_a) {
                var key = _a[0];
                return key !== 'children';
            }));
            var prevChildrenProps_1 = Object.fromEntries(Object.entries(prevChildren).filter(function (_a) {
                var key = _a[0];
                return key !== 'children';
            }));
            // @ts-ignore
            return (deepCompareChildren(nextChildren.props.children, prevChildren.props.children) &&
                !(Object.keys(nextChildrenProps_1).find(function (key) { return nextChildrenProps_1[key] != prevChildrenProps_1[key]; }) && Object.keys(prevChildrenProps_1).find(function (key) { return nextChildrenProps_1[key] != prevChildrenProps_1[key]; })));
        }
        return false;
    }
    catch (e) {
        return false;
    }
};
var Marker = /** @class */ (function (_super) {
    __extends(Marker, _super);
    function Marker() {
        var _this = _super !== null && _super.apply(this, arguments) || this;
        _this.state = {
            recreateKey: false,
            children: _this.props.children,
        };
        return _this;
    }
    Marker.prototype.getCommand = function (cmd) {
        if (react_native_1.Platform.OS === 'ios') {
            return react_native_1.UIManager.getViewManagerConfig('MappableMarker').Commands[cmd];
        }
        else {
            return cmd;
        }
    };
    Marker.getDerivedStateFromProps = function (nextProps, prevState) {
        if (!deepCompareChildren(nextProps.children, prevState.children)) {
            return {
                children: nextProps.children,
                recreateKey: !prevState.recreateKey,
            };
        }
        return __assign(__assign({}, prevState), { children: nextProps.children });
    };
    Marker.prototype.resolveImageUri = function (img) {
        return img ? (0, resolveAssetSource_1.default)(img).uri : '';
    };
    Marker.prototype.getProps = function () {
        return __assign(__assign({}, this.props), { source: this.resolveImageUri(this.props.source), children: undefined });
    };
    Marker.prototype.animatedMoveTo = function (coords, duration) {
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('animatedMoveTo'), [coords, duration]);
    };
    Marker.prototype.animatedRotateTo = function (angle, duration) {
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('animatedRotateTo'), [angle, duration]);
    };
    Marker.prototype.render = function () {
        return (react_1.default.createElement(NativeMarkerComponent, __assign({}, this.getProps(), { pointerEvents: "none" }),
            react_1.default.createElement(react_native_1.View, { style: { position: 'absolute', zIndex: 10 }, key: String(this.state.recreateKey) }, this.props.children)));
    };
    Marker.defaultProps = {
        rotated: false,
    };
    return Marker;
}(react_1.default.Component));
exports.Marker = Marker;
//# sourceMappingURL=Marker.js.map