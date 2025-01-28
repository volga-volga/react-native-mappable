package ru.vvdev.mappable

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager
import ru.vvdev.mappable.search.RNMappableSearchModule
import ru.vvdev.mappable.suggest.RNMappableSuggestModule
import java.util.Arrays

class RNMappablePackage : ReactPackage {
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
        return Arrays.asList<NativeModule>(
            RNMappableModule(reactContext),
            RNMappableSuggestModule(reactContext),
            RNMappableSearchModule(reactContext)
        )
    }

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return Arrays.asList<ViewManager<*, *>>(
            MappableViewManager(),
            ClusteredMappableViewManager(),
            MappablePolygonManager(),
            MappablePolylineManager(),
            MappableMarkerManager(),
            MappableCircleManager(),
            MappableDefaultMarkerManager()
        )
    }
}
