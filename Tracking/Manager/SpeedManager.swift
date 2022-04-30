//
//  SpeedManager.swift
//  Tracking
//
//  Created by Manish on 23/04/22.
//
import Foundation
import CoreLocation
import MapKit

typealias Speed = CLLocationSpeed

@objc protocol SpeedManagerDelegate{
    func speedDidChange(speed: Speed, distance : Double)
}

class SpeedManager: NSObject, CLLocationManagerDelegate{
    
    var delegate: SpeedManagerDelegate?
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var distanceTraveled: Double = 0.0
    var tempDistanceTraveled: Double = 0.0
    var locationsPassed = [CLLocation]()
    var tempLocations = [CLLocation]()
    var startTime = Date()
    var stopTime = Date()
    private let locationManager: CLLocationManager?
    static let shared : SpeedManager = {
        let instance = SpeedManager()
        return instance
    }()
    
    override init() {
        locationManager = CLLocationManager.locationServicesEnabled() ? CLLocationManager() : nil
        
        super.init()
        
        if let locationManager = self.locationManager {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            
            if CLLocationManager.authorization() == CLAuthorizationStatus.notDetermined {
                locationManager.requestAlwaysAuthorization()
            } else if CLLocationManager.authorization() == .authorizedAlways || CLLocationManager.authorization() == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.showsBackgroundLocationIndicator = true
            }else if CLLocationManager.authorization() == .denied{
                redirectToSetting()
            }
            
        }
    }
    
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if CLLocationManager.authorization() == .authorizedAlways || CLLocationManager.authorization() == .authorizedWhenInUse{
            locationManager?.startUpdatingLocation()
            locationManager?.startUpdatingHeading()
        }else if CLLocationManager.authorization() == .denied{
            redirectToSetting()
        }
    }
    
    func addLocationsToArray(_ locations: [CLLocation]) {
        for location in locations {
            if !locationsPassed.contains(location) {
                locationsPassed.append(location)
            }
        }
        var totalDistance = 0.0
        if locationsPassed.count > 0{
            for i in 1..<locationsPassed.count {
                let previousLocation = locationsPassed[i-1]
                let currentLocation = locationsPassed[i]
                totalDistance += currentLocation.distance(from: previousLocation)
            }
            distanceTraveled = totalDistance
            print(distanceTraveled)
        }
    }
    
    func getNotifLocation(locations: [CLLocation]) -> Double{
        for location in locations {
            if !tempLocations.contains(location) {
                tempLocations.append(location)
            }
        }
        var tempTotalDistance = 0.0
        if tempLocations.count > 0{
            for i in 1..<tempLocations.count {
                let previousLocation = tempLocations[i-1]
                let currentLocation = tempLocations[i]
                tempTotalDistance += currentLocation.distance(from: previousLocation)
            }
        }
        return tempTotalDistance
    }
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if AppConstants.isStart{
            addLocationsToArray(locations)
//            tempDistanceTraveled = getNotifLocation(locations: locations)
            
            if let lastLocation = lastLocation{
                if let newlastLocation = locations.last{
                    tempDistanceTraveled += newlastLocation.distance(from: lastLocation)
                }
            }
            lastLocation = locations.last
            
            if tempDistanceTraveled >= 50.0{
                stopTime = Date()
                let data = getModel(startTime: startTime.stringFromDateForDB(), stopTime: stopTime.stringFromDateForDB(), distance: tempDistanceTraveled)
                let isSave = DatabaseManager.shared.insertData(data)
                print(isSave)
                tempDistanceTraveled = 0.0
                tempLocations.removeAll()
                startTime = Date()
                NotificationManager.shared.sendNotification()
            }
        }
        
        
        if locations.count > 0 {
            if let lastLocation = locations.last{
                if Int(lastLocation.horizontalAccuracy) <= AppConstants.horizontalAccuracy{
                    let mps = max(locations[locations.count - 1].speed, 0)
                    delegate?.speedDidChange(speed: mps, distance: distanceTraveled)
                }
                
            }
        }
    }
    
    func redirectToSetting(){
        let alert = UIAlertController(title: "\(AppConstants.appName)", message: "You denied location services please enable it from Setting -> Location Services -> \(AppConstants.appName).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes I'll", style: .default, handler: { (_) in
            let url = URL(string: "app-settings:root=LOCATION_SERVICES")
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
        if let topController = AppConstants.topViewController(){
            topController.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func getModel(startTime: String, stopTime: String, distance: Double) -> TrackingModel{
        var trackingModel = TrackingModel()
        trackingModel.distance = String(format:"%.2f", distance)
        trackingModel.startTime = startTime
        trackingModel.stopTime = stopTime
        return trackingModel
    }
    
    fileprivate func checkLocationTypeForNotification() {
        if CLLocationManager.authorization() == .authorizedWhenInUse{
            if let topViewController = AppConstants.topViewController(){
                AppConstants.showAlert(title: AppConstants.appName, message: "50 M Completed notification will not get in Location when in use privacy setting. \n\n Please Allow always use location for get notification from settings.", in: topViewController)
            }
            
        }
    }
    
}
