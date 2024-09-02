import { BoundingBox, Point } from './interfaces';
export interface Address {
    country_code: string;
    formatted: string;
    postal_code: string;
    Components: {
        kind: string;
        name: string;
    }[];
}
export type MappableSearch = {
    title: string;
    subtitle?: string;
    uri?: string;
};
export type MappableCoords = {
    lon: number;
    lat: number;
};
export type MappableSearchWithCoords = MappableSearch & Partial<MappableCoords>;
export declare enum SearchTypes {
    MMKSearchTypeUnspecified = 0,
    /**
     * Toponyms.
     */
    MMKSearchTypeGeo = 1,
    /**
     * Companies.
     */
    MMKSearchTypeBiz = 2
}
export declare enum SearchTypesSnippets {
    MMKSearchTypeUnspecified = 0,
    /**
     * Toponyms.
     */
    MMKSearchTypeGeo = 1,
    /**
     * Companies.
     */
    MMKSearchTypeBiz = 1
}
export type SearchOptions = {
    disableSpellingCorrection?: boolean;
    geometry?: boolean;
    snippets?: SearchTypesSnippets;
    searchTypes?: SearchTypes;
};
export declare enum GeoFigureType {
    POINT = "POINT",
    BOUNDINGBOX = "BOUNDINGBOX",
    POLYLINE = "POLYLINE",
    POLYGON = "POLYGON"
}
export interface PointParams {
    type: GeoFigureType.POINT;
    value: Point;
}
export interface BoundingBoxParams {
    type: GeoFigureType.BOUNDINGBOX;
    value: BoundingBox;
}
export interface PolylineParams {
    type: GeoFigureType.POLYLINE;
    value: PolylineParams;
}
export interface PolygonParams {
    type: GeoFigureType.POLYGON;
    value: PolygonParams;
}
type FigureParams = PointParams | BoundingBoxParams | PolylineParams | PolygonParams;
type SearchFetcher = (query: string, options?: SearchOptions) => Promise<Array<MappableSearch>>;
type SearchPointFetcher = (point: Point, options?: SearchOptions) => Promise<Address>;
declare const Search: {
    searchText: (query: string, figure?: FigureParams, options?: SearchOptions) => any;
    searchPoint: (point: Point, zoom?: number, options?: SearchOptions) => Promise<Address[]>;
    geocodePoint: SearchPointFetcher;
    geocodeAddress: SearchFetcher;
    resolveURI: SearchFetcher;
    searchByURI: SearchFetcher;
};
export default Search;
