package ru.vvdev.mappable.suggest

import android.content.Context
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil
import ru.vvdev.mappable.utils.Callback

class RNMappableSuggestModule(reactContext: ReactApplicationContext?) :
    ReactContextBaseJavaModule(reactContext) {
    private var suggestClient: MapSuggestClient? = null
    private val argsHelper = MappableSuggestRNArgsHelper()

    override fun getName(): String {
        return "MappableSuggests"
    }

    @ReactMethod
    fun suggest(text: String?, promise: Promise) {
        if (text == null) {
            promise.reject(ERR_NO_REQUEST_ARG, "suggest request: text arg is not provided")
            return
        }

        UiThreadUtil.runOnUiThread {
            getSuggestClient(reactApplicationContext).suggest(text,
                object : Callback<List<MapSuggestItem?>?> {
                    override fun invoke(arg: List<MapSuggestItem?>?) {
                        promise.resolve(argsHelper.createSuggestsMapFrom(arg))
                    }
                },
                object : Callback<Throwable?> {
                    override fun invoke(arg: Throwable?) {
                        promise.reject(ERR_SUGGEST_FAILED, "suggest request: " + arg?.message)
                    }
                }
            )
        }
    }

    @ReactMethod
    fun suggestWithOptions(text: String?, options: ReadableMap?, promise: Promise) {
        if (text == null) {
            promise.reject(ERR_NO_REQUEST_ARG, "suggest request: text arg is not provided")
            return
        }

        UiThreadUtil.runOnUiThread {
            getSuggestClient(reactApplicationContext).suggest(text, options,
                object : Callback<List<MapSuggestItem?>?> {
                    override fun invoke(arg: List<MapSuggestItem?>?) {
                        promise.resolve(argsHelper.createSuggestsMapFrom(arg))
                    }
                },
                object : Callback<Throwable?> {
                    override fun invoke(arg: Throwable?) {
                        promise.reject(ERR_SUGGEST_FAILED, "suggest request: " + arg?.message)
                    }
                }
            )
        }
    }

    @ReactMethod
    fun reset() {
        UiThreadUtil.runOnUiThread { getSuggestClient(reactApplicationContext).resetSuggest() }
    }

    private fun getSuggestClient(context: Context): MapSuggestClient {
        if (suggestClient == null) {
            suggestClient = MappableMapSuggestClient(context)
        }

        return suggestClient as MapSuggestClient
    }

    companion object {
        private const val ERR_NO_REQUEST_ARG = "MAPPABLE_SUGGEST_ERR_NO_REQUEST_ARG"
        private const val ERR_SUGGEST_FAILED = "MAPPABLE_SUGGEST_ERR_SUGGEST_FAILED"
    }
}
