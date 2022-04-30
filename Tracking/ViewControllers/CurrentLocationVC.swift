//
//  CurrentLocationVC.swift
//  Tracking
//
//  Created by Manish on 23/04/22.
//

import UIKit
import CoreLocation
import MapKit

class CurrentLocationVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var lastCoordinet: MKCoordinateRegion?
    var locationManager: CLLocationManager!
    var startStopTrackingButton = UIBarButtonItem()
    var strStartTracking = "Start Tracking"
    var strStopTracking = "Stop Tracking"
    let geocoder = CLGeocoder()
    var annotation: MKAnnotation?
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.register(SnapshotAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        startStopTrackingButton = UIBarButtonItem(title: strStartTracking, style: .plain, target: self, action: #selector(startStopTrackingTapped(_:)))
        self.navigationItem.setRightBarButton(startStopTrackingButton, animated: true)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SpeedManager.shared.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        setupLocationManager()
        NotificationManager.shared.requestNotificationAuthorization()
    }
    
    @objc func startStopTrackingTapped(_ sender: UIBarButtonItem){
        AppConstants.isStart.toggle()
        
        sender.title = AppConstants.isStart ? strStopTracking : strStartTracking
        
        if AppConstants.isStart{
            SpeedManager.shared.startTime = Date()
        }else{
            SpeedManager.shared.distanceTraveled = 0.0
            SpeedManager.shared.locationsPassed.removeAll()
        }
        
    }
    
    func setupLocationManager(){
        if (CLLocationManager.locationServicesEnabled())
        {
            self.mapView.showsUserLocation = true
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.mapView.isZoomEnabled = true
            self.locationManager.headingFilter = 10
            self.locationManager.startUpdatingLocation()
            if let coordinate = self.lastCoordinet{
                mapView.setRegion(coordinate, animated: true)
            }
        }else{
            AppConstants.showAlert(title: AppConstants.appName, message: "Please enable location services from setings.", in: self)
        }
    }
    

}


extension CurrentLocationVC : CLLocationManagerDelegate, MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            
            let searchRadius: CLLocationDistance = 500
            
            let coordinateRegion = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            lastCoordinet = coordinateRegion
            if let locManager = locationManager {
                locManager.startUpdatingLocation()
            }
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        print("Heading")
        if let loc = manager.location{
            mapView.camera.heading = newHeading.magneticHeading
            mapView.camera.altitude = 700
            mapView.camera.pitch = 45
            mapView.setCamera(mapView.camera, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last{
            
            let noLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let viewRegion = MKCoordinateRegion(center: noLocation, latitudinalMeters: 200, longitudinalMeters: 200)
                mapView.setRegion(viewRegion, animated: false)
            addAnnotation(for: mapView.centerCoordinate)
//                mapView.showsUserLocation = true
        }
        
    
    }
    
    
    func addAnnotation(for coordinate: CLLocationCoordinate2D) {
        if !AppConstants.isStart{
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                if let placemark = placemarks?.first {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = placemark.name ?? ""
                    annotation.subtitle = placemark.locality ?? ""
                    self.annotation = annotation
                    self.title = "\(placemark.name ?? "") \(placemark.locality ?? "")"
                    self.mapView.addAnnotation(annotation)
                }
            }
        }else{
            guard let annotation = self.annotation else{
                return
            }
            mapView.removeAnnotation(annotation)
        }
        
    }
    
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let calloutView = SnapshotAnnotationView(annotation: mapView.annotations.last!, reuseIdentifier: "callOut")
        calloutView.translatesAutoresizingMaskIntoConstraints = false
        calloutView.backgroundColor = UIColor.lightGray
        view.addSubview(calloutView)
//        calloutView.annotation?.title = "Hello"

        NSLayoutConstraint.activate([
            calloutView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            calloutView.widthAnchor.constraint(equalToConstant: 60),
            calloutView.heightAnchor.constraint(equalToConstant: 30),
            calloutView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.calloutOffset.x)
        ])
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {

            let pin = mapView.view(for: annotation) as? MKPinAnnotationView ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "callOut")
            return pin
        } else {
            
        }
        return nil
    }
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = Double("\(pdblLatitude)")!
            //21.228124
            let lon: Double = Double("\(pdblLongitude)")!
            //72.833770
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)


            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]

                    if pm.count > 0 {
                        let pm = placemarks![0]
                        print(pm.country)
                        print(pm.locality)
                        print(pm.subLocality)
                        print(pm.thoroughfare)
                        print(pm.postalCode)
                        print(pm.subThoroughfare)
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }


                        print(addressString)
                  }
            })

        }

}

extension CurrentLocationVC: SpeedManagerDelegate{
    func speedDidChange(speed: Speed, distance: Double) {
        print("Location")
    }
    
    
}
