import MappableMobile
import UIKit

@objc(MappableSearch)
class MappableSearch: NSObject {
    enum ArrayError: Error {
        case indexOutOfBounds
    }

    var searchManager: MMKSearchManager?
    let defaultBoundingBox: MMKBoundingBox
    var searchSession: MMKSearchSession?
    var searchOptions: MMKSearchOptions

    let ERR_NO_REQUEST_ARG = "MAPPABLE_SEARCH_ERR_NO_REQUEST_ARG"
    let ERR_SEARCH_FAILED = "MAPPABLE_SEARCH_ERR_SEARCH_FAILED"

    override init() {
        let southWestPoint = MMKPoint(latitude: -90.0, longitude: -180.0)
        let northEastPoint = MMKPoint(latitude: -85.0, longitude: -175.0)
        self.defaultBoundingBox = MMKBoundingBox(southWest: southWestPoint, northEast: northEastPoint)
        self.searchOptions = MMKSearchOptions()
        super.init()
    }

    private func setSearchOptions(options: [String: Any]?) -> Void {
        self.searchOptions = MMKSearchOptions();
        if ((options?.keys) != nil) {
            for (key, value) in options! {
                self.searchOptions.setValue(value, forKey: key)
            }
        }
    }

    func runOnMainQueueWithoutDeadlocking(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync(execute: block)
        }
    }

    func initSearchManager() -> Void {
        if searchManager == nil {
            runOnMainQueueWithoutDeadlocking {
                self.searchManager = MMKSearch.sharedInstance().createSearchManager(with: .online)
            }
        }
    }

    private func getGeometry(figure: [String: Any]?) throws -> MMKGeometry {
        if (figure == nil) {
            return MMKGeometry(boundingBox: self.defaultBoundingBox)
        }
        if (figure!["type"] as! String=="POINT") {
            return MMKGeometry.init(point: MMKPoint(latitude: (figure!["value"] as! [String: Any])["lat"] as! Double, longitude: (figure!["value"] as! [String: Any])["lon"] as! Double))
        }
        if (figure!["type"] as! String=="BOUNDINGBOX") {
            var southWest = MMKPoint(latitude: ((figure!["value"] as! [String: Any])["southWest"] as! [String: Any])["lat"] as! Double, longitude: ((figure!["value"] as! [String: Any])["southWest"] as! [String: Any])["lon"] as! Double)
            var northEast = MMKPoint(latitude: ((figure!["value"] as! [String: Any])["northEast"] as! [String: Any])["lat"] as! Double, longitude: ((figure!["value"] as! [String: Any])["northEast"] as! [String: Any])["lon"] as! Double)
            return MMKGeometry.init(boundingBox: MMKBoundingBox(southWest: southWest, northEast: northEast))
        }
        if (figure!["type"] as! String=="POLYLINE") {
            let points = (figure!["value"] as! [String: Any])["points"] as! [[String: Any]];
            var convertedPoints = [MMKPoint]()
            points.forEach{point in
                convertedPoints.append(MMKPoint(latitude: point["lat"] as! Double, longitude: point["lon"] as! Double))
            }
            return MMKGeometry.init(polyline: MMKPolyline(points:convertedPoints))
        }
        if (figure!["type"] as! String=="POLYGON") {
            let linearRingPoints = (figure!["value"] as! [String: Any])["points"] as! [[String: Any]];
            if (linearRingPoints.count != 4) {
                throw ArrayError.indexOutOfBounds
            }
            var convertedlinearRingPoints = [MMKPoint]()
            linearRingPoints.forEach{point in
                convertedlinearRingPoints.append(MMKPoint(latitude: point["lat"] as! Double, longitude: point["lon"] as! Double))
            }
            return MMKGeometry.init(polygon: MMKPolygon(outerRing: MMKLinearRing(points: convertedlinearRingPoints), innerRings: []))
        }
        return MMKGeometry(boundingBox: self.defaultBoundingBox)
    }

    private func convertSearchResponce(search: MMKSearchResponse?) -> [String: Any] {
        var searchToPass = [String: Any]()
        let geoObjects = search?.collection.children.compactMap { $0.obj }

        searchToPass["formatted"] = (
            geoObjects?.first?.metadataContainer
                .getItemOf(MMKSearchToponymObjectMetadata.self) as? MMKSearchToponymObjectMetadata
        )?.address.formattedAddress

        searchToPass["country_code"] = (
            geoObjects?.first?.metadataContainer
                .getItemOf(MMKSearchToponymObjectMetadata.self) as? MMKSearchToponymObjectMetadata
        )?.address.countryCode

        var components = [[String: Any]]()

        geoObjects?.forEach { geoItem in
            var component = [String: Any]()
            component["name"] = geoItem.name
            component["kind"] = (
                geoItem.metadataContainer
                    .getItemOf(MMKSearchToponymObjectMetadata.self) as? MMKSearchToponymObjectMetadata
            )?.address.components.last?.kinds.first?.stringValue
            components.append(component)
        }

        searchToPass["Components"] = components
        searchToPass["uri"] = (
            geoObjects?.first?.metadataContainer.getItemOf(MMKUriObjectMetadata.self) as? MMKUriObjectMetadata
        )?.uris.first?.value

        return searchToPass;
    }

    @objc func searchByAddress(_ searchQuery: String, figure: [String: Any]?, options: [String: Any]?, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        self.initSearchManager()
        do {
            self.setSearchOptions(options: options)
            let geometryFigure: MMKGeometry = try self.getGeometry(figure: figure)
            runOnMainQueueWithoutDeadlocking {
                self.searchSession = self.searchManager?.submit(withText: searchQuery, geometry: geometryFigure, searchOptions: self.searchOptions, responseHandler: { search, error in
                    if let error = error {
                        rejecter(self.ERR_SEARCH_FAILED, "search request: \(searchQuery)", error)
                        return
                    }

                    resolver(self.convertSearchResponce(search: search))
                })
            }
        } catch {
            rejecter(ERR_NO_REQUEST_ARG, "search request: \(searchQuery)", nil)
        }
    }

    @objc func addressToGeo(_ searchQuery: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        self.initSearchManager()
        do {
            self.setSearchOptions(options: nil)
            runOnMainQueueWithoutDeadlocking {
                self.searchSession = self.searchManager?.submit(withText: searchQuery, geometry: MMKGeometry(boundingBox: self.defaultBoundingBox), searchOptions: self.searchOptions, responseHandler: { search, error in
                    if let error = error {
                        rejecter(self.ERR_SEARCH_FAILED, "search request: \(searchQuery)", error)
                        return
                    }

                    let geoObjects = search?.collection.children.compactMap { $0.obj }

                    let point = (
                        geoObjects?.first?.metadataContainer
                            .getItemOf(MMKSearchToponymObjectMetadata.self) as? MMKSearchToponymObjectMetadata
                    )?.balloonPoint
                    let searchPoint = ["lat": point?.latitude, "lon": point?.longitude];

                    resolver(searchPoint)

                })
            }
        } catch {
            rejecter(ERR_NO_REQUEST_ARG, "search request: \(searchQuery)", nil)
        }
    }

    @objc func searchByPoint(_ point: [String: Any], zoom: NSNumber, options: [String: Any]?, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        let searchPoint = MMKPoint(latitude: point["lat"] as! Double, longitude: point["lat"] as! Double)
        self.initSearchManager()
        self.setSearchOptions(options: options)
        runOnMainQueueWithoutDeadlocking {
            self.searchSession = self.searchManager?.submit(with: searchPoint, zoom: zoom, searchOptions: self.searchOptions, responseHandler: { search, error in
                if let error = error {
                    rejecter(self.ERR_SEARCH_FAILED, "search request: \(point)", error)
                    return
                }

                resolver(self.convertSearchResponce(search: search))
            })
        }
    }

    @objc func geoToAddress(_ point: [String: Any], resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        let searchPoint = MMKPoint(latitude: point["lat"] as! Double, longitude: point["lat"] as! Double)
        self.initSearchManager()
        self.setSearchOptions(options: nil)
        runOnMainQueueWithoutDeadlocking {
            self.searchSession = self.searchManager?.submit(with: searchPoint, zoom: 10, searchOptions: self.searchOptions, responseHandler: { search, error in
                if let error = error {
                    rejecter(self.ERR_SEARCH_FAILED, "search request: \(point)", error)
                    return
                }

                resolver(self.convertSearchResponce(search: search))
            })
        }
    }

    @objc func searchByURI(_ searchUri: NSString, options: [String: Any]?, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        self.initSearchManager()
        self.setSearchOptions(options: options)
        runOnMainQueueWithoutDeadlocking {
            self.searchSession = self.searchManager?.searchByURI(withUri: searchUri as String, searchOptions: self.searchOptions, responseHandler: { search, error in
                if let error = error {
                    rejecter(self.ERR_SEARCH_FAILED, "search request: \(searchUri)", error)
                    return
                }

                resolver(self.convertSearchResponce(search: search))
            })
        }
    }

    @objc func resolveURI(_ searchUri: NSString, options: [String: Any]?, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        self.initSearchManager()
        self.setSearchOptions(options: options)
        runOnMainQueueWithoutDeadlocking {
            self.searchSession = self.searchManager?.resolveURI(withUri: searchUri as String, searchOptions: self.searchOptions, responseHandler: { search, error in
                if let error = error {
                    rejecter(self.ERR_SEARCH_FAILED, "search request: \(searchUri)", error)
                    return
                }

                resolver(self.convertSearchResponce(search: search))
            })
        }
    }

    @objc static func moduleName() -> String {
        return "MappableSearch"
    }
}
