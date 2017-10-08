//
//  DataManager.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 8/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation

// Helps load and analyzes data, does not store data, but uses USBankManager as a store.
// For Storage, look at USBankManager, which has adhoc interfaces with bank account data.
class DataManager {
    static let instance = DataManager()
    
    func getMccJsonFromURL(_ resource:String, completion: @escaping (_ data: [MerchantCode]?, _ error: Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let filePath = Bundle.main.path(forResource: resource, ofType: "json")
            let url = URL(fileURLWithPath: filePath!)
            let data = try! Data(contentsOf: url, options: .uncached)
            let decoder = JSONDecoder()
            do {
                let merchantCodes = try decoder.decode([MerchantCode].self, from: data)
                completion(merchantCodes, nil)
            } catch  {
                NSLog("failed to convert data to json")
            }
        }
    }
    
    // MARK: - Analytics
    func getDateFromTextRange(_ text: String="day") -> Date {
        var interval: Calendar.Component = .day
        switch text {
        case "year": interval = .year
        case "week": interval = .weekOfYear
        case "month": interval = .month
        case "day": interval = .day
        default: break
        }

        return Calendar.current.date(byAdding: interval, value: -1, to: Date())!
    }
    
    func getAnalyticsForSavings(fromApi: String, completion: @escaping (([String]) -> Void)) {
        let context = WatsonManager.instance.convoContext!
        let apiType = context.json["FromType"] as! String
        var dateFrom = getDateFromTextRange()
        switch apiType {
        case "FromTimeRange":
            guard let timeRangeText = context.json[apiType] as? String else {return}
            dateFrom = getDateFromTextRange(timeRangeText)
        case "FromDate":
            guard let dateString = context.json[apiType] as? String else {return}
            dateFrom = Constants.Bank.dateFormatter.date(from: dateString)!
        default: break
        }
        
        var advice: [String] = []
        switch fromApi {
        case "savings":
            advice = getSavingsAnalysisFrom(date: dateFrom)
            completion(advice)
        case "spendings":
            advice = getSpendingAnalysisFrom(date: dateFrom)
            completion(advice)
        default: break
        }
    }
    
    func getLatestBalance() -> Double {
        if let latestTransaction = USBankManager.instance.transactions["DDA"]?.first as? TransactionDDA {
            return latestTransaction.balanceLeft
        }
        return 0
    }
    
    func getSavingsAnalysisFrom(date: Date) -> [String] {
        let transactions = USBankManager.instance.transactions["DDA"]!
            .filter({$0.date > date})
            .map {$0 as! TransactionDDA}
        
        return getInsightsFromSavings(transactions, fromDate: date)
    }
    
    
    func getSpendingAnalysisFrom(date: Date) -> [String] {
        let transactions = USBankManager.instance.transactions["CCD"]!
            .filter({$0.date > date})
            .map {$0 as! TransactionCCD}
        
        return getInsightsFromSpending(transactions, fromDate: date)
    }
    
    func getInsightsFromSavings(_ transactions: [TransactionDDA], fromDate: Date) -> [String] {
        var advice: [String] = []
        var timesWithdrawn = 0.0
        var timesDeposited = 0.0
        
        var totalWithdrawal = 0.0
        var totalDeposit = 0.0
        
        transactions.forEach { transaction in
            if transaction.takeInOrOut == "DEPOSIT" {
                totalDeposit += transaction.amount
                timesDeposited += 1
            } else {
                totalWithdrawal += transaction.amount
                timesWithdrawn += 1
            }
        }
        
        let savingsChange = totalDeposit - totalWithdrawal
        advice.append("Your savings changed: $\((savingsChange).formatSign()) since \(fromDate.getString()).")
        let haveEnough = getLatestBalance() > Constants.Bank.emergencyMin
        if savingsChange < 0, !haveEnough {
            advice.append("You need to save more!")
            advice.append("You should more than 3 months of living expenses in case of emergencies.")
        } else if savingsChange < 0 {
            advice.append("Your have enough savings for most emergencies but do try to save more.")
        } else if !haveEnough {
            advice.append("You still lack the minimum of $\(Constants.Bank.emergencyMin) for an emergency, but keep it up!")
        } else {
            advice.append("Great!")
        }
        return advice
    }
    
    func getInsightsFromSpending(_ transactions: [TransactionCCD], fromDate: Date) -> [String] {
        var advice: [String] = []
        var mostSpentOnCategory: [String: Double] = [:]
        
        transactions.forEach { transaction in
            let cat = USBankManager.instance.merchantCodes[transaction.categoryCode]!.irs_description
            if mostSpentOnCategory[cat] == nil {
                mostSpentOnCategory[cat] = transaction.amount
            } else {
                mostSpentOnCategory[cat]! += transaction.amount
            }
        }
        
        var biggestSpendingCat = ""
        var biggestSpent = 0.0
        mostSpentOnCategory.forEach { cat in
            if cat.value > biggestSpent {
                biggestSpent = cat.value
                biggestSpendingCat = cat.key
            }
        }
        let haveEnough = getLatestBalance() > Constants.Bank.emergencyMin
        if !haveEnough {
            advice.append("Your spending is reducing the emergency fund!")
            advice.append("Cut down on your spending on \(biggestSpendingCat), it was the largest around $\(biggestSpent) since \(fromDate.getString())")
        } else {
            advice.append("Watch how you spend on \(biggestSpendingCat), you spent $\(biggestSpent) since \(fromDate.getString())")
        }
        return advice
    }
    
    

}
