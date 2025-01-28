package ru.vvdev.mappable.view

import world.mappable.mapkit.geometry.Point
import world.mappable.mapkit.map.MapObject

interface IMarker {
    fun getPoint(): Point?
    fun setMarkerMapObject(obj: MapObject?)
}