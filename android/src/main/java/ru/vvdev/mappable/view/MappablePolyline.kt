package ru.vvdev.mappable.view

import android.content.Context
import android.graphics.Color
import android.view.ViewGroup
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter
import world.mappable.mapkit.geometry.Point
import world.mappable.mapkit.geometry.Polyline
import world.mappable.mapkit.map.MapObject
import world.mappable.mapkit.map.MapObjectTapListener
import world.mappable.mapkit.map.PolylineMapObject
import ru.vvdev.mappable.models.ReactMapObject
import world.mappable.mapkit.geometry.Geometry

class MappablePolyline(context: Context?) : ViewGroup(context), MapObjectTapListener, ReactMapObject {
    @JvmField
    var polyline: Polyline
    var _points: ArrayList<Point> = ArrayList()
    override var rnMapObject: MapObject? = null
    private var outlineColor = Color.BLACK
    private var strokeColor = Color.BLACK
    private var zIndex = 1
    private var strokeWidth = 1f
    private var dashLength = 1
    private var gapLength = 0
    private var dashOffset = 0f
    private var outlineWidth = 0

    init {
        polyline = Polyline(ArrayList())
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
    }

    // PROPS
    fun setPolygonPoints(points: ArrayList<Point>?) {
        _points = points ?: ArrayList()
        polyline = Polyline(_points)
        updatePolyline()
    }

    fun setZIndex(_zIndex: Int) {
        zIndex = _zIndex
        updatePolyline()
    }

    fun setStrokeColor(_color: Int) {
        strokeColor = _color
        updatePolyline()
    }

    fun setDashLength(length: Int) {
        dashLength = length
        updatePolyline()
    }

    fun setDashOffset(offset: Float) {
        dashOffset = offset
        updatePolyline()
    }

    fun setGapLength(length: Int) {
        gapLength = length
        updatePolyline()
    }

    fun setOutlineWidth(width: Int) {
        outlineWidth = width
        updatePolyline()
    }

    fun setOutlineColor(color: Int) {
        outlineColor = color
        updatePolyline()
    }

    fun setStrokeWidth(width: Float) {
        strokeWidth = width
        updatePolyline()
    }

    private fun updatePolyline() {
        if (rnMapObject != null) {
            (rnMapObject as PolylineMapObject).geometry=polyline
            (rnMapObject as PolylineMapObject).strokeWidth=strokeWidth
            (rnMapObject as PolylineMapObject).setStrokeColor(strokeColor)
            (rnMapObject as PolylineMapObject).zIndex=zIndex.toFloat()
            (rnMapObject as PolylineMapObject).dashLength=dashLength.toFloat()
            (rnMapObject as PolylineMapObject).gapLength=gapLength.toFloat()
            (rnMapObject as PolylineMapObject).dashOffset=dashOffset
            (rnMapObject as PolylineMapObject).outlineColor=outlineColor
            (rnMapObject as PolylineMapObject).outlineWidth=outlineWidth.toFloat()
        }
    }

    fun setPolylineMapObject(obj: MapObject?) {
        rnMapObject = obj as PolylineMapObject?
        rnMapObject!!.addTapListener(this)
        updatePolyline()
    }

    override fun onMapObjectTap(mapObject: MapObject, point: Point): Boolean {
        val e = Arguments.createMap()
        (context as ReactContext).getJSModule(RCTEventEmitter::class.java).receiveEvent(
            id, "onPress", e
        )

        return false
    }
}
