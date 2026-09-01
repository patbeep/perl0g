import CoreLocation
import Combine

/// A small wrapper around `CLLocationManager` used only for the
/// optional "Use Current Location" button in the entry editor. Perlog
/// never tracks location in the background — this is a one-shot lookup
/// triggered explicitly by the user.
final class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var placeName: String?
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var isResolving: Bool = false
    @Published var errorMessage: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestCurrentLocation() {
        errorMessage = nil
        isResolving = true
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            isResolving = false
            errorMessage = "Location access is off. You can enable it in Settings, or type a place name instead."
        default:
            manager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied {
            isResolving = false
            errorMessage = "Location access is off. You can enable it in Settings, or type a place name instead."
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self else { return }
            self.isResolving = false
            if let placemark = placemarks?.first {
                self.placeName = [placemark.name, placemark.locality].compactMap { $0 }.joined(separator: ", ")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isResolving = false
        errorMessage = "Couldn't determine your location. You can type a place name instead."
    }
}
