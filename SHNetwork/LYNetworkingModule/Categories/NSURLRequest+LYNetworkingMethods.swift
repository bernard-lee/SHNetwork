//
//  NSURLRequest+LYNetworkingMethods.swift
//  LYNetworkingModule
//
//  Created by User on 04/09/2017.
//  Copyright © 2017 GoldenMango. All rights reserved.
//

import Foundation
import Alamofire

extension Request {
    
    struct RuntimeKey {
        static let LYNetworkingRequestParams = UnsafeRawPointer.init(bitPattern: "LYNetworkingRequestParams".hashValue)
    }
    
    var requestParams: NSDictionary {
        get {
            return objc_getAssociatedObject(self, Request.RuntimeKey.LYNetworkingRequestParams) as! NSDictionary
        }
        set {
            objc_setAssociatedObject(self, Request.RuntimeKey.LYNetworkingRequestParams, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
