import { BoundingBox, Point } from './interfaces';
import { NativeModules } from 'react-native';

const { MappableSearch } = NativeModules;

export interface Address {
  country_code: string;
  formatted: string;
  postal_code: string;
  Components: {kind: string, name: string}[];
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

export enum SearchTypes {
  MMKSearchTypeUnspecified = 0b00,
  /**
   * Toponyms.
   */
  MMKSearchTypeGeo = 0b01,
  /**
   * Companies.
   */
  MMKSearchTypeBiz = 0b01 << 1,
  /**
   * Mass transit routes.
   */
}

export enum SearchTypesSnippets {
  MMKSearchTypeUnspecified = 0b00,
  /**
   * Toponyms.
   */
  MMKSearchTypeGeo = 0b01,
  /**
   * Companies.
   */
  MMKSearchTypeBiz = 0b01 << 32,
  /**
   * Mass transit routes.
   */
}

export type SearchOptions = {
  disableSpellingCorrection?: boolean;
  geometry?: boolean;
  snippets?: SearchTypesSnippets;
  searchTypes?: SearchTypes;
};

export enum GeoFigureType {
  POINT="POINT",
  BOUNDINGBOX="BOUNDINGBOX",
  POLYLINE="POLYLINE",
  POLYGON="POLYGON",
}

export interface PointParams {
  type: GeoFigureType.POINT
  value: Point
}

export interface BoundingBoxParams {
  type: GeoFigureType.BOUNDINGBOX
  value: BoundingBox
}

export interface PolylineParams {
  type: GeoFigureType.POLYLINE
  value: PolylineParams
}

export interface PolygonParams {
  type: GeoFigureType.POLYGON
  value: PolygonParams
}

type FigureParams = PointParams | BoundingBoxParams | PolylineParams | PolygonParams

type SearchFetcher = (query: string, options?: SearchOptions) => Promise<Array<MappableSearch>>;
type SearchPointFetcher = (point: Point, options?: SearchOptions) => Promise<Address>;
const searchText = (query: string, figure?: FigureParams, options?: SearchOptions) => {
  return MappableSearch.searchByAddress(query, figure, options);
}

const searchPoint = (point: Point, zoom?: number, options?: SearchOptions): Promise<Address[]> => {
  return MappableSearch.searchByPoint(point, zoom, options);
}

const resolveURI: SearchFetcher = (uri: string, options) => {
  return MappableSearch.resolveURI(uri, options);
}

const searchByURI: SearchFetcher = (uri: string, options) => {
  return MappableSearch.searchByURI(uri, options);
}

const geocodePoint: SearchPointFetcher = (point: Point) => {
  return MappableSearch.geoToAddress(point);
}

const geocodeAddress: SearchFetcher = (address: string) => {
  return MappableSearch.addressToGeo(address);
}

const Search = {
  searchText,
  searchPoint,
  geocodePoint,
  geocodeAddress,
  resolveURI,
  searchByURI
};

export default Search;
