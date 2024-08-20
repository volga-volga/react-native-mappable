package ru.vvdev.mappable.search

import android.content.Context
import world.mappable.mapkit.geometry.Geometry
import world.mappable.mapkit.geometry.Point
import world.mappable.mapkit.search.BusinessObjectMetadata
import world.mappable.mapkit.search.Response
import world.mappable.mapkit.search.SearchFactory
import world.mappable.mapkit.search.SearchManager
import world.mappable.mapkit.search.SearchManagerType
import world.mappable.mapkit.search.SearchOptions
import world.mappable.mapkit.search.Session.SearchListener
import world.mappable.mapkit.search.ToponymObjectMetadata
import world.mappable.mapkit.uri.UriObjectMetadata
import world.mappable.runtime.Error
import ru.vvdev.mappable.utils.Callback

class MappableMapSearchClient(context: Context) : MapSearchClient {
    private val searchManager: SearchManager = SearchFactory.getInstance().createSearchManager(SearchManagerType.COMBINED)

    private fun transformResponse(searchResponse: Response, options: SearchOptions): MapSearchItem {
        val result = MapSearchItem()
        if (options.searchTypes==2) {
            result.formatted =
                searchResponse.collection.children.firstOrNull()?.obj?.metadataContainer
                    ?.getItem(BusinessObjectMetadata::class.java)?.address?.formattedAddress
        } else {
            result.formatted =
                searchResponse.collection.children.firstOrNull()?.obj?.metadataContainer
                    ?.getItem(ToponymObjectMetadata::class.java)?.address?.formattedAddress
        }
        result.uri = searchResponse.collection.children.firstOrNull()?.obj
            ?.metadataContainer
            ?.getItem(UriObjectMetadata::class.java)
            ?.uris
            ?.firstOrNull()
            ?.value
        result.country_code = searchResponse.collection.children.firstOrNull()?.obj?.metadataContainer
            ?.getItem(ToponymObjectMetadata::class.java)?.address?.countryCode
        result.point = searchResponse.collection.children.firstOrNull()?.obj?.geometry?.firstOrNull()?.point
        result.Components = ArrayList(searchResponse.collection.children.size);
        for (i in searchResponse.collection.children) {
            result.Components!!.add(MapSearchItemComponent().apply {
                name = i.obj?.name
                if (options.searchTypes==2) {
                    kind = i.obj?.metadataContainer
                        ?.getItem(BusinessObjectMetadata::class.java)?.address?.components?.lastOrNull()?.kinds?.firstOrNull()?.name
                } else {
                    kind = i.obj?.metadataContainer
                        ?.getItem(ToponymObjectMetadata::class.java)?.address?.components?.lastOrNull()?.kinds?.firstOrNull()?.name
                }
            })
        }
        return result;
    }

    override fun searchPoint(
        point: Point,
        zoom: Int,
        options: SearchOptions,
        onSuccess: Callback<MapSearchItem?>,
        onError: Callback<Throwable?>?
    ) {
        this.searchManager.submit(point, zoom, options, object: SearchListener {
            override fun onSearchResponse(searchResponse: Response) {
                onSuccess.invoke(transformResponse(searchResponse, options))
            }

            override fun onSearchError(error: Error) {
                onError!!.invoke(IllegalStateException("search error: $error"))
            }
        })
    }

    override fun searchAddress(
        text: String,
        geometry: Geometry,
        options: SearchOptions,
        onSuccess: Callback<MapSearchItem?>,
        onError: Callback<Throwable?>?
    ) {
        this.searchManager.submit(text, geometry, options, object: SearchListener {
            override fun onSearchResponse(searchResponse: Response) {
                onSuccess.invoke(transformResponse(searchResponse, options))
            }

            override fun onSearchError(error: Error) {
                onError!!.invoke(IllegalStateException("search error: $error"))
            }
        })
    }

    override fun resolveURI(
        uri: String,
        options: SearchOptions,
        onSuccess: Callback<MapSearchItem?>,
        onError: Callback<Throwable?>?
    ) {
        this.searchManager.resolveURI(uri, options, object: SearchListener {
            override fun onSearchResponse(searchResponse: Response) {
                onSuccess.invoke(transformResponse(searchResponse, options))
            }

            override fun onSearchError(error: Error) {
                onError!!.invoke(IllegalStateException("search error: $error"))
            }
        })
    }

    override fun searchByURI(
        uri: String,
        options: SearchOptions,
        onSuccess: Callback<MapSearchItem?>,
        onError: Callback<Throwable?>?
    ) {
        this.searchManager.searchByURI(uri, options, object: SearchListener {
            override fun onSearchResponse(searchResponse: Response) {
                onSuccess.invoke(transformResponse(searchResponse, options))
            }

            override fun onSearchError(error: Error) {
                onError!!.invoke(IllegalStateException("search error: $error"))
            }
        })
    }
}
