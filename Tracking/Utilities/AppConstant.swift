//
//  AppConstant.swift
//  Tracking
//
//  Created by Manish on 23/04/22.
//

import Foundation
import UIKit

struct AppConstants{
    
    static var isStart = false
    static let horizontalAccuracy = 500
    static let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? "Tracking"
    static var startTimr = Date()
    static var endTime = Date()
    static func topViewController(controller: UIViewController? = UIWindow.key?.rootViewController) -> UIViewController? {
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    static func showAlert(title: String, message: String, in vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func getDateDiff(start: Date?, end: Date?) -> String  {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: start ?? Date(), to: end ?? Date())
        let seconds = dateComponents.second ?? 0
        let minutes = seconds / 60;
        let secondsToShow = seconds % 60;
        return String( format: "%02d:%02d", arguments: [minutes, secondsToShow])
    }
    
}
