//
//  Questions.swift
//  MentalArithmetic
//
//  Created by 张润泽 on 16/4/27.
//  Copyright © 2016年 张润泽. All rights reserved.
//

import Foundation

class QuestionHelper{
    var settingInfo: SettingInfo?
    var amount: Int?
    var maxNumber: UInt32?
    var countdownTime: Double?
    //var questions: [question]?

    struct question {
        var question: String?
        var result: String?
    }
    
    func addition() -> question{
        var numberOne: UInt32
        var numberTwo: UInt32
        repeat{
            numberOne = arc4random_uniform(maxNumber!)
            numberTwo = arc4random_uniform(maxNumber!)
        }while ((numberOne + numberTwo > maxNumber) || (numberTwo == 0) || (numberOne == 0))
        
        var result = question()
        result.question = "\(numberOne) + \(numberTwo) = "
        result.result = "\(numberOne + numberTwo)"
        return result
    }
    
    func subtraction() -> question{
        var numberOne: UInt32
        var numberTwo: UInt32
        repeat{
            numberOne = arc4random_uniform(maxNumber! - 10) + 10
            numberTwo = arc4random_uniform(numberOne-1)
        }while (numberOne == 0 || numberTwo == 0 || numberTwo > numberOne)
        var result = question()
        result.question = "\(numberOne) - \(numberTwo) = "
        result.result = "\(numberOne - numberTwo)"
        return result
    }
    
    func multiplication() -> question{
        var numberOne: UInt32
        var numberTwo: UInt32
        repeat{
            numberOne = arc4random_uniform(9)
            numberTwo = arc4random_uniform(9)
        }while (numberOne == 0 || numberTwo == 0 || numberOne * numberTwo < 10)
        var result = question()
        result.question = "\(numberOne) × \(numberTwo) = "
        result.result = "\(numberOne * numberTwo)"
        return result
    }
    
    func division() -> question{
        var numberOne: UInt32
        var numberTwo: UInt32
        let maxOne: UInt32 = (maxNumber! >= 100) ? 89 : maxNumber!
        repeat{
            numberOne = arc4random_uniform(maxOne)
            numberTwo = arc4random_uniform(9)
        }while (numberTwo < 2 || numberOne < 11 || numberOne <= numberTwo || numberOne % numberTwo != 0 || numberOne / numberTwo > 9)
        var result = question()
        result.question = "\(numberOne) ÷ \(numberTwo) = "
        result.result = "\(numberOne / numberTwo)"
        return result
    }
    
    func divisionWithRemainder() -> question{
        var numberOne: UInt32
        var numberTwo: UInt32
        let maxOne: UInt32 = (maxNumber! >= 100) ? 89 : maxNumber!
        repeat{
            numberOne = arc4random_uniform(maxOne)
            numberTwo = arc4random_uniform(9)
        }while (numberTwo < 2 || numberOne < 11 || numberOne <= numberTwo || numberOne % numberTwo == 0 || numberOne % numberTwo > 9 || numberOne / numberTwo > 9)
        var result = question()
        result.question = "\(numberOne) ÷ \(numberTwo) = "
        result.result = "\(numberOne / numberTwo)∙∙∙ \(numberOne % numberTwo)"
        return result
    }
    
    func getAmount() -> Void{
        for elemt in (settingInfo?.amount)! {
            if (elemt.checked){
                self.amount = Int(elemt.name)
            }
        }
    }
    
    func getMaxNumber() -> Void{
        for elemt in (settingInfo?.diffculty)! {
            if (elemt.checked){
                self.maxNumber = UInt32(elemt.name)
            }
        }
    }
    
    func getCountdownTime() -> Void{
        for elemt in (settingInfo?.time)! {
            if (elemt.checked){
                self.countdownTime = Double(elemt.name)
            }
        }
    }
    
    func generateNewQuestions() -> [question]{
        getAmount()
        getMaxNumber()
        getCountdownTime()
        var questions = [question]()
        repeat{
            for type in (self.settingInfo?.types)! {
                if (type.checked){
                    switch type.name {
                    case "addition":
                        questions.append(addition())
                    case "subtraction":
                        questions.append(subtraction())
                    case "multiplication":
                        questions.append(multiplication())
                    case "division":
                        questions.append(division())
                    case "divisionWithRemainder":
                        questions.append(divisionWithRemainder())
                    default:
                        continue
                    }
                }
                if (questions.count == self.amount){
                    return questions
                }
            }
        }while(questions.count < self.amount)
        return questions
    }
}