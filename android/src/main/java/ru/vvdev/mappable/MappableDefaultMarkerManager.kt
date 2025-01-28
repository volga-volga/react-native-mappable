package ru.vvdev.mappable

import android.graphics.PointF
import android.view.View
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import ru.vvdev.mappable.view.DefaultMarker
import world.mappable.mapkit.geometry.Point
import javax.annotation.Nonnull

class MappableDefaultMarkerManager internal constructor() : ViewGroupManager<DefaultMarker>() {
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

    private fun castToMarkerView(view: View): DefaultMarker {
        return view as DefaultMarker
    }

    @Nonnull
    public override fun createViewInstance(@Nonnull context: ThemedReactContext): DefaultMarker {
        return DefaultMarker(context)
    }

    // PROPS
    @ReactProp(name = "point")
    fun setPoint(view: View, markerPoint: ReadableMap?) {
        if (markerPoint != null) {
            val lon = markerPoint.getDouble("lon")
            val lat = markerPoint.getDouble("lat")
            val point = Point(lat, lon)
            castToMarkerView(view).setPoint(point)
        }
    }

    @ReactProp(name = "type")
    fun setType(view: View, type: Int) {
        castToMarkerView(view).setType(type)
    }

    @ReactProp(name = "icon")
    fun setIcon(view: View, icon: Int) {
        castToMarkerView(view).setIcon(icon)
    }

    @ReactProp(name = "text")
    fun setText(view: View, text: String) {
        castToMarkerView(view).setText(text)
    }

    @ReactProp(name = "subText")
    fun setSubText(view: View, subText: String) {
        castToMarkerView(view).setText(subText)
    }

    @ReactProp(name = "color")
    fun setMarkerColor(view: View, color: Int) {
        castToMarkerView(view).setMarkerColor(color)
    }

    @ReactProp(name = "iconColor")
    fun setMarkerIconColor(view: View, iconColor: Int) {
        castToMarkerView(view).setMarkerIconColor(iconColor)
    }

    @ReactProp(name = "zIndex")
    fun setZIndex(view: View, zIndex: Int) {
        castToMarkerView(view).setZIndex(zIndex)
    }

    @ReactProp(name = "scale")
    fun setScale(view: View, scale: Float) {
        castToMarkerView(view).setScale(scale)
    }

    @ReactProp(name = "handled")
    fun setHandled(view: View, handled: Boolean?) {
        castToMarkerView(view).setHandled(handled ?: true)
    }

    @ReactProp(name = "rotated")
    fun setRotated(view: View, rotated: Boolean?) {
        castToMarkerView(view).setRotated(rotated ?: true)
    }

    @ReactProp(name = "visible")
    fun setVisible(view: View, visible: Boolean?) {
        castToMarkerView(view).setVisible(visible ?: true)
    }

    @ReactProp(name = "anchor")
    fun setAnchor(view: View, anchor: ReadableMap?) {
        castToMarkerView(view).setAnchor(
            if (anchor != null) PointF(
                anchor.getDouble("x").toFloat(),
                anchor.getDouble("y").toFloat()
            ) else null
        )
    }

    override fun receiveCommand(
        view: DefaultMarker,
        commandType: String,
        args: ReadableArray?
    ) {
        when (commandType) {
            "animatedMoveTo" -> {
                val markerPoint = args!!.getMap(0)
                val moveDuration = args.getInt(1)
                val lon = markerPoint.getDouble("lon").toFloat()
                val lat = markerPoint.getDouble("lat").toFloat()
                val point = Point(lat.toDouble(), lon.toDouble())
                castToMarkerView(view).animatedMoveTo(point, moveDuration.toFloat())
                return
            }

            "animatedRotateTo" -> {
                val angle = args!!.getInt(0)
                val rotateDuration = args.getInt(1)
                castToMarkerView(view).animatedRotateTo(angle.toFloat(), rotateDuration.toFloat())
                return
            }

            else -> throw IllegalArgumentException(
                String.format(
                    "Unsupported command %d received by %s.",
                    commandType,
                    javaClass.simpleName
                )
            )
        }
    }

    companion object {
        const val REACT_CLASS: String = "MappableDefaultMarker"
    }
}
