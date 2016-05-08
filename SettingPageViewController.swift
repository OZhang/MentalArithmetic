//
//  SettingPageViewController.swift
//  MentalArithmetic
//
//  Created by 张润泽 on 16/4/16.
//  Copyright © 2016年 张润泽. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class SettingPageViewController: UITableViewController, UITextFieldDelegate {

    var settings: NSDictionary?
    var settingInfo: SettingInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = loadFromPlist()
        self.settingInfo = loadSettingInfo(path!)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "settingCell")
    }
    
    func loadFromPlist() -> NSURL?{
        // getting path to settingInfo.plist
        let file = "settingInfo.plist"
        let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first
        let url = NSURL(fileURLWithPath: dir!).URLByAppendingPathComponent(file)
        let plistPath = NSBundle.mainBundle().URLForResource("settingInfo", withExtension: "plist")
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(url.absoluteString)) {
            do {
                try  fileManager.copyItemAtURL(plistPath!, toURL: url)
            }
            catch{}
        }
        return url
    }
    
    func saveSettingInfo() {
        let file = "settingInfo.plist"
        let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first
        let url = NSURL(fileURLWithPath: dir!).URLByAppendingPathComponent(file)
        let settingInfo = NSMutableDictionary()
        for index in 0...3 {
            let infos = self.settingInfo?.dataCollection(index)
            let data = NSMutableArray()
            for info in infos! {
                let i = NSMutableDictionary()
                i.setValue(info.name, forKeyPath: "value")
                i.setValue(info.title, forKeyPath: "title")
                i.setValue(info.checked, forKeyPath: "checked")
                data.addObject(i)
            }
            let key = index == 0 ? "types" : index == 1 ? "diffculty" : index == 2 ? "amount" : "time"
            settingInfo.setValue(data, forKeyPath: key)
        }
        settingInfo.writeToURL(url, atomically: false)
    }
    
 //   @IBAction func GenerateQuesetions(sender: AnyObject) {
 //       self.performSegueWithIdentifier("getQusetions", sender: self)
 //   }
    
    func loadSettingInfo(plistPath: NSURL) -> SettingInfo{
        let settingInfo = SettingInfo()
        self.settings = NSMutableDictionary(contentsOfURL: plistPath)
        settingInfo.types = initSettingInfo(self.settings!["types"] as! NSMutableArray)
        settingInfo.diffculty = initSettingInfo(self.settings!["diffculty"] as! NSMutableArray)
        settingInfo.amount = initSettingInfo(self.settings!["amount"] as! NSMutableArray)
        settingInfo.time = initSettingInfo(self.settings!["time"] as! NSMutableArray)
        return settingInfo
    }
    
    func initSettingInfo(source: NSArray) -> [Info]{
        var infos = [Info]()
        for data in source {
            let dictionary = data as! NSMutableDictionary
            let title = dictionary["title"] as! String
            let checked = dictionary["checked"] as! Bool
            let name = dictionary["value"] as! String
            let info: Info = Info(name: name, title: title, checked: checked)
            infos.append(info)
        }
        return infos
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func initTypes(types: [Info]) {
        var typeNames = String()
        for type in types {
            if (type.checked){
                typeNames = typeNames.stringByAppendingString(type.title).stringByAppendingString("  ")
            }
        }
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))! as UITableViewCell
        cell.textLabel?.text = typeNames
        settingInfo!.types = types
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? OperationViewController{
            viewController.sendData((self.settingInfo?.types)!)
            viewController.onDataAvailable = {[weak self](data) in
                if let weakself = self {
                    weakself.initTypes(data)
                }
            }
        }
        else if let viewController = segue.destinationViewController as? QuestionViewController{
            
            for section in 1...3 {
                let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: section))! as UITableViewCell
                let count = ((self.settingInfo?.dataCollection(section))! as [Info]).count
                var infos = self.settingInfo?.dataCollection(section)
                for index in 1...count {
                    infos![index-1].checked = cell.textLabel?.text == infos![index-1].title
                }
                switch section {
                case 1:
                    self.settingInfo?.diffculty = infos
                case 2:
                    self.settingInfo?.amount = infos
                case 3:
                    self.settingInfo?.time = infos
                default:
                    continue
                }
            }
            saveSettingInfo()
            viewController.sendData(self.settingInfo!)
        }
    }
 
    //func setAlert(title: String, message: String, actions: [String], cell: UITableViewCell?) -> UIAlertController{
    func setAlert(title: String, message: String, actions: [Info], section: Int) -> UIAlertController{
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: section))
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        for info in actions {
            let action = UIAlertAction(title: info.title, style: .Default){
                (action) -> Void in
                    cell?.textLabel?.text = info.title
            }
            alertController.addAction(action)
        }
        
        let cancelAlert = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alertController.addAction(cancelAlert)
        alertController.popoverPresentationController?.sourceRect = CGRect(x: (self.view.frame.width/2), y: self.view.frame.height, width: 0, height: 0)
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Down
        return alertController

    }
    
    func accessoryButtonTapped(sender : AnyObject){
        print(sender.tag)
        print("Tapped")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("settingCell", forIndexPath: indexPath) as UITableViewCell

        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = ""
            cell.accessoryType = .DisclosureIndicator
            cell.selectionStyle = .Default
            for info in (self.settingInfo?.types)! {
                if (info.checked){
                    cell.textLabel?.text = cell.textLabel?.text?.stringByAppendingString(info.title).stringByAppendingString("  ")
                }
            }
        case 1:
            for info in (self.settingInfo?.diffculty)! {
                if (info.checked){
                cell.textLabel?.text = info.title
                }
            }
        case 2:
            for info in (self.settingInfo?.amount)! {
                if (info.checked){
                    cell.textLabel?.text = info.title
                }            }
        case 3:
            for info in (self.settingInfo?.time)! {
                if (info.checked){
                    cell.textLabel?.text = info.title
                }            }
        default:
            return cell
        }
        cell.textLabel?.textColor = UIColor(colorLiteralRed: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        cell.textLabel?.textAlignment = .Left
        return cell
    }
  
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let header = self.tableView.headerViewForSection(indexPath.section)?.textLabel?.text
    var alert:UIAlertController
        switch indexPath.section {
        case 0:
            self.performSegueWithIdentifier("showOperation", sender: self)
            return
        case 1:
            let message = "乘法和除法保持在九九乘法表范围内"
            alert = setAlert(header!, message: message, actions: (self.settingInfo?.diffculty)!,
                             section: indexPath.section)
        case 2:
            let message = "生成口算题目的数量"
            alert = setAlert(header!, message: message, actions: (self.settingInfo?.amount)!,
                             section: indexPath.section)
        case 3:
            let message = "所选时间会被用作口算计时"
            alert = setAlert(header!, message: message, actions: (self.settingInfo?.time)!,
                             section: indexPath.section)
        default:
            return
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
}