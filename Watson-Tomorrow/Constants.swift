//
//  Constants.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 8/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation

struct Constants {
    static let MccCodeFileName = "mcc_codes"
    
    struct Bank {
        static let testUserIds = [
            "913996201744144603",
            "908997180284469041",
            "000996202016520455",
            "913995730031830909",
            "000995928731567433"
        ]
        static let requestHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]

        static let userAccountsEndpoint = "https://api119525live.gateway.akana.com:443/user/accounts"
        static let transactionEndpoint = "https://api119622live.gateway.akana.com:443/account/transactions"
    }
    
}
