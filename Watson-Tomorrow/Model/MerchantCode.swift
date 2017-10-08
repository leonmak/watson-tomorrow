//
//  MerchantCode.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 8/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation

struct MerchantCode: Codable {
    let mcc: String
    let edited_description: String
    let combined_description: String
    let usda_description: String
    let irs_description: String
    let irs_reportable: String
    let id: Int
}
