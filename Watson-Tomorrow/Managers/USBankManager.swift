//
//  USBankManager.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 8/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation
import Alamofire

class USBankManager {
    static let instance = USBankManager()
    var merchantCodes: [MerchantCode] = []
    var bankAccounts: [BankAccount] = []
    var transactions: [Transaction] = []
    
    private init () {
    }
    
    func initializeData() {
        loadMccCodes()
        loadUserData(id: Constants.Bank.testUserIds.first!)
    }
    
    func loadMccCodes() {
        DataManager.instance.getMccJsonFromURL(Constants.MccCodeFileName) { (merchantCodes, error) in
            if error != nil {
                NSLog(error.debugDescription)
                return
            }
            if let mcc = merchantCodes {
                self.merchantCodes = mcc
            }
        }
    }
    
    func loadUserData(id: String) {
        let parameters: Parameters = ["LegalParticipantIdentifier": id]
        NSLog("Requesting user accounts")
        Alamofire.request(Constants.Bank.userAccountsEndpoint,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: Constants.Bank.requestHeaders).validate().responseJSON { response in
            switch response.result {
            case .success:
                guard let value = response.result.value as? [String: Any],
                    let accounts = value["AccessibleAccountDetailList"] as? [[String: Any]] else {
                        return
                }
                accounts.forEach({ (accountDict) in
                    let companyId = accountDict["OperatingCompanyIdentifier"] as! String
                    let productCode = accountDict["ProductCode"] as! String
                    let primaryId = accountDict["PrimaryIdentifier"] as! String
                    let bankAccount = BankAccount(companyId: companyId, productCode: productCode, primaryId: primaryId)
                    if bankAccount.productCode !=  "CCD" {
                        return
                    }
                    self.bankAccounts.append(bankAccount)
                })
                guard self.bankAccounts.count > 0 else {
                    print("No credit card accounts detected")
                    return
                }
                print("Loaded User accounts Successful")
                self.loadTransactions(account: self.bankAccounts.first!)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func loadTransactions(account: BankAccount) {
        Alamofire.request(Constants.Bank.transactionEndpoint,
                          method: .post,
                          parameters: account.params,
                          encoding: JSONEncoding.default,
                          headers: Constants.Bank.requestHeaders).validate().responseJSON { response in
            switch response.result {
            case .success:
                guard let value = response.result.value as? [String: Any],
                    let transactionsResponses = value["MonetaryTransactionResponseList"] as? [[String: String]] else {
                        return
                }
                transactionsResponses.forEach {transactionDict in
                    guard let transaction = Transaction(dict: transactionDict) else {
                        print("Invalid dictionary", transactionDict)
                        return
                    }
                    self.transactions.append(transaction)
                }
                print(self.transactions)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    
}
