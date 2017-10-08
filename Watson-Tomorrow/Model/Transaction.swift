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
    var description: String
    var category: String
    var date: Date
    
    init?(dict: [String: String]) {
        self.amount = Double(dict["PostedAmount"]!)!
        self.description = dict["TransactionDescription"]!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.date = dateFormatter.date(from: dict["PostedDate"]!)!
        var mcc = dict["StandardIndustryCode"]!
        mcc.remove(at: mcc.startIndex)
        self.category = mcc
    }
}
