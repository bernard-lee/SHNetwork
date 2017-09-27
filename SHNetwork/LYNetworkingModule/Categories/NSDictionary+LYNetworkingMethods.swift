//
//  NSDictionary+LYNetworkingMethods.swift
//  LYNetworkingModule
//
//  Created by User on 22/09/2017.
//  Copyright © 2017 GoldenMango. All rights reserved.
//

import Foundation

extension NSDictionary {
    
    /// 转义参数
    ///
    /// - Parameter isForSignature: <#isForSignature description#>
    /// - Returns: <#return value description#>
    func transformedUrlParamsArray(_ isForSignature: Bool) -> NSArray {
        let result: NSMutableArray = NSMutableArray()
        
        for (key, value) in self {
            var strValue: NSString
            
            if !(value is NSString) {
                strValue = NSString(format: "%@", value as! CVarArg)
            } else {
                strValue = value as! NSString
            }
            
            if !isForSignature {
                strValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            }
            
            if strValue.length > 0 {
                result.add(NSString(format: "%@=%@", key as! CVarArg, strValue))
            }
        }
        
        
//        let sortedResult = result.sortedArray(using: #selector(result.sort(comparator:)))
        
        return result
    }
    
    func urlParamsString(_ isForSignature: Bool) -> NSString {
        return self.transformedUrlParamsArray(isForSignature).componentsJoined(by: "&") as NSString
    }
    
}
