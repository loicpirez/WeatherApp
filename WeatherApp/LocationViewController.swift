import UIKit
import MapKit

@available(iOS 10.0, *)
class LocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var chooseButton: UIButton!
    var locationManager:CLLocationManager!
    var annotation: MKPointAnnotation = MKPointAnnotation()
    @IBOutlet weak var searchBar: UISearchBar!

    var city : NSString = ""

    @IBAction func chooseButtonClicked(_ sender: UIButton) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: self.annotation.coordinate.latitude, longitude: self.annotation.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            self.city = placeMark.addressDictionary!["City"] as? NSString ?? "nil"
            let user = UserOperations().getUser(access_token: ((SessionManager.shared.credentials?.accessToken)!))
            UserOperations().editUser(access_token: (user?.access_token)!, temperature_format: (user?.temperature_format)!, location: self.city as String, username: (user?.username)!)
            self.performSegue(withIdentifier: "FromMapToWeather", sender: nil)
        })
    }

    @IBAction func unzoomButtonClicked(_ sender: UIButton) {
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
        mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func zoomButtonClicked(_ sender: UIButton) {
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapView.setRegion(region, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchBarText = searchBar.text
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            let result : MKMapItem =  response.mapItems[0]
            let region = MKCoordinateRegion(center: result.placemark.coordinate,  span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            self.mapView.setRegion(region, animated: true)
            self.annotation.coordinate = CLLocationCoordinate2DMake(region.center.latitude, region.center.longitude);
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.center = view.center
        mapView.isUserInteractionEnabled = false;
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        determineCurrentLocation()
    }
    
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)
        annotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
            mapView.addAnnotation(annotation)
    }
}
