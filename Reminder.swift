//
//  Reminder.swift
//  MentalArithmetic
//
//  Created by 张润泽 on 16/4/30.
//  Copyright © 2016年 张润泽. All rights reserved.
//
import EventKit
import UIKit
import Foundation

class Reminder{
    let title = "口算时间到！"
    var calendarItemIdentifier: String?
    class var Instance: Reminder {
        dispatch_once(&Inner.token) {
            Inner.instance = Reminder()
        }
        return Inner.instance!
    }
    struct Inner {
        static var instance: Reminder?
        static var token: dispatch_once_t = 0
    }
    
    func createReminder(calendarDatabase: EKEventStore, timeInterval: NSDate) -> String{
        let reminder = EKReminder(eventStore: calendarDatabase)
        reminder.title = title
        let alarm = EKAlarm(absoluteDate: timeInterval)
        reminder.addAlarm(alarm)
        reminder.calendar = calendarDatabase.defaultCalendarForNewReminders()
        self.calendarItemIdentifier = reminder.calendarItemIdentifier
        do{
            try calendarDatabase.saveReminder(reminder, commit: true)
            Reminder.Instance.saveIdentifier()
        }
        catch{
            return ""
        }
        return self.calendarItemIdentifier!
    }
    
    func removeExpiredReminders(calendarItemIdentifier: String) {
        let eventStore = EKEventStore()
        let predicate = eventStore.predicateForRemindersInCalendars([])
        eventStore.fetchRemindersMatchingPredicate(predicate) { reminders in
            for reminder in reminders! {
                if (reminder.title == "口算时间到！" && reminder.calendarItemIdentifier == calendarItemIdentifier){
                    do{
                        try eventStore.removeReminder(reminder, commit: true)
                    }
                    catch{
                        NSLog("removeExpiredReminders")
                    }
                }
            }
        }
    }
    
    func loadIdentifier() -> Bool{
        let file = "reminder.plist"
        let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first
        let url = NSURL(fileURLWithPath: dir!).URLByAppendingPathComponent(file)
        let dict = NSMutableDictionary(contentsOfURL: url)
        if (dict != nil){
            self.calendarItemIdentifier = dict!["calendarItemIdentifier"] as? String
        }
        return true
    }
    
    func saveIdentifier() -> Bool {
        if (self.calendarItemIdentifier == nil){
            return false
        }
        
        let file = "reminder.plist"
        let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first
        let url = NSURL(fileURLWithPath: dir!).URLByAppendingPathComponent(file)
        let dict = NSMutableDictionary()
        dict.setValue(self.calendarItemIdentifier!, forKeyPath: "calendarItemIdentifier")
        let result = dict.writeToURL(url, atomically: false)
        return result
    }
}