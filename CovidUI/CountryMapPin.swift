

import Foundation
import MapKit

struct Coordinates {
    @GraphQL(Covid.Coordinates.latitude)
    var latitude

    @GraphQL(Covid.Coordinates.longitude)
    var longitude
}

struct Polygon {
    @GraphQL(Covid.Polygon.points)
    var points: [Coordinates]
}

extension Polygon {

    final class MapKitPolygon: MKPolygon {
        fileprivate(set) var active: Int = 0
    }

    func overlay(active: Int) -> MKPolygon {
        let coordinates = UnsafeMutableBufferPointer<CLLocationCoordinate2D>.allocate(capacity: points.count)
        _ = coordinates.initialize(from: points.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
        let polygon = MapKitPolygon(coordinates: UnsafePointer(coordinates.baseAddress!), count: points.count)
        polygon.active = active
        return polygon
    }

}

struct MultiPolygon {
    @GraphQL(Covid.MultiPolygon.polygons)
    var polygons: [Polygon]
}

struct CountryMapPin {
    @GraphQL(Covid.Country.active)
    var active

    @GraphQL(Covid.Country.geometry.polygon)
    var polygon: Polygon?

    @GraphQL(Covid.Country.geometry.multiPolygon)
    var multiPolygon: MultiPolygon?

    @GraphQL(Covid.Country.info.latitude)
    var latitude: Double?
    
    @GraphQL(Covid.Country.info.longitude)
    var longitude: Double?

    func overlay() -> [MKOverlay] {
        if let polygon = polygon {
            return [polygon.overlay(active: active)]
        }

        if let multiPolygon = multiPolygon {
            return multiPolygon.polygons.map { $0.overlay(active: active) }
        }

        return []
    }

    func coordinate() -> CLLocationCoordinate2D? {
        guard let latitude = latitude, let longitude = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
