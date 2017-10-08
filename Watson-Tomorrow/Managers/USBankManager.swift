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
    var merchantCodes: [String: MerchantCode] = [:]     // Key - 4 digit code
    var openBankAccounts: [String: BankAccount] = [:]   // Key - pdtCode
    var transactions: [String: [Transaction]] = [:]     // Key - pdtCode
    
    private init () {
    }
    
    func initializeData() {
        loadMccCodes()
        loadUserData(id: Constants.Bank.testUserIds.first!)
    }
    
    func loadMccCodes() {
        DataManager.instance.getMccJsonFromURL(Constants.MccCodeFileName) { (mccs, error) in
            if error != nil {
                NSLog(error.debugDescription)
                return
            }
            guard let mccs = mccs else {
                return
            }
            mccs.forEach { merchantCode in
                self.merchantCodes[merchantCode.mcc] = merchantCode
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
                accounts.forEach({ accountDict in
                    let bankAccount = BankAccount(accountDict: accountDict)
                    if bankAccount.isOpen {
                        self.openBankAccounts[bankAccount.productCode] = bankAccount
                    }
                })
                guard self.openBankAccounts.values.count > 0 else {
                    print("No bank accounts detected")
                    return
                }
                print("Loaded User accounts Successful")
                self.openBankAccounts.values.forEach { account in
                    self.loadTransactions(account: account)
                }
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
                    let transactionsResponses = value["MonetaryTransactionResponseList"] as? [[String: Any]] else {
                        return
                }
                var transactionArr: [Transaction] = []
                // TODO: Support more account types, and store in a persistent backend (requires proper banking API)
                switch account.productCode {
                case "DDA":
                    transactionsResponses.forEach { transactionDict in
                        guard let transaction = TransactionDDA(dict: transactionDict) else {
                            print("Invalid dictionary", transactionDict)
                            return
                        }
                        transactionArr.append(transaction)
                    }
                case "CCD":
                    transactionsResponses.forEach { transactionDict in
                        guard let transaction = TransactionCCD(dict: transactionDict) else {
                            print("Invalid dictionary", transactionDict)
                            return
                        }
                        transactionArr.append(transaction)
                    }
                default: break
                }
                
                // Sort by latest first
                transactionArr.sort(by: { (t1, t2) -> Bool in
                    t1.date > t2.date
                })
                
                // Upsert into store
                if self.transactions[account.productCode] != nil {
                    self.transactions[account.productCode]!.append(contentsOf: transactionArr)
                } else {
                    self.transactions[account.productCode] = transactionArr
                }
                
                print("Loaded account type: " + account.productCode)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
