package ru.vvdev.mappable

import android.view.View
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import world.mappable.mapkit.geometry.Point
import ru.vvdev.mappable.view.MappablePolygon
import javax.annotation.Nonnull

class MappablePolygonManager internal constructor() : ViewGroupManager<MappablePolygon>() {
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

    private fun castToPolygonView(view: View): MappablePolygon {
        return view as MappablePolygon
    }

    @Nonnull
    public override fun createViewInstance(@Nonnull context: ThemedReactContext): MappablePolygon {
        return MappablePolygon(context)
    }

    // PROPS
    @ReactProp(name = "points")
    fun setPoints(view: View, points: ReadableArray?) {
        if (points != null) {
            val parsed = ArrayList<Point>()
            for (i in 0 until points.size()) {
                val markerMap = points.getMap(i)
                if (markerMap != null) {
                    val lon = markerMap.getDouble("lon")
                    val lat = markerMap.getDouble("lat")
                    val point = Point(lat, lon)
                    parsed.add(point)
                }
            }
            castToPolygonView(view).setPolygonPoints(parsed)
        }
    }

    @ReactProp(name = "innerRings")
    fun setInnerRings(view: View, _rings: ReadableArray?) {
        val rings = ArrayList<ArrayList<Point>>()
        if (_rings != null) {
            for (j in 0 until _rings.size()) {
                val points = _rings.getArray(j)
                if (points != null) {
                    val parsed = ArrayList<Point>()
                    for (i in 0 until points.size()) {
                        val markerMap = points.getMap(i)
                        if (markerMap != null) {
                            val lon = markerMap.getDouble("lon")
                            val lat = markerMap.getDouble("lat")
                            val point = Point(lat, lon)
                            parsed.add(point)
                        }
                    }
                    rings.add(parsed)
                }
            }
        }
        castToPolygonView(view).setPolygonInnerRings(rings)
    }

    @ReactProp(name = "strokeWidth")
    fun setStrokeWidth(view: View, width: Float) {
        castToPolygonView(view).setStrokeWidth(width)
    }

    @ReactProp(name = "strokeColor")
    fun setStrokeColor(view: View, color: Int) {
        castToPolygonView(view).setStrokeColor(color)
    }

    @ReactProp(name = "fillColor")
    fun setFillColor(view: View, color: Int) {
        castToPolygonView(view).setFillColor(color)
    }

    @ReactProp(name = "zIndex")
    fun setZIndex(view: View, zIndex: Int) {
        castToPolygonView(view).setZIndex(zIndex)
    }

    companion object {
        const val REACT_CLASS: String = "MappablePolygon"
    }
}