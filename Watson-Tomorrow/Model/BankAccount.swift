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
    
    var params: Parameters {
        get {
            return [
                "OperatingCompanyIdentifier" : self.companyId,
                "ProductCode" : self.productCode,
                "PrimaryIdentifier" : self.primaryId
            ]
        }
    }
    
    init(companyId: String, productCode: String, primaryId: String) {
        self.companyId = companyId
        self.productCode = productCode
        self.primaryId = primaryId
    }
    
    
}
