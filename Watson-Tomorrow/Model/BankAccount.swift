//
//  BankAccount.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 8/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Alamofire

class BankAccount {
    var companyId: String
    var productCode: String
    var primaryId: String
    var accountDetails: [String: Any]
    var accountDict: [String: Any]
    
    var params: Parameters {
        get {
            return [
                "OperatingCompanyIdentifier" : self.companyId,
                "ProductCode" : self.productCode,
                "PrimaryIdentifier" : self.primaryId
            ]
        }
    }
    
    init(accountDict: [String: Any]) {
        let companyId = accountDict["OperatingCompanyIdentifier"] as! String
        let productCode = accountDict["ProductCode"] as! String
        let primaryId = accountDict["PrimaryIdentifier"] as! String
        self.companyId = companyId
        self.productCode = productCode
        self.primaryId = primaryId
        self.accountDetails = accountDict["BasicAccountDetail"] as! [String: Any]
        self.accountDict = accountDict
    }
    
    var isOpen: Bool {
        get {
            if let accountDetailsCodes = self.accountDetails["Codes"] as? [String: Any],
                let status = accountDetailsCodes["StatusDescription"] as? String {
                return status == "OPEN"
            }
            return false
        }
    }
    
    var hashKey: String {
        return "\(self.productCode)_\(self.companyId)"
    }
    
}
