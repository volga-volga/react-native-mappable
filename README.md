
## React Native Mappable

Mappable MapKit SDK for React Native



## Installation

```
yarn add react-native-mappable
```
or
```
npm i react-native-mappable --save
```

### Linking

Linking is required to use Mappable MapKit (the library supports autolinking).


#### Linking React Native <0.60

```
react-native link react-native-mappable
```

## Using maps

### Initialize the maps

To do this, it is best to go to the root file of the application, for example, `App.js`, and add initialization:

```js
import Mappable from 'react-native-mappable';

Mappable.init('API_KEY');
```

### Change the language

```js
import Mappable from 'react-native-mappable';

const currentLocale = await Mappable.getLocale();
Mappable.setLocale('en_US');
Mappable.resetLocale();
```

-  **getLocale(): Promise\<string\>** -  returns the map language used;

-  **setLocale(locale: string): Promise\<void\>** - set the language of the maps;

-  **resetLocale(): Promise\<void\>** - use the system language for maps.

Each method returns a Promise that is executed when the native SDK responds. The Promise may be rejected if the SDK returns an error.

**IMPORTANT!**

1. For **Android** changing the language of the maps will take effect only after **restarting** the application.
2. For **iOS** language change methods can only be called before the first map rendering. Also, you cannot call the method again if the language has already been changed (it is possible only after restarting the application), otherwise the changes will not be accepted, and a warning message will be displayed in the terminal. There will be no error information in the code.

### Using the components

```jsx
import React from 'react';
import Mappable from 'react-native-mappable';

const Map = () => {
  return (
    <Mappable
      userLocationIcon={{ uri: 'https://www.clipartmax.com/png/middle/180-1801760_pin-png.png' }}
      initialRegion={{
        lat: 50,
        lon: 50,
        zoom: 10,
        azimuth: 80,
        tilt: 100
      }}
      style={{ flex: 1 }}
    />
  );
};
```

#### Main types

```typescript
interface Point {
  lat: Number;
  lon: Number;
}

interface ScreenPoint {
  x: number;
  y: number;
}

interface MapLoaded {
  renderObjectCount: number;
  curZoomModelsLoaded: number;
  curZoomPlacemarksLoaded: number;
  curZoomLabelsLoaded: number;
  curZoomGeometryLoaded: number;
  tileMemoryUsage: number;
  delayedGeometryLoaded: number;
  fullyAppeared: number;
  fullyLoaded: number;
}

interface InitialRegion {
  lat: number;
  lon: number;
  zoom?: number;
  azimuth?: number;
  tilt?: number;
}


type MasstransitVehicles = 'bus' | 'trolleybus' | 'tramway' | 'minibus' | 'suburban' | 'underground' | 'ferry' | 'cable' | 'funicular';

type Vehicles = MasstransitVehicles | 'walk' | 'car';

interface DrivingInfo {
  time: string;
  timeWithTraffic: string;
  distance: number;
}

interface MasstransitInfo {
  time:  string;
  transferCount:  number;
  walkingDistance:  number;
}

interface RouteInfo<T extends(DrivingInfo | MasstransitInfo)> {
  id: string;
  sections: {
    points: Point[];
    sectionInfo: T;
    routeInfo: T;
    routeIndex: number;
    stops: any[];
    type: string;
    transports?: any;
    sectionColor?: string;
  }
}

interface RoutesFoundEvent<T extends(DrivingInfo | MasstransitInfo)> {
    status: 'success' | 'error';
    id: string;
    routes: RouteInfo<T>[];
}

interface CameraPosition {
  zoom: number;
  tilt: number;
  azimuth: number;
  point: Point;
  reason: 'GESTURES' | 'APPLICATION';
  finished: boolean;
}

type VisibleRegion = {
  bottomLeft: Point;
  bottomRight: Point;
  topLeft: Point;
  topRight: Point;
}


type MappableSuggest = {
  title: string;
  subtitle?: string;
  uri?: string;
}

type MappableCoords = {
  lon: number;
  lat: number;
}

type MappableSuggestWithCoords = {
  lon: number;
  lat: number;
  title: string;
  subtitle?: string;
  uri?: string;
}

type MappableLogoPosition = {
  horizontal: 'left' | 'center' | 'right';
  vertical: 'top' | 'bottom';
}

type MappableLogoPadding = {
  horizontal?: number;
  vertical?: number;
}
```

#### Available `props` for the **MapView** component:

