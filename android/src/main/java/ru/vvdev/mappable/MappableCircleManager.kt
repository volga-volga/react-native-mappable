package ru.vvdev.mappable

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import world.mappable.mapkit.geometry.Point
import ru.vvdev.mappable.view.MappableCircle
import javax.annotation.Nonnull

class MappableCircleManager internal constructor() : ViewGroupManager<MappableCircle>() {
    override fun getName(): String {
        return REACT_CLASS
    }

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
        return MapBuilder.builder<String, Any>()
            .put("onPress", MapBuilder.of("registrationName", "onPress"))
            .build()
    }

    override fun getExportedCustomBubblingEventTypeConstants(): MutableMap<String, Any>? {
        return MapBuilder.builder<String, Any>()
            .build()
    }

    @Nonnull
    public override fun createViewInstance(@Nonnull context: ThemedReactContext): MappableCircle {
        return MappableCircle(context)
    }

    // PROPS
    @ReactProp(name = "center")
    fun setCenter(view: MappableCircle, center: ReadableMap?) {
        if (center != null) {
            val lon = center.getDouble("lon")
            val lat = center.getDouble("lat")
            val point = Point(lat, lon)
            view.setCenter(point)
        }
    }

    @ReactProp(name = "radius")
    fun setRadius(view: MappableCircle, radius: Float) {
        view.setRadius(radius)
    }

    @ReactProp(name = "strokeWidth")
    fun setStrokeWidth(view: MappableCircle, width: Float) {
        view.setStrokeWidth(width)
    }

    @ReactProp(name = "strokeColor")
    fun setStrokeColor(view: MappableCircle, color: Int) {
        view.setStrokeColor(color)
    }

    @ReactProp(name = "fillColor")
    fun setFillColor(view: MappableCircle, color: Int) {
        view.setFillColor(color)
    }

    @ReactProp(name = "zIndex")
    fun setZIndex(view: MappableCircle, zIndex: Int) {
        view.setZIndex(zIndex)
    }

    @ReactProp(name = "handled")
    fun setHandled(view: MappableCircle, handled: Boolean?) {
        view.setHandled(handled ?: true)
    }


    companion object {
        const val REACT_CLASS: String = "MappableCircle"
    }
}
