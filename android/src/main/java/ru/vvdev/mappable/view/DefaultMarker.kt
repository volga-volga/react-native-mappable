package ru.vvdev.mappable.view

import android.animation.ValueAnimator
import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.PointF
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnLayoutChangeListener
import android.view.animation.LinearInterpolator
import android.widget.FrameLayout
import android.widget.TextView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.facebook.react.views.view.ReactViewGroup
import ru.vvdev.mappable.R
import world.mappable.mapkit.geometry.Point
import world.mappable.mapkit.map.MapObject
import world.mappable.mapkit.map.MapObjectTapListener
import world.mappable.mapkit.map.PlacemarkMapObject
import world.mappable.runtime.image.ImageProvider
import ru.vvdev.mappable.models.ReactMapObject
import world.mappable.mapkit.map.IconStyle
import world.mappable.mapkit.map.RotationType

enum class MarkerType(private val layoutInt: Int) {
    SMALL(R.layout.custom_small_marker_layout),
    MIDDLE(R.layout.custom_marker_layout),
    LARGE(R.layout.custom_large_marker_layout);

    companion object {
        fun value(id: Int): Int {
            return entries[id].layoutInt;
        }
    }
}

class DefaultMarker(context: Context?) : ReactViewGroup(context), MapObjectTapListener,
    ReactMapObject {
    @JvmField
    var point: Point? = null
    private var zIndex = 1
    private var markerType: Int = 0
    private var markerText: String = ""
    private var markerSubText: String = ""
    private var markerColor = Color.BLACK
    private var markerIconColor = Color.BLACK
    private var scale = 1f
    private var visible = true
    private var rotated = false
    private var handled = true
    private var markerAnchor: PointF? = null
    private var markerIcon = 0;
    override var rnMapObject: MapObject? = null

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
    }

    private fun createCustomMarker(): Bitmap {
        val markerView: View =
            LayoutInflater.from(context).inflate(MarkerType.value(markerType), null)
        val markerTextLayout = markerView.findViewById<FrameLayout>(R.id.marker_text_layout);
        if (markerText.toBoolean() && markerSubText.toBoolean()) {
            markerTextLayout.visibility = View.VISIBLE
            val markerViewText = markerView.findViewById<TextView>(R.id.marker_text);
            markerViewText.text = markerText
            val markerViewSubText = markerView.findViewById<TextView>(R.id.marker_sub_text);
            markerViewSubText.text = markerSubText
        } else {
            markerTextLayout.visibility = View.GONE
        }
        val markerIconLayout = markerView.findViewById<FrameLayout>(R.id.marker_icon_layout);
        val markerViewIcon = markerView.findViewById<FrameLayout>(R.id.marker_icon);
        markerIconLayout.backgroundTintList =
            ColorStateList(arrayOf(intArrayOf(markerColor)), intArrayOf(markerColor));
        markerViewIcon.setBackgroundResource(DrawableResource.get(markerIcon).resId);
        markerViewIcon.backgroundTintList =
            ColorStateList(arrayOf(intArrayOf(markerIconColor)), intArrayOf(markerIconColor));
        // Convert the view to a bitmap
        markerView.measure(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED)
        markerView.layout(0, 0, markerView.measuredWidth, markerView.measuredHeight)
        val bitmap = Bitmap.createBitmap(
            markerView.measuredWidth,
            markerView.measuredHeight,
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        markerView.draw(canvas)

        return bitmap
    }

    // PROPS
    fun setPoint(_point: Point?) {
        point = _point
        updateMarker()
    }

    fun setType(_type: Int) {
        markerType = _type
        updateMarker()
    }

    fun setIcon(_icon: Int) {
        markerIcon = _icon
        updateMarker()
    }

    fun setText(_markerText: String) {
        markerText = _markerText
        updateMarker()
    }

    fun setMarkerColor(_markerColor: Int) {
        markerColor = _markerColor
        updateMarker()
    }

    fun setMarkerIconColor(_markerIconColor: Int) {
        markerIconColor = _markerIconColor
        updateMarker()
    }

    fun setSubText(_markerSubText: String) {
        markerSubText = _markerSubText
        updateMarker()
    }

    fun setZIndex(_zIndex: Int) {
        zIndex = _zIndex
        updateMarker()
    }

    fun setScale(_scale: Float) {
        scale = _scale
        updateMarker()
    }

    fun setRotated(_rotated: Boolean) {
        rotated = _rotated
        updateMarker()
    }

    fun setVisible(_visible: Boolean) {
        visible = _visible
        updateMarker()
    }

    fun setAnchor(anchor: PointF?) {
        markerAnchor = anchor
        updateMarker()
    }

    fun setHandled(_handled: Boolean) {
        handled = _handled
    }

    private fun updateMarker() {
        if (rnMapObject != null && rnMapObject!!.isValid) {

            val iconStyle = IconStyle()
            iconStyle.setScale(scale)
            iconStyle.setRotationType(if (rotated) RotationType.ROTATE else RotationType.NO_ROTATION)
            iconStyle.setVisible(visible)
            if (markerAnchor != null) {
                iconStyle.setAnchor(markerAnchor)
            }

            val b = createCustomMarker()
            (rnMapObject as PlacemarkMapObject).setIcon(ImageProvider.fromBitmap(b))
            (rnMapObject as PlacemarkMapObject).geometry = point!!
            (rnMapObject as PlacemarkMapObject).zIndex = zIndex.toFloat()

        }
    }
        fun setMarkerMapObject(obj: MapObject?) {
            rnMapObject = obj as PlacemarkMapObject?
            rnMapObject!!.addTapListener(this)
            updateMarker()
        }

        fun moveAnimationLoop(lat: Double, lon: Double) {
            (rnMapObject as PlacemarkMapObject).geometry = Point(lat, lon)
        }

        fun rotateAnimationLoop(delta: Float) {
            (rnMapObject as PlacemarkMapObject).direction = delta
        }

        fun animatedMoveTo(point: Point, duration: Float) {
            val p = (rnMapObject as PlacemarkMapObject).geometry
            val startLat = p.latitude
            val startLon = p.longitude
            val deltaLat = point.latitude - startLat
            val deltaLon = point.longitude - startLon
            val valueAnimator = ValueAnimator.ofFloat(0f, 1f)
            valueAnimator.setDuration(duration.toLong())
            valueAnimator.interpolator = LinearInterpolator()
            valueAnimator.addUpdateListener { animation ->
                try {
                    val v = animation.animatedFraction
                    moveAnimationLoop(startLat + v * deltaLat, startLon + v * deltaLon)
                } catch (ex: Exception) {
                    // I don't care atm..
                }
            }
            valueAnimator.start()
        }

        fun animatedRotateTo(angle: Float, duration: Float) {
            val placemark = (rnMapObject as PlacemarkMapObject)
            val startDirection = placemark.direction
            val delta = angle - placemark.direction
            val valueAnimator = ValueAnimator.ofFloat(0f, 1f)
            valueAnimator.setDuration(duration.toLong())
            valueAnimator.interpolator = LinearInterpolator()
            valueAnimator.addUpdateListener { animation ->
                try {
                    val v = animation.animatedFraction
                    rotateAnimationLoop(startDirection + v * delta)
                } catch (ex: Exception) {
                    // I don't care atm..
                }
            }
            valueAnimator.start()
        }

    override fun onMapObjectTap(mapObject: MapObject, point: Point): Boolean {
        val e = Arguments.createMap()
        (context as ReactContext).getJSModule(RCTEventEmitter::class.java).receiveEvent(
            id, "onPress", e
        )

        return handled
    }
}
