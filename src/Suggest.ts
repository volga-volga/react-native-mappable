import { BoundingBox, Point } from './interfaces';
import { NativeModules } from 'react-native';

const { MappableSuggests } = NativeModules;

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

export enum SuggestTypes {
  MMKSuggestTypeUnspecified = 0b00,
  /**
   * Toponyms.
   */
  MMKSuggestTypeGeo = 0b01,
  /**
   * Companies.
   */
  MMKSuggestTypeBiz = 0b01 << 1,
  /**
   * Mass transit routes.
   */
  MMKSuggestTypeTransit = 0b01 << 2,
}

export type SuggestOptions = {
  userPosition?: Point;
  boundingBox?: BoundingBox;
  suggestWords?: boolean;
  suggestTypes?: SuggestTypes[];
};

type SuggestFetcher = (query: string, options?: SuggestOptions) => Promise<Array<MappableSuggest>>;
const suggest: SuggestFetcher = (query, options) => {
  if (options) {
    return MappableSuggests.suggestWithOptions(query, options);
  }
  return MappableSuggests.suggest(query);
}

type SuggestWithCoordsFetcher = (query: string, options?: SuggestOptions) => Promise<Array<MappableSuggestWithCoords>>;
const suggestWithCoords: SuggestWithCoordsFetcher = async (query, options) => {
  const suggests = await suggest(query, options);

  return suggests.map((item) => ({
    ...item,
    ...getCoordsFromSuggest(item),
  }));
};

type SuggestResetter = () => Promise<void>;
const reset: SuggestResetter = () => MappableSuggests.reset();
//  Original uri format for the MapKit 4.0.0 ymapsbm1://geo?ll=39.957371%2C48.306156&spn=0.001000%2C0.001000&text=%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D1%8F%2C%20%D0%A0%D0%BE%D1%81%D1%82%D0%BE%D0%B2%D1%81%D0%BA%D0%B0%D1%8F%20%D0%BE%D0%B1%D0%BB%D0%B0%D1%81%D1%82%D1%8C%2C%20%D0%94%D0%BE%D0%BD%D0%B5%D1%86%D0%BA%2C%20%D1%83%D0%BB%D0%B8%D1%86%D0%B0%20%D0%9C%D0%B8%D0%BA%D0%BE%D1%8F%D0%BD%D0%B0%2C%2012
// Decoded uri format ymapsbm1://geo?ll=39.957371,48.306156&spn=0.001000,0.001000&text=Россия, Ростовская область, Донецк, улица Микояна, 12
type LatLonGetter = (suggest: MappableSuggest) => MappableCoords | undefined;
const getCoordsFromSuggest: LatLonGetter = (suggest) => {
  const coords = suggest.uri
                        ?.split('?')[1]
    ?.split('&')
    ?.find((param) => param.startsWith('ll'))
    ?.split('=')[1];
  if (!coords) return;

  const splittedCoords = coords.split('%2C');
  const lon = Number(splittedCoords[0]);
  const lat = Number(splittedCoords[1]);

  return { lat, lon };
};

const Suggest = {
  suggest,
  suggestWithCoords,
  reset,
  getCoordsFromSuggest
};

export default Suggest;