| Name | Type | Default value | Description                                                                                                                                                                                        |
|--|--|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| showUserPosition | boolean | true          | Tracking geodata and displaying the user's position. On Android you need request `android.permission.ACCESS_FINE_LOCATION`. On Ios you need add `NSLocationWhenInUseUsageDescription` in Info.plst |
| followUser | boolean | true          | Camera tracking of the user                                                                                                                                                                        |
| userLocationIcon | ImageSource | false         | The icon for the user's position. The same values are available as for the Image component from React Native                                                                                       |
| userLocationIconScale | number | 1             | Scaling the user's icon                                                                                                                                                                            |
| initialRegion | InitialRegion |               | The original location of the map when loading                                                                                                                                                      |
| interactive | boolean | true          | Is the map interactive (moving around the map, tracking clicks)                                                                                                                                    |
| nightMode | boolean | false         | Using Night mode                                                                                                                                                                                   |
| onMapLoaded | function |               | Callback for maps loading                                                                                                                                                                          |
| onCameraPositionChange | function |               | Callback for changing the camera position                                                                                                                                                          |
| onCameraPositionChangeEnd | function |               | Callback at the end of the camera position change                                                                                                                                                  |
| onMapPress | function |               | The event of clicking on the map. Returns the coordinates of the clicked point                                                                                                                     |
| onMapLongPress | function |               | The event of a long click on the map. Returns the coordinates of the clicked point                                                                                                                 |
| userLocationAccuracyFillColor | string |               | The background color of the user position accuracy zone                                                                                                                                            |
| userLocationAccuracyStrokeColor | string |               | The color of the border of the accuracy zone for determining the user's position                                                                                                                   |
| userLocationAccuracyStrokeWidth | number |               | The thickness of the accuracy zone for determining the user's position                                                                                                                             |
| scrollGesturesEnabled | boolean | true          | Are scroll gestures enabled                                                                                                                                                                        |
| zoomGesturesEnabled | boolean | true          | Are zoom gestures enabled                                                                                                                                                                          |
| tiltGesturesEnabled | boolean | true          | Are the camera tilt gestures enabled with two fingers                                                                                                                                              |
| rotateGesturesEnabled | boolean | true          | Are camera rotation gestures enabled                                                                                                                                                               |
| fastTapEnabled | boolean | true          | Has the 300ms delay been removed when clicking/tapping                                                                                                                                             |
| clusterColor | string | 'red'         | The background color of the cluster placemark                                                                                                                                                      |
| maxFps | number | 60            | Maximum card refresh rate                                                                                                                                                                          |
| logoPosition | MappableLogoPosition | {}            | The position of the Mappable logo on the map                                                                                                                                                       |
| logoPadding | MappableLogoPadding | {}            | Indentation of the Mappable logo on the map                                                                                                                                                        |
| mapStyle | string | {}            | Map styles according to the documentation                                                                                                                                                          |

#### Available methods for the **MapView** component:

-  `fitMarkers(points: Point[]): void` - adjust the camera position to accommodate the specified markers (if possible);
-  `fitAllMarkers(): void` - adjust the camera position to accommodate all markers (if possible);
-  `setCenter(center: { lon: number, lat: number }, zoom: number = 10, azimuth: number = 0, tilt: number = 0, duration: number = 0, animation: Animation = Animation.SMOOTH)` - sets the camera to a point with the specified zoom, azimuth rotation and tilt of the map (tilt). You can parameterize the animation: duration and type. If the duration is set to 0, then the transition will be without animation. Possible animation types are `Animation.SMOOTH` and `Animation.LINEAR`;
-  `setZoom(zoom: number, duration: number, animation: Animation)` - change the current zoom of the map. The `duration` and `animation` parameters work similarly to `setCenter`;
-  `getCameraPosition(callback: (position: CameraPosition) => void)` - requests the camera position and calls the transmitted callback with the current value;
-  `getVisibleRegion(callback: (region: VisibleRegion) => void)` - requests the visible region and calls the passed callback with the current value;
-  `findRoutes(points: Point[], vehicles: Vehicles[], callback: (event: RoutesFoundEvent) => void)` - requesting routes through `points` using `vehicles` transport. When receiving routes, a `callback` will be called with information about all routes (for more information, see the section **"Requesting routes"**);
-  `findMasstransitRoutes(points: Point[], callback: (event: RoutesFoundEvent<MasstransitInfo>) => void): void` - request routes on any public transport (builds in the city area);
-  `findPedestrianRoutes(points: Point[], callback: (event: RoutesFoundEvent<MasstransitInfo>) => void): void` - request a walking route;
-  `findDrivingRoutes(points: Point[], callback: (event: RoutesFoundEvent<DrivingInfo>) => void): void` - request a route for a car;
-  `setTrafficVisible(isVisible: boolean): void` - enable/disable the display of the traffic layer on maps;
-  `getScreenPoints(point: Point[], callback: (screenPoints: ScreenPoint[]) => void)` - get the coordinates on the screen (x and y) from the coordinates of the markers;
-  `getWorldPoints(screenPoint: ScreenPoint[], callback: (worldPoints: Point[]) => void)` - get the coordinates of the points (lat and lon) from the coordinates on the screen.

