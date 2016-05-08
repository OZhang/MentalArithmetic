    //
//  ViewController.swift
//  MentalArithmetic
//
//  Created by 张润泽 on 16/4/9.
//  Copyright © 2016年 张润泽. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class QuestionViewController: UITableViewController {
    
    var settingInfo: SettingInfo?
    var onDataAvailable : ((data: [Info]) -> ())?
    var questions: [QuestionHelper.question]?
    var helper: QuestionHelper?
    var hideAnswer = true
    @IBOutlet weak var subjects: UITextField!
    var list : NSMutableDictionary = NSMutableDictionary()
    var elements : NSArray = NSArray()
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    var calendarItemIdentifier: String?
    @IBAction func subjectClick(sender: AnyObject) {}
    
    @IBAction func startTimer(sender: AnyObject) {
        let button = sender as! UIBarButtonItem
        if (button.title == "开始计时"){
            let countDownMins = self.helper?.countdownTime
            let realTime = NSDate().dateByAddingTimeInterval(countDownMins! * 60)
            createReminder(realTime, button: button)
        }
        else{
            Reminder.Instance.removeExpiredReminders(calendarItemIdentifier!)
            button.title = "开始计时"
        }
    }
    
    @IBAction func showAnswers(sender: AnyObject) {
        self.hideAnswer = !self.hideAnswer
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    func sendData(data: SettingInfo) {
        self.settingInfo = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.helper = QuestionHelper()
        if (Reminder.Instance.loadIdentifier()){
            if (Reminder.Instance.calendarItemIdentifier != nil){
                Reminder.Instance.removeExpiredReminders(Reminder.Instance.calendarItemIdentifier!)
            }
        }
        self.helper!.settingInfo = self.settingInfo!
        self.questions = self.helper!.generateNewQuestions()
        self.refreshControl?.addTarget(self, action: #selector(QuestionViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func refresh(sender: AnyObject){
        self.questions = self.helper!.generateNewQuestions()
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        self.refreshControl?.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CellIdentifier"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as! QuestionCell
        cell.number!.text = "(\(indexPath.row + 1))"
        cell.number!.textAlignment = .Right
        cell.question!.text = self.questions![indexPath.row].question
        cell.question!.textAlignment = .Left
        cell.result!.text = self.questions![indexPath.row].result
        cell.result!.textAlignment = .Left
        cell.result!.hidden = self.hideAnswer
        cell.accessoryType = UITableViewCellAccessoryType.None
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let change = UITableViewRowAction(style: .Normal, title: "换") { (action, indexPath) in
            let oldQuestion = self.questions![indexPath.row].question
            repeat{
                let random = arc4random_uniform(5)
                switch random {
                case 1:
                    if (self.settingInfo?.types![0] != nil &&
                        (self.settingInfo?.types![0].checked)!){
                        self.questions![indexPath.row] = self.helper!.addition()
                    }
                case 2:
                    if (self.settingInfo?.types![1] != nil &&
                        (self.settingInfo?.types![1].checked)!){
                        self.questions![indexPath.row] = self.helper!.subtraction()
                    }
                case 3:
                    if (self.settingInfo?.types![2] != nil &&
                        (self.settingInfo?.types![2].checked)!){
                        self.questions![indexPath.row] = self.helper!.multiplication()
                    }
                case 4:
                    if (self.settingInfo?.types![3] != nil &&
                        (self.settingInfo?.types![3].checked)!){
                        self.questions![indexPath.row] = self.helper!.division()
                    }
                case 5:
                    if (self.settingInfo?.types![4] != nil &&
                        (self.settingInfo?.types![4].checked)!){
                        self.questions![indexPath.row] = self.helper!.divisionWithRemainder()
                    }
                default:
                    break
                }
            }while(self.questions![indexPath.row].question == oldQuestion)
            
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        change.backgroundColor = UIColor.redColor()
        return [change]
    }
    
    func createReminder(timeInterval: NSDate, button: UIBarButtonItem){
        if (self.calendarItemIdentifier != nil){
            Reminder.Instance.removeExpiredReminders(self.calendarItemIdentifier!)
        }
        let calendarDatabase = EKEventStore()
        calendarDatabase.requestAccessToEntityType(.Reminder) { (value, error) in
            if (value){
                let calendarItemIdentifier = Reminder.Instance.createReminder(calendarDatabase, timeInterval: timeInterval)
                if (calendarItemIdentifier != ""){
                    self.calendarItemIdentifier = calendarItemIdentifier
                    dispatch_async(dispatch_get_main_queue(), {
                        button.title = "结束"
                    })
                }
            }
            else{
                
                let alertController = UIAlertController(title: "不被允许访问提醒事项", message: "为了给您提供计时功能，请授权访问您的提醒事项", preferredStyle: .Alert)
                let action = UIAlertAction(title: "去授权", style: .Default){
                    (action) in
                    if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                alertController.addAction(action)
                let cancelAlert = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alertController.addAction(cancelAlert)
                alertController.popoverPresentationController?.sourceRect = CGRect(x: (self.view.frame.width/2), y: self.view.frame.height, width: 0, height: 0)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



