//
//  DataManager.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 8/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation

class DataManager {
    static let instance = DataManager()

    func getMccJsonFromURL(_ resource:String, completion:@escaping (_ data: [MerchantCode]?, _ error: Error?) -> Void) {
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


    func loadJSON(fileName: String, finishedClosure: @escaping ((_ jsonObject: [String:AnyObject]?, _ error: NSError?) ->Void)) {
        DispatchQueue.global().async {
            
            guard let path = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                DispatchQueue.main.async {
                    finishedClosure(nil, NSError(domain: "JSON file not found in bundle", code: 401, userInfo: nil))
                }
                return
            }
            
            guard let jsonData = (try? Data(contentsOf: path)) else {
                DispatchQueue.main.async {
                    finishedClosure(nil, NSError(domain: "Could not convert JSON file", code: 400, userInfo: nil))
                }
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData,
                                                                     options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject] {
                    DispatchQueue.main.async {
                        print("OK")
                        finishedClosure(jsonObject, nil)
                    }
                }
            } catch let error as NSError {
                print(error)
                DispatchQueue.main.async {
                    finishedClosure(nil, error)
                }
            }
        }
    }

}