**IMPORTANT**

- The maps component is styled, just like the `View` from React Native. If the map is not displayed, after initialization with a valid API key, it is probably necessary to prescribe a style that describes the dimensions of the component (`height + width` or `flex`);
- When using images from JS (via `require('./img.png')`) There may be different marker sizes in the launch and release on Android. It is recommended to check the render in the release build.

## Displaying primitives

### Marker

```jsx
import { Marker, MappableMap } from 'react-native-mappable';

<MappableMap>
  <Marker point={{ lat: 50, lon: 50 }}/>
</MappableMap>
```

#### Available `props` for the **Marker** primitive:

| Name | Type | Description                                                                           |
|--|--|---------------------------------------------------------------------------------------|
| point | Point | Coordinates of the point to display the marker                                        |
| scale | number | Scaling of the marker icon. It doesn't work if you use children in the marker         |
| source | ImageSource | Data for the marker image                                                             |
| children | ReactElement | Rendering a marker as a component                                                     |
| onPress | function | Click action                                                                          |
| anchor | {  x:  number,  y:  number  } | The anchor of the marker icon. The coordinates take values from 0 to 1                |
| zIndex | number | Displaying an element on the Z axis                                                   |
| visible | boolean | Displaying a marker on the map                                                        |
| rotated | boolean | Enables marker rotation                                                               |
| handled | boolean | Enable(**false**)/disable(**true**) event touch propagation for parent `default:true` |

#### Available methods for the **Marker** primitive:

-  `animatedMoveTo(point: Point, duration: number)` - smooth change of marker position;
-  `animatedRotateTo(angle: number, duration: number)` - smooth rotation of the marker. You should enable rotation via `rotated` prop

### DefaultMarker

Only for Android
```jsx
import { DefaultMarker, MappableMap } from 'react-native-mappable';

<MappableMap>
  <DefaultMarker point={{ lat: 50, lon: 50 }}/>
</MappableMap>
```

#### Available `props` for the **DefaultMarker** primitive:

| Name    | Type                          | Description                                                                           |
|---------|-------------------------------|---------------------------------------------------------------------------------------|
| point   | Point                         | Coordinates of the point to display the marker                                        |
| scale   | number                        | Scaling of the marker icon. It doesn't work if you use children in the marker         |
| type    | DefaultMarkerType             | Type of marker                                                                        |
| icon    | DefaultMarkerIcon             | Icon for marker (awailable for MEDIUM and LARGE)                                      |
| onPress | function                      | Click action                                                                          |
| anchor  | {  x:  number,  y:  number  } | The anchor of the marker icon. The coordinates take values from 0 to 1                |
| zIndex  | number                        | Displaying an element on the Z axis                                                   |
| visible | boolean                       | Displaying a marker on the map                                                        |
| rotated | boolean                       | Enables marker rotation                                                               |
| handled | boolean                       | Enable(**false**)/disable(**true**) event touch propagation for parent `default:true` |
| text | string                        | Defines text for marker                                                               |
| subText | string                        | Defines subtext for marker                                                            |
| color | string                        | Defines color for marker                                                               |
| iconColor | string                        | Defines iconColor for marker                                                            |

#### Available methods for the **DefaultMarker** primitive same with **Marker**:

### Circle

```jsx
import { Circle, MappableMap } from 'react-native-mappable';

<MappableMap>
  <Circle center={{ lat: 50, lon: 50 }} radius={300} />
</MappableMap>
```

#### Available `props` for the **Circle** primitive:

| Name | Type | Description |
|--|--|--|
| center | Point | Coordinates of the center of the circle |
| radius | number | The radius of the circle in meters |
| fillColor | string | Fill color |
| strokeColor | string | Border color |
| strokeWidth | number | Border thickness |
| onPress | function | Click action |
| zIndex | number | Displaying an element on the Z axis |
| handled | boolean | Enable(**false**)/disable(**true**) event touch propagation for parent `default:true` |

### Polyline

```jsx
import { Polyline, MappableMap } from 'react-native-mappable';

<MappableMap>
  <Polyline
    points={[
      { lat: 50, lon: 50 },
      { lat: 50, lon: 20 },
      { lat: 20, lon: 20 },
    ]}
  />
</MappableMap>
```

#### Available `props` for the **Polyline** primitive:

