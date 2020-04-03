
import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let pins: [CountryMapPin]

    final class Coordinator: NSObject, MKMapViewDelegate {

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            return nil
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.3)
            circle.lineWidth = 1
            return circle
        }

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        let overlays = pins.compactMap { $0.overlay() }

        let important = pins.dropLast(pins.count - 5).compactMap { $0.coordinate() }
        let region = MKCoordinateRegion(from: important)

        mapView.addOverlays(overlays)
        mapView.setRegion(mapView.regionThatFits(region), animated: false)
    }
}

extension MKCoordinateRegion {

    init(from coordinates: [CLLocationCoordinate2D]) {
        self = MKCoordinateRegion()
        guard let topLeftLatitude = coordinates.max(by: { $0.latitude < $1.latitude })?.latitude,
            let topLeftLongitude = coordinates.min(by: { $0.longitude < $1.longitude })?.longitude,
            let bottomRightLatitude = coordinates.min(by: { $0.latitude < $1.latitude })?.latitude,
            let bottomRightLongitude = coordinates.max(by: { $0.longitude < $1.longitude })?.longitude else { return }

        let latitudeDistance = topLeftLatitude - bottomRightLatitude
        let longitudeDistance = bottomRightLongitude - topLeftLongitude

        self.center = CLLocationCoordinate2D(latitude: topLeftLatitude - latitudeDistance / 2, longitude: bottomRightLongitude - longitudeDistance / 2)
        self.span.latitudeDelta = latitudeDistance * 1.3
        self.span.longitudeDelta = longitudeDistance * 1.3
    }

}
