"use strict";
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
exports.MarkerImage = void 0;
var react_1 = __importDefault(require("react"));
var react_native_1 = require("react-native");
var react_2 = require("react");
var MarkerImage = function (props) {
    var _a = (0, react_2.useState)(false), isLoaded = _a[0], setIsLoaded = _a[1];
    return (react_1.default.createElement(react_native_1.Image, __assign({}, props, { key: String(isLoaded), onLoad: function (event) {
            var _a;
            (_a = props.onLoad) === null || _a === void 0 ? void 0 : _a.call(props, event);
            setIsLoaded(true);
        } })));
};
exports.MarkerImage = MarkerImage;
//# sourceMappingURL=MarkerImage.js.map