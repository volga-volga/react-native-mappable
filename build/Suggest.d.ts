import { BoundingBox, Point } from './interfaces';
export declare type MappableSuggest = {
    title: string;
    subtitle?: string;
    uri?: string;
};
export declare type MappableCoords = {
    lon: number;
    lat: number;
};
export declare type MappableSuggestWithCoords = MappableSuggest & Partial<MappableCoords>;
export declare enum SuggestTypes {
    MMKSuggestTypeUnspecified = 0,
    /**
     * Toponyms.
     */
    MMKSuggestTypeGeo = 1,
    /**
     * Companies.
     */
    MMKSuggestTypeBiz = 2,
    /**
     * Mass transit routes.
     */
    MMKSuggestTypeTransit = 4
}
export declare type SuggestOptions = {
    userPosition?: Point;
    boundingBox?: BoundingBox;
    suggestWords?: boolean;
    suggestTypes?: SuggestTypes[];
};
declare type SuggestFetcher = (query: string, options?: SuggestOptions) => Promise<Array<MappableSuggest>>;
declare type SuggestWithCoordsFetcher = (query: string, options?: SuggestOptions) => Promise<Array<MappableSuggestWithCoords>>;
declare type SuggestResetter = () => Promise<void>;
declare type LatLonGetter = (suggest: MappableSuggest) => MappableCoords | undefined;
declare const Suggest: {
    suggest: SuggestFetcher;
    suggestWithCoords: SuggestWithCoordsFetcher;
    reset: SuggestResetter;
    getCoordsFromSuggest: LatLonGetter;
};
export default Suggest;
