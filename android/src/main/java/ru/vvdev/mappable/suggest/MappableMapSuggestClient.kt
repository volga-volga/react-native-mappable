package ru.vvdev.mappable.suggest

import android.content.Context
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
import world.mappable.mapkit.geometry.BoundingBox
import world.mappable.mapkit.geometry.Point
import world.mappable.mapkit.search.SearchFactory
import world.mappable.mapkit.search.SearchManager
import world.mappable.mapkit.search.SearchManagerType
import world.mappable.mapkit.search.SearchType
import world.mappable.mapkit.search.SuggestOptions
import world.mappable.mapkit.search.SuggestResponse
import world.mappable.mapkit.search.SuggestSession
import world.mappable.mapkit.search.SuggestSession.SuggestListener
import world.mappable.mapkit.search.SuggestType
import world.mappable.runtime.Error
import ru.vvdev.mappable.utils.Callback

class MappableMapSuggestClient(context: Context?) : MapSuggestClient {
    private val searchManager: SearchManager
    private val suggestOptions = SuggestOptions()
    private var suggestSession: SuggestSession? = null

    /**
     * Для Яндекса нужно указать географическую область поиска. В дефолтном варианте мы не знаем какие
     * границы для каждого конкретного города, поэтому поиск осуществляется по всему миру.
     * Для `BoundingBox` нужно указать ширину и долготу для юго-западной точки и северо-восточной
     * в градусах. Получается, что координаты самой юго-западной точки, это
     * ширина = -90, долгота = -180, а самой северо-восточной - ширина = 90, долгота = 180
     */
    private val defaultGeometry = BoundingBox(Point(-90.0, -180.0), Point(90.0, 180.0))

    init {
        searchManager = SearchFactory.getInstance().createSearchManager(SearchManagerType.COMBINED)
        suggestOptions.setSuggestTypes(SearchType.GEO.value)
    }

    private fun suggestHandler(
        text: String?,
        options: SuggestOptions,
        boundingBox: BoundingBox,
        onSuccess: Callback<List<MapSuggestItem?>?>?,
        onError: Callback<Throwable?>?
    ) {
        if (suggestSession == null) {
            suggestSession = searchManager.createSuggestSession()
        }

        suggestSession!!.suggest(
            text!!,
            boundingBox,
            options,
            object : SuggestListener {
                override fun onResponse(suggestResponse: SuggestResponse) {
                    val result: MutableList<MapSuggestItem?> = ArrayList(suggestResponse.items.size)
                    for (i in suggestResponse.items.indices) {
                        val rawSuggest = suggestResponse.items[i]
                        val suggest = MapSuggestItem()
                        suggest.searchText = rawSuggest.searchText
                        suggest.title = rawSuggest.title.text
                        if (rawSuggest.subtitle != null) {
                            suggest.subtitle = rawSuggest.subtitle!!.text
                        }
                        suggest.uri = rawSuggest.uri
                        result.add(suggest)
                    }
                    onSuccess!!.invoke(result)
                }

                override fun onError(error: Error) {
                    onError!!.invoke(IllegalStateException("suggest error: $error"))
                }
            }
        )
    }

    private fun mapPoint(readableMap: ReadableMap?, pointKey: String): Point {
        val lonKey = "lon"
        val latKey = "lat"

        check(readableMap!!.getType(pointKey) == ReadableType.Map) { "suggest error: $pointKey is not an Object" }
        val pointMap = readableMap.getMap(pointKey)

        check(!(!pointMap!!.hasKey(latKey) || !pointMap.hasKey(lonKey))) { "suggest error: $pointKey does not have lat or lon" }

        check(!(pointMap.getType(latKey) != ReadableType.Number || pointMap.getType(lonKey) != ReadableType.Number)) { "suggest error: lat or lon is not a Number" }

        val lat = pointMap.getDouble(latKey)
        val lon = pointMap.getDouble(lonKey)

        return Point(lat, lon)
    }

    override fun suggest(
        text: String?,
        onSuccess: Callback<List<MapSuggestItem?>?>?,
        onError: Callback<Throwable?>?
    ) {
        this.suggestHandler(text, this.suggestOptions, this.defaultGeometry, onSuccess, onError)
    }

    override fun suggest(
        text: String?,
        options: ReadableMap?,
        onSuccess: Callback<List<MapSuggestItem?>?>?,
        onError: Callback<Throwable?>?
    ) {
        val userPositionKey = "userPosition"
        val suggestWordsKey = "suggestWords"
        val suggestTypesKey = "suggestTypes"
        val boundingBoxKey = "boundingBox"
        val southWestKey = "southWest"
        val northEastKey = "northEast"

        val options_ = SuggestOptions()

        var suggestType = SuggestType.GEO.value
        var boundingBox = this.defaultGeometry

        if (options!!.hasKey(suggestWordsKey) && !options.isNull(suggestWordsKey)) {
            if (options.getType(suggestWordsKey) != ReadableType.Boolean) {
                onError!!.invoke(IllegalStateException("suggest error: $suggestWordsKey is not a Boolean"))
                return
            }
            val suggestWords = options.getBoolean(suggestWordsKey)

            options_.setSuggestWords(suggestWords)
        }

        if (options.hasKey(boundingBoxKey) && !options.isNull(boundingBoxKey)) {
            if (options.getType(boundingBoxKey) != ReadableType.Map) {
                onError!!.invoke(IllegalStateException("suggest error: $boundingBoxKey is not an Object"))
                return
            }
            val boundingBoxMap = options.getMap(boundingBoxKey)

            if (!boundingBoxMap!!.hasKey(southWestKey) || !boundingBoxMap.hasKey(northEastKey)) {
                onError!!.invoke(IllegalStateException("suggest error: $boundingBoxKey does not have southWest or northEast"))
                return
            }

            try {
                val southWest = mapPoint(boundingBoxMap, southWestKey)
                val northEast = mapPoint(boundingBoxMap, northEastKey)
                boundingBox = BoundingBox(southWest, northEast)
            } catch (bbex: Exception) {
                onError!!.invoke(bbex)
                return
            }
        }

        if (options.hasKey(userPositionKey) && !options.isNull(userPositionKey)) {
            try {
                val userPosition = mapPoint(options, userPositionKey)
                options_.setUserPosition(userPosition)
            } catch (upex: Exception) {
                onError!!.invoke(upex)
                return
            }
        }

        if (options.hasKey(suggestTypesKey) && !options.isNull(suggestTypesKey)) {
            if (options.getType(suggestTypesKey) != ReadableType.Array) {
                onError!!.invoke(IllegalStateException("suggest error: $suggestTypesKey is not an Array"))
                return
            }
            suggestType = SuggestType.UNSPECIFIED.value
            val suggestTypesArray = options.getArray(suggestTypesKey)
            for (i in 0 until suggestTypesArray!!.size()) {
                if (suggestTypesArray.getType(i) != ReadableType.Number) {
                    onError!!.invoke(IllegalStateException("suggest error: one or more $suggestTypesKey is not an Number"))
                    return
                }
                val value = suggestTypesArray.getInt(i)
                suggestType = suggestType or value
            }
        }

        options_.setSuggestTypes(suggestType)
        this.suggestHandler(text, options_, boundingBox, onSuccess, onError)
    }

    override fun resetSuggest() {
        if (suggestSession != null) {
            suggestSession!!.reset()
            suggestSession = null
        }
    }
}
