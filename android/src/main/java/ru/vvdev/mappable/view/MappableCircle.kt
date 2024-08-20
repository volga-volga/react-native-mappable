package ru.vvdev.mappable.view

import android.content.Context
import android.graphics.Color
import android.view.ViewGroup
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter
import world.mappable.mapkit.geometry.Circle
import world.mappable.mapkit.geometry.Point
import world.mappable.mapkit.map.CircleMapObject
import world.mappable.mapkit.map.MapObject
import world.mappable.mapkit.map.MapObjectTapListener
import ru.vvdev.mappable.models.ReactMapObject

class MappableCircle(context: Context?) : ViewGroup(context), MapObjectTapListener, ReactMapObject {
    @JvmField
    var circle: Circle

    override var rnMapObject: MapObject? = null
    private var fillColor = Color.BLACK
    private var strokeColor = Color.BLACK
    private var zIndex = 1
    private var strokeWidth = 2f
    private var center = Point(0.0, 0.0)
    private var radius = 0f

    init {
        circle = Circle(center, radius)
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
    }

    // PROPS
    fun setCenter(point: Point) {
        center = point
        updateGeometry()
        updateCircle()
    }

    fun setRadius(_radius: Float) {
        radius = _radius
        updateGeometry()
        updateCircle()
    }

    private fun updateGeometry() {
        circle = Circle(center, radius)
    }

    fun setZIndex(_zIndex: Int) {
        zIndex = _zIndex
        updateCircle()
    }

    fun setStrokeColor(_color: Int) {
        strokeColor = _color
        updateCircle()
    }

    fun setFillColor(_color: Int) {
        fillColor = _color
        updateCircle()
    }

    fun setStrokeWidth(width: Float) {
        strokeWidth = width
        updateCircle()
    }

    private fun updateCircle() {
        if (rnMapObject != null) {
            (rnMapObject as CircleMapObject).geometry = circle
            (rnMapObject as CircleMapObject).strokeWidth = strokeWidth
            (rnMapObject as CircleMapObject).strokeColor = strokeColor
            (rnMapObject as CircleMapObject).fillColor = fillColor
            (rnMapObject as CircleMapObject).zIndex = zIndex.toFloat()
        }
    }

    fun setCircleMapObject(obj: MapObject?) {
        rnMapObject = obj as CircleMapObject?
        rnMapObject!!.addTapListener(this)
        updateCircle()
    }

    override fun onMapObjectTap(mapObject: MapObject, point: Point): Boolean {
        val e = Arguments.createMap()
        (context as ReactContext).getJSModule(RCTEventEmitter::class.java).receiveEvent(
            id, "onPress", e
        )

        return false
    }
}
