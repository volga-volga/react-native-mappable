package ru.vvdev.mappable.search

import world.mappable.mapkit.geometry.Geometry
import world.mappable.mapkit.geometry.Point
import world.mappable.mapkit.search.SearchOptions
import ru.vvdev.mappable.utils.Callback

interface MapSearchClient {
    fun searchPoint(
        point: Point,
        zoom: Int,
        options: SearchOptions,
        onSuccess: Callback<MapSearchItem?>,
        onError: Callback<Throwable?>?
    )

    fun searchAddress(
        text: String,
        geometry: Geometry,
        options: SearchOptions,
        onSuccess: Callback<MapSearchItem?>,
        onError: Callback<Throwable?>?
    )

    fun resolveURI(
        uri: String,
        options: SearchOptions,
        onSuccess: Callback<MapSearchItem?>,
        onError: Callback<Throwable?>?
    )

    fun searchByURI(
        uri: String,
        options: SearchOptions,
        onSuccess: Callback<MapSearchItem?>,
        onError: Callback<Throwable?>?
    )
}
