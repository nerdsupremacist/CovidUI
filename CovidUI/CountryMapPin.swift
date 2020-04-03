

import Foundation
import MapKit

struct CountryMapPin {
    @GraphQL(Covid.Country.cases)
    var cases: Int

    @GraphQL(Covid.Country.info.latitude)
    var latitude: Double?

    @GraphQL(Covid.Country.info.longitude)
    var longitude: Double?

    func overlay() -> MKOverlay? {
        return coordinate().map { MKCircle(center: $0, radius: min(max(Double(cases) * 5, 500), 5_000_000)) }
    }

    func coordinate() -> CLLocationCoordinate2D? {
        guard let latitude = latitude, let longitude = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
