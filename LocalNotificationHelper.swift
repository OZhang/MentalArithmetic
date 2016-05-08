//
//  LocalNotificationHelper.swift
//  MentalArithmetic
//
//  Created by 张润泽 on 16/5/7.
//  Copyright © 2016年 张润泽. All rights reserved.
//

import Foundation
import AVKit

class LocalNotificationHelper: NSObject {
    
    let LOCAL_NOTIFICATION_CATEGORY : String = "小天口算Category"
    
    // MARK: - Shared Instance
    class func sharedInstance() -> LocalNotificationHelper {
        struct Singleton {
            static var sharedInstance = LocalNotificationHelper()
        }
        return Singleton.sharedInstance
    }
    
    func createUserNotificationActionButton(identifier identifier: String, title: String) -> UIUserNotificationAction{
        let actionButton = UIMutableUserNotificationAction()
        actionButton.identifier = identifier
        actionButton.title = title
        actionButton.activationMode = .Background
        actionButton.authenticationRequired = true
        actionButton.destructive = false
        return actionButton
    }
    
    // MARK: - Schedule Notification
    
    func scheduleNotificationWithKey(key: String, title: String, message: String, seconds: Double, userInfo: [NSObject: AnyObject]?) {
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(seconds))
        let notification = notificationWithTitle(key, title: title, message: message, date: date, userInfo: userInfo, soundName: nil, hasAction: true)
        notification.category = LOCAL_NOTIFICATION_CATEGORY
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func scheduleNotificationWithKey(key: String, title: String, message: String, date: NSDate, userInfo: [NSObject: AnyObject]?){
        let notification = notificationWithTitle(key, title: title, message: message, date: date, userInfo: ["key": key], soundName: nil, hasAction: true)
        notification.category = LOCAL_NOTIFICATION_CATEGORY
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func scheduleNotificationWithKey(key: String, title: String, message: String, seconds: Double, soundName: String, userInfo: [NSObject: AnyObject]?){
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(seconds))
        let notification = notificationWithTitle(key, title: title, message: message, date: date, userInfo: ["key": key], soundName: soundName, hasAction: true)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func scheduleNotificationWithKey(key: String, title: String, message: String, date: NSDate, soundName: String, userInfo: [NSObject: AnyObject]?){
        let notification = notificationWithTitle(key, title: title, message: message, date: date, userInfo: ["key": key], soundName: soundName, hasAction: true)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    // MARK: - Present Notification
    
    func presentNotificationWithKey(key: String, title: String, message: String, soundName: String, userInfo: [NSObject: AnyObject]?) {
        let notification = notificationWithTitle(key, title: title, message: message, date: nil, userInfo: ["key": key], soundName: nil, hasAction: true)
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    // MARK: - Create Notification
    
    func notificationWithTitle(key : String, title: String, message: String, date: NSDate?, userInfo: [NSObject: AnyObject]?, soundName: String?, hasAction: Bool) -> UILocalNotification {
        
        var dct : Dictionary<String,AnyObject> = userInfo as! Dictionary<String,AnyObject>
        dct["key"] = NSString(string: key) as String
        
        let notification = UILocalNotification()
        notification.alertAction = title
        notification.alertBody = message
        notification.userInfo = dct
        notification.soundName = soundName ?? UILocalNotificationDefaultSoundName
        notification.fireDate = date
        notification.hasAction = hasAction
        return notification
    }
    
    func getNotificationWithKey(key : String) -> UILocalNotification {
        
        var notif : UILocalNotification?
        
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! where notification.userInfo!["key"] as! String == key{
            notif = notification
            break
        }
        
        return notif!
    }
    
    func cancelNotification(key : String){
        
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! where notification.userInfo!["key"] as! String == key{
            UIApplication.sharedApplication().cancelLocalNotification(notification)
            break
        }
    }
    
    func getAllNotifications() -> [UILocalNotification]? {
        return UIApplication.sharedApplication().scheduledLocalNotifications
    }
    
    func cancelAllNotifications() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    func registerUserNotificationWithActionButtons(actions actions : [UIUserNotificationAction]){
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = LOCAL_NOTIFICATION_CATEGORY
        
        category.setActions(actions, forContext: UIUserNotificationActionContext.Default)
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: NSSet(object: category) as? Set<UIUserNotificationCategory>)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func registerUserNotification(){
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
   
    
}