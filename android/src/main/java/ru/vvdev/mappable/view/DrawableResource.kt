package ru.vvdev.mappable.view

import ru.vvdev.mappable.R

enum class DrawableResource(val resId: Int) {

    AIRFIELD(R.drawable.airfield_24),
    AIRPORT(R.drawable.airport_24),
    AUTO(R.drawable.auto_24),
    BARS(R.drawable.bars_24),
    BEACH(R.drawable.beach_24),
    BUILDING(R.drawable.building_24),
    CAFE(R.drawable.cafe_24),
    FAST_FOOD(R.drawable.fast_food_24),
    RESTAURANTS(R.drawable.restaurants_24),
    WC(R.drawable.wc_24);

    companion object {
        fun get(resId: Int): DrawableResource {
            return entries[resId];
        }
    }
}
