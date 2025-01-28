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
exports.DefaultMarker = void 0;
var react_1 = __importDefault(require("react"));
var react_native_1 = require("react-native");
// @ts-ignore
var resolveAssetSource_1 = __importDefault(require("react-native/Libraries/Image/resolveAssetSource"));
var utils_1 = require("../utils");
var NativeMarkerComponent = (0, react_native_1.requireNativeComponent)('MappableDefaultMarker');
var DefaultMarker = /** @class */ (function (_super) {
    __extends(DefaultMarker, _super);
    function DefaultMarker() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    DefaultMarker.prototype.getCommand = function (cmd) {
        if (react_native_1.Platform.OS === 'ios') {
            return react_native_1.UIManager.getViewManagerConfig('MappableDefaultMarker').Commands[cmd];
        }
        else {
            return cmd;
        }
    };
    DefaultMarker.prototype.resolveImageUri = function (img) {
        return img ? (0, resolveAssetSource_1.default)(img).uri : '';
    };
    DefaultMarker.prototype.getProps = function () {
        var props = __assign({}, this.props);
        (0, utils_1.processColorProps)(props, 'color');
        (0, utils_1.processColorProps)(props, 'iconColor');
        return props;
    };
    DefaultMarker.prototype.animatedMoveTo = function (coords, duration) {
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('animatedMoveTo'), [coords, duration]);
    };
    DefaultMarker.prototype.animatedRotateTo = function (angle, duration) {
        react_native_1.UIManager.dispatchViewManagerCommand((0, react_native_1.findNodeHandle)(this), this.getCommand('animatedRotateTo'), [angle, duration]);
    };
    DefaultMarker.prototype.render = function () {
        return (react_1.default.createElement(NativeMarkerComponent, __assign({}, this.getProps(), { pointerEvents: "none" })));
    };
    DefaultMarker.defaultProps = {
        rotated: false,
    };
    return DefaultMarker;
}(react_1.default.Component));
exports.DefaultMarker = DefaultMarker;
//# sourceMappingURL=DefaultMarker.js.map