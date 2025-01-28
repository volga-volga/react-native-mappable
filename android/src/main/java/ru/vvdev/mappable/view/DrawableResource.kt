package ru.vvdev.mappable.view

import ru.vvdev.mappable.R

enum class DrawableResource(val resId: Int) {
    RESTAURANTS(R.drawable.restaurants_24),
    AIRPORT(R.drawable.airport_24);

    companion object {
        fun get(resId: Int): DrawableResource {
            return entries[resId];
        }
    }
}