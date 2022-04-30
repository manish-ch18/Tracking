//
//  Extensions.swift
//  Tracking
//
//  Created by Manish on 23/04/22.
//

import Foundation
import UIKit
import CoreLocation

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

extension CLLocationManager{
    class func authorization() -> CLAuthorizationStatus{
        
        if #available(iOS 14, *) {
            return CLLocationManager().authorizationStatus
        } else {
            return self.authorizationStatus()
        }

        
    }
}


extension Date{
    func stringFromDateForDB() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strDate = dateFormatter.string(from: self)
        return strDate
    }
    
    func stringFromDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let strDate = dateFormatter.string(from: self)
        return strDate
    }
}

extension String{
    func dateFromString() -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)
        return date
    }
}


extension Notification.Name {
    static let kRedirectToTab3 = Notification.Name("RedirectToTab3")
}
