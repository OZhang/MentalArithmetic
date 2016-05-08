//
//  OperationViewController.swift
//  MentalArithmetic
//
//  Created by 张润泽 on 16/4/18.
//  Copyright © 2016年 张润泽. All rights reserved.
//

import UIKit

class OperationViewController: UITableViewController {
    
    var elements: [Info]?
    
    var onDataAvailable : ((data: [Info]) -> ())?
    
    func sendData(elements: [Info]) {
        // Whenever you want to send data back to viewController1, check
        // if the closure is implemented and then call it if it is
        self.elements = elements
    }
    
    override func viewDidLoad() {
       tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let info = self.elements![indexPath.row]
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = info.title
        //configure you cell here.
        if !info.checked {
            cell.accessoryType = .None
            
        } else {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                self.elements![indexPath.row].checked = false
                var checkedCount = 0
                for element in self.elements! {
                    if (element.checked){
                        checkedCount += 1
                    }
                }
                if (checkedCount == 0){
                    cell.accessoryType = .Checkmark
                    self.elements![indexPath.row].checked = true
                }
            } else {
                cell.accessoryType = .Checkmark
                self.elements![indexPath.row].checked = true
            }
        }
        
        self.onDataAvailable?(data: self.elements!)
    }
}