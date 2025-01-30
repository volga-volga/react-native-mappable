package ru.vvdev.mappable.view

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.PointF
import android.view.View
import android.view.View.OnLayoutChangeListener
import android.view.animation.LinearInterpolator
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.facebook.react.views.view.ReactViewGroup
import world.mappable.mapkit.geometry.Point
import world.mappable.mapkit.map.IconStyle
import world.mappable.mapkit.map.MapObject
import world.mappable.mapkit.map.MapObjectTapListener
import world.mappable.mapkit.map.PlacemarkMapObject
import world.mappable.mapkit.map.RotationType
import world.mappable.runtime.image.ImageProvider
import ru.vvdev.mappable.models.ReactMapObject
import ru.vvdev.mappable.utils.Callback
import ru.vvdev.mappable.utils.ImageLoader.DownloadImageBitmap

class MappableMarker(context: Context?) : ReactViewGroup(context), MapObjectTapListener,
    ReactMapObject, IMarker {
    @JvmField
    var point: Point? = null
    private var zIndex = 1
    private var scale = 1f
    private var visible = true
    private var rotated = false
    private var handled = true
    private var markerAnchor: PointF? = null
    private var iconSource: String? = null
    private var _childView: View? = null
    override var rnMapObject: MapObject? = null
    private val childs = ArrayList<View>()

    private val childLayoutListener =
        OnLayoutChangeListener { v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom -> updateMarker() }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
    }

    // PROPS
    fun setPoint(_point: Point?) {
        point = _point
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

    fun setIconSource(source: String?) {
        iconSource = source
        updateMarker()
    }

    fun setAnchor(anchor: PointF?) {
        markerAnchor = anchor
        updateMarker()
    }

//    private fun createCustomMarker(): Bitmap {
//        val markerView: View = LayoutInflater.from(context).inflate(R.layout.custom_marker_layout, null)
//        val markerTextLayout = markerView.findViewById<FrameLayout>(R.id.marker_text_layout);
//        markerTextLayout.visibility = View.GONE
////        val markerText = markerView.findViewById<TextView>(R.id.marker_text);
////        markerText.setText("МаркерТекст1")
////        val markerSubText = markerView.findViewById<TextView>(R.id.marker_sub_text);
////        markerSubText.setText("МаркерСубТекст1")
//        val markerIconLayout = markerView.findViewById<FrameLayout>(R.id.marker_icon_layout);
//        val markerIcon = markerView.findViewById<FrameLayout>(R.id.marker_icon);
//        markerIconLayout.backgroundTintList = ColorStateList(arrayOf(intArrayOf(Color.RED)), intArrayOf(Color.CYAN));
//        markerIcon.setBackgroundResource(R.drawable.restaurants_24)
//        markerIcon.backgroundTintList = ColorStateList(arrayOf(intArrayOf(Color.WHITE)), intArrayOf(Color.WHITE));
////        markerIconLayout.background = ColorStateList(arrayOf(intArrayOf(Color.RED)), intArrayOf(Color.CYAN));
//
//        // Convert the view to a bitmap
//        markerView.measure(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED)
//        markerView.layout(0, 0, markerView.measuredWidth, markerView.measuredHeight)
//        val bitmap = Bitmap.createBitmap(
//            markerView.measuredWidth,
//            markerView.measuredHeight,
//            Bitmap.Config.ARGB_8888
//        )
//        val canvas = Canvas(bitmap)
//        markerView.draw(canvas)
//
//        return bitmap
//    }

    private fun updateMarker() {
        if (rnMapObject != null && rnMapObject!!.isValid) {
            val iconStyle = IconStyle()
            iconStyle.setScale(scale)
            iconStyle.setRotationType(if (rotated) RotationType.ROTATE else RotationType.NO_ROTATION)
            iconStyle.setVisible(visible)
            if (markerAnchor != null) {
                iconStyle.setAnchor(markerAnchor)
            }
            (rnMapObject as PlacemarkMapObject).geometry = point!!
            (rnMapObject as PlacemarkMapObject).zIndex = zIndex.toFloat()

            if (_childView != null) {
                try {
                    val b = Bitmap.createBitmap(
                        _childView!!.width, _childView!!.height, Bitmap.Config.ARGB_8888
                    )
                    val c = Canvas(b)
                    _childView!!.draw(c)
                    (rnMapObject as PlacemarkMapObject).setIcon(ImageProvider.fromBitmap(b))
                    (rnMapObject as PlacemarkMapObject).setIconStyle(iconStyle)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            if (childs.size == 0) {
                if (iconSource != "") {
                    iconSource?.let {
                        DownloadImageBitmap(context, it, object : Callback<Bitmap?> {
                            override fun invoke(arg: Bitmap?) {
                                try {
                                    val icon = ImageProvider.fromBitmap(arg)
                                    (rnMapObject as PlacemarkMapObject).setIcon(icon)
                                    (rnMapObject as PlacemarkMapObject).setIconStyle(iconStyle)
                                } catch (e: Exception) {
                                    e.printStackTrace()
                                }
                            }
                        })
                    }
                }
            }
        }
    }

    override fun getPoint(): Point? {
        return point
    }

    override fun setMarkerMapObject(obj: MapObject?) {
        rnMapObject = obj as PlacemarkMapObject?
        rnMapObject!!.addTapListener(this)
        updateMarker()
    }

    fun setHandled(_handled: Boolean) {
        handled = _handled
    }

    fun setChildView(view: View?) {
        if (view == null) {
            _childView!!.removeOnLayoutChangeListener(childLayoutListener)
            _childView = null
            updateMarker()
            return
        }
        _childView = view
        _childView!!.addOnLayoutChangeListener(childLayoutListener)
    }

    fun addChildView(view: View, index: Int) {
        childs.add(index, view)
        setChildView(childs[0])
    }

    fun removeChildView(index: Int) {
        childs.removeAt(index)
        setChildView(if (childs.size > 0) childs[0] else null)
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