| Name | Type | Description |
|--|--|--|
| points | Point[] | Array of line points |
| strokeColor | string | Line color |
| strokeWidth | number | Line thickness |
| outlineColor | string | Outline color |
| outlineWidth | number | Stroke thickness |
| dashLength | number | Stroke length |
| dashOffset | number | The indentation of the first stroke from the beginning of the polyline |
| gapLength | number | The length of the gap between the strokes |
| onPress | function | Click action |
| zIndex | number | Displaying an element on the Z axis |
| handled | boolean | Enable(**false**)/disable(**true**) event touch propagation for parent `default:true` |

### Polygon

```jsx
import {Polygon, MappableMap} from 'react-native-mappable';

<MappableMap>
  <Polygon
    points={[
      { lat: 50, lon: 50 },
      { lat: 50, lon: 20 },
      { lat: 20, lon: 20 },
    ]}
  />
</MappableMap>
```

#### Available `props` for the **Polygon** primitive:

| Name | Type | Description |
|--|--|--|
| points | Point[] | Array of line points |
| fillColor | string | Fill color |
| strokeColor | string | Border color |
| strokeWidth | number | Border thickness |
| innerRings | (Point[])[] | An array of polylines that form holes in a polygon |
| onPress | function | Click action |
| zIndex | number | Displaying an element on the Z axis |
| handled | boolean | Enable(**false**)/disable(**true**) event touch propagation for parent `default:true` |

## Request routes

Routes can be requested using the `findRoutes` method of the `Mappable` component (via ref).

`findRoutes(points: Point[], vehicles: Vehicles[], callback: (event: RoutesFoundEvent) => void)` - requesting routes through `points` using `vehicles` transport. When receiving routes, a `callback` will be called with information about all routes.

The following routers from Mappable MapKit are available:

-  **masstransit** - for public transport routes;
-  **pedestrian** - for walking routes;
-  **driving** - for routes by car.

The type of router depends on the `vehicles` array passed to the function:

- If an empty array is passed (`this.map.current.findRoutes(points, [], () => null);`), then the `PedestrianRouter` will be used;
- If an array with a single `'car'` element is passed (`this.map.current.findRoutes(points, ['car'], () => null);`), then `DrivingRouter` will be used;
- In all other cases, `MasstransitRouter` is used.

You can also use the desired router by calling the appropriate function:

```typescript
findMasstransitRoutes(points: Point[], callback: (event: RoutesFoundEvent) => void): void;
findPedestrianRoutes(points: Point[], callback: (event: RoutesFoundEvent) => void): void;
findDrivingRoutes(points: Point[], callback: (event: RoutesFoundEvent) => void): void;
```

#### Remark

Depending on the type of router, the route information may vary slightly.

## Geo search (GeoSearch)

To search you need to use the Search module:

```typescript

import { Search } from 'react-native-mappable';

const find = async (query: string, options?: SuggestOptions) => {
  // you can use Point, BoundingBox, Polyline и Polygon (4 points, without innerRings)
  const search = await Search.searchText(
    query,
    { type: GeoFigureType.POINT, value: {lat: 54, lon: 53}},
    { disableSpellingCorrection: true, geometry: true },
  );
  
  const searchByPoint = await Search.searchPoint({lat: 54, lon: 53}, 10, {
    disableSpellingCorrection: true,
    geometry: true,
  });

  const resolveURI = await Search.resolveURI("mappable://geo?data=IgoNAQBYQhUBAFhC", {
    disableSpellingCorrection: true,
    geometry: true,
  });

  const searchByURI = await Search.searchByURI("mappable://geo?data=IgoNAQBYQhUBAFhC", {
    disableSpellingCorrection: true,
    geometry: true,
  });
}
```

You can also now use simplified geocoding methods

```typescript

import { Search } from 'react-native-mappable';

const address = Search.geocodePoint({lat: 54, lon: 53});

const point = Search.geocodeAddress(address.formatted);

```


## Geo search with hints (GeoSuggestions)

To search with hints, you need to use the Suggest module:

```typescript

import { Suggest } from 'react-native-mappable';

const find = async (query: string, options?: SuggestOptions) => {
  const suggestions = await Suggest.suggest(query, options);
  
  const suggestionsWithCoards = await Suggest.suggestWithCoords(query, options);

  // After searh session is finished
  Suggest.reset();
}
```

### Using component ClusteredMappable

```jsx
import React from 'react';
import { ClusteredMappable, Marker } from 'react-native-mappable';

const Map = () => {
  return (
    <ClusteredMappable
      clusterColor="red"
      clusteredMarkers={[
        {
          point: {
            lat: 56.754215,
            lon: 38.622504,
          },
          data: {},
        },
        {
          point: {
            lat: 56.754215,
            lon: 38.222504,
          },
          data: {},
        },
      ]}
      renderMarker={(info, index) => (
        <Marker
          key={index}
          point={info.point}
        />
      )}
      style={{flex: 1}}
    />
  );
};
```
