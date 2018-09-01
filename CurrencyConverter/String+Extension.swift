//
//  String+Extension.swift
//  CurrencyConverter
//
//  Created by Snehil on 09/08/18.
//  Copyright © 2018 Snehil. All rights reserved.
//

import Foundation

extension Float {
    func normalisedStr() -> String{
        var str = ""
        if self == 0 {
            return "0"
        }
        if self.truncatingRemainder(dividingBy: 1.0) == 0 {
            str = String(format: "%.0f", self)
        }else if (self * 10).truncatingRemainder(dividingBy: 1.0) == 0 {
            str = String(format: "%.1f", self)
        }else {
            str = String(format: "%.2f", self)
        }
        
        if str.hasSuffix(".00") {
            let index = str.index(of: ".")!
            return String(str[..<index])
        }
        return str
    }
}


