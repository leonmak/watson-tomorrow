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

