//
//  NotificationManager.swift
//  Tracking
//
//  Created by Manish on 23/04/22.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject{
    
    static let shared : NotificationManager = {
        let instance = NotificationManager()
        return instance
    }()
    
    
    func requestNotificationAuthorization(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            else{
                print(success)
            }
        }
    }
    
    
    func sendNotification(){
        let content = UNMutableNotificationContent()
        content.title = AppConstants.appName
        content.subtitle = "Targate done!!!"
        content.body = "Hurrey!!!, You completed 50 meter ride...."
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,repeats: false)
        let request = UNNotificationRequest(identifier: "Notification_\(Date().timeIntervalSince1970)",content: content,trigger: trigger)
        UNUserNotificationCenter.current().delegate = self
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
}

extension NotificationManager: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14, *) {
            completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            NotificationCenter.default.post(name: .kRedirectToTab3, object: nil)
        }
        
        completionHandler()
    }
    
}
