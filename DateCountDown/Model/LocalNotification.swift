//
//  LocalNotification.swift
//  DateCountDown
//
//  Created by sabrina on 2021/2/1.
//

import Cocoa
import UserNotifications

class LocalNotifications : NSObject {
    let notificationCenter:UNUserNotificationCenter
    
    override init() {
        notificationCenter = UNUserNotificationCenter.current()
    }
    
    func register(identifier:String, date:Date, event:String, completed: @escaping ((String) -> Void), failure: @escaping ((Error) -> Void)) {
        let content = UNMutableNotificationContent()
        content.title = "倒數日期已到期！"
        content.body = String(format: "「%@」就是今天拉～～", event)
        
        content.userInfo = ["method": "new"]
        
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "COUNTDOWN_" + identifier
        let testCategory = UNNotificationCategory(identifier:  "COUNTDOWN_" + identifier,
                                                  actions: [],
                                                  intentIdentifiers: [],
                                                  hiddenPreviewsBodyPlaceholder: "",
                                                  options: .customDismissAction)
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "COUNTDOWN_" + identifier + "_REQUEST",
                                            content: content,
                                            trigger: trigger)
        
        // Schedule the request with the system.
        notificationCenter.delegate = self
        notificationCenter.setNotificationCategories([testCategory])
        notificationCenter.add(request) { (error) in
            guard let err = error else { completed("Register Success!!"); return }
            print(err.localizedDescription)
            failure(err)
        }
    }
    
    static func removeAllNotify() {
        let notify = UNUserNotificationCenter.current()
        notify.removeAllDeliveredNotifications()
        notify.removeAllPendingNotificationRequests()
    }
}

extension LocalNotifications : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        switch response.actionIdentifier {
        case "SHOW_ACTION":
            print(userInfo)
        case "CLOSE_ACTION":
            print("Nothing to do")
        default:
            print("Nothing to do")
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
