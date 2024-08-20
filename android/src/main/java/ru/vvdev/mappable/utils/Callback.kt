package ru.vvdev.mappable.utils

interface Callback<T> {
    fun invoke(arg: T)
}
