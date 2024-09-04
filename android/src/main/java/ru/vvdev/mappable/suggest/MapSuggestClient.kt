package ru.vvdev.mappable.suggest

import com.facebook.react.bridge.ReadableMap
import ru.vvdev.mappable.utils.Callback

interface MapSuggestClient {
    fun suggest(
        text: String?,
        onSuccess: Callback<List<MapSuggestItem?>?>?,
        onError: Callback<Throwable?>?
    )

    fun suggest(
        text: String?,
        options: ReadableMap?,
        onSuccess: Callback<List<MapSuggestItem?>?>?,
        onError: Callback<Throwable?>?
    )
    fun resetSuggest()
}
