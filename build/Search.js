"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GeoFigureType = exports.SearchTypesSnippets = exports.SearchTypes = void 0;
var react_native_1 = require("react-native");
var MappableSearch = react_native_1.NativeModules.MappableSearch;
var SearchTypes;
(function (SearchTypes) {
    SearchTypes[SearchTypes["MMKSearchTypeUnspecified"] = 0] = "MMKSearchTypeUnspecified";
    /**
     * Toponyms.
     */
    SearchTypes[SearchTypes["MMKSearchTypeGeo"] = 1] = "MMKSearchTypeGeo";
    /**
     * Companies.
     */
    SearchTypes[SearchTypes["MMKSearchTypeBiz"] = 2] = "MMKSearchTypeBiz";
    /**
     * Mass transit routes.
     */
})(SearchTypes = exports.SearchTypes || (exports.SearchTypes = {}));
var SearchTypesSnippets;
(function (SearchTypesSnippets) {
    SearchTypesSnippets[SearchTypesSnippets["MMKSearchTypeUnspecified"] = 0] = "MMKSearchTypeUnspecified";
    /**
     * Toponyms.
     */
    SearchTypesSnippets[SearchTypesSnippets["MMKSearchTypeGeo"] = 1] = "MMKSearchTypeGeo";
    /**
     * Companies.
     */
    SearchTypesSnippets[SearchTypesSnippets["MMKSearchTypeBiz"] = 1] = "MMKSearchTypeBiz";
    /**
     * Mass transit routes.
     */
})(SearchTypesSnippets = exports.SearchTypesSnippets || (exports.SearchTypesSnippets = {}));
var GeoFigureType;
(function (GeoFigureType) {
    GeoFigureType["POINT"] = "POINT";
    GeoFigureType["BOUNDINGBOX"] = "BOUNDINGBOX";
    GeoFigureType["POLYLINE"] = "POLYLINE";
    GeoFigureType["POLYGON"] = "POLYGON";
})(GeoFigureType = exports.GeoFigureType || (exports.GeoFigureType = {}));
var searchText = function (query, figure, options) {
    return MappableSearch.searchByAddress(query, figure, options);
};
var searchPoint = function (point, zoom, options) {
    return MappableSearch.searchByPoint(point, zoom, options);
};
var resolveURI = function (uri, options) {
    return MappableSearch.resolveURI(uri, options);
};
var searchByURI = function (uri, options) {
    return MappableSearch.searchByURI(uri, options);
};
var geocodePoint = function (point) {
    return MappableSearch.geoToAddress(point);
};
var geocodeAddress = function (address) {
    return MappableSearch.addressToGeo(address);
};
var Search = {
    searchText: searchText,
    searchPoint: searchPoint,
    geocodePoint: geocodePoint,
    geocodeAddress: geocodeAddress,
    resolveURI: resolveURI,
    searchByURI: searchByURI
};
exports.default = Search;
//# sourceMappingURL=Search.js.map