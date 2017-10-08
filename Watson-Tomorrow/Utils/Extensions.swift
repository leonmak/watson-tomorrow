//
//  Extensions.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 8/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation

extension Date {
    public static func <(a: Date, b: Date) -> Bool{
        return a.compare(b) == ComparisonResult.orderedAscending
    }
    static public func ==(a: Date, b: Date) -> Bool {
        return a.compare(b) == ComparisonResult.orderedSame
    }
}

extension Double {
    public func formatDp(_ power:Double=2.0) -> String {
        let mul = pow(10.0, power)
        return String(floor(self * mul) / mul)
    }
    
    public func formatSign() -> String {
        let amt = self.formatDp()
        var sign = "-"
        if self > 0.0 {
            sign = "+"
        }
        return "\(sign) $\(amt)"
    }
}

extension Date {
    func getString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

