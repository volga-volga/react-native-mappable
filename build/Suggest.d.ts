import { BoundingBox, Point } from './interfaces';
export type MappableSuggest = {
    title: string;
    subtitle?: string;
    uri?: string;
};
export type MappableCoords = {
    lon: number;
    lat: number;
};
export type MappableSuggestWithCoords = MappableSuggest & Partial<MappableCoords>;
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
export type SuggestOptions = {
    userPosition?: Point;
    boundingBox?: BoundingBox;
    suggestWords?: boolean;
    suggestTypes?: SuggestTypes[];
};
type SuggestFetcher = (query: string, options?: SuggestOptions) => Promise<Array<MappableSuggest>>;
type SuggestWithCoordsFetcher = (query: string, options?: SuggestOptions) => Promise<Array<MappableSuggestWithCoords>>;
type SuggestResetter = () => Promise<void>;
type LatLonGetter = (suggest: MappableSuggest) => MappableCoords | undefined;
declare const Suggest: {
    suggest: SuggestFetcher;
    suggestWithCoords: SuggestWithCoordsFetcher;
    reset: SuggestResetter;
    getCoordsFromSuggest: LatLonGetter;
};
export default Suggest;
