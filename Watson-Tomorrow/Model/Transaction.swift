//
//  Transaction.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 8/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation

class Transaction {
    var amount: Double
    var date: Date
    
    init?(dict: [String: Any]) {
        self.amount = Double(dict["PostedAmount"] as! String)!
        Constants.Bank.dateFormatter.dateFormat = Constants.Bank.dateFormat
        self.date = Constants.Bank.dateFormatter.date(from: dict["PostedDate"] as! String)!
        
    }
}

class TransactionCCD: Transaction {
    var description: String
    var categoryCode: String

    override init?(dict: [String: Any]) {
        self.description = dict["TransactionDescription"] as! String
        var mcc = dict["StandardIndustryCode"] as! String
        mcc.remove(at: mcc.startIndex)
        self.categoryCode = mcc
        super.init(dict: dict)
    }
}

class TransactionDDA: Transaction {
    var takeInOrOut: String
    var balanceLeft: Double
    
    override init?(dict: [String: Any]) {
        self.takeInOrOut = dict["TransactionLevelCode"] as! String
        self.balanceLeft = Double(dict["AfterPostingCurrentBalanceAmount"] as! String)!
        super.init(dict: dict)
    }

}
