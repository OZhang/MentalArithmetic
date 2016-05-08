//
//  SettingInfo.swift
//  MentalArithmetic
//
//  Created by 张润泽 on 16/4/20.
//  Copyright © 2016年 张润泽. All rights reserved.
//

import Foundation

class SettingInfo{
    var types: [Info]?
    var diffculty: [Info]?
    var amount: [Info]?
    var time: [Info]?
    func dataCollection(index: Int) -> [Info]{
        switch index {
        case 0:
            return types!
        case 1:
            return diffculty!
        case 2:
            return amount!
        case 3:
            return time!
        default:
            return [Info]()
        }
    }
}

struct Info{
    var name: String
    var title: String
    var checked: Bool
}