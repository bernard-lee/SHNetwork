//
//  LYNetworkingConfigurationManager.swift
//  LYNetworkingModule
//
//  Created by User on 01/09/2017.
//  Copyright © 2017 GoldenMango. All rights reserved.
//

import UIKit
import Alamofire

class LYNetworkingConfigurationManager: NSObject {
    
    static let shareInstance = LYNetworkingConfigurationManager()
    private let netManager = NetworkReachabilityManager()
    private override init() {
        self.netManager?.startListening()
    }

    var isReachable: Bool {
        if self.netManager?.networkReachabilityStatus == NetworkReachabilityManager.NetworkReachabilityStatus.unknown {
            return true
        } else {
            return (self.netManager?.isReachable)!
        }
        
    }
    
    var shouldCache: Bool = true
    var serviceIsOnline: Bool = false
    var apiNetworkingTimeoutSeconds: TimeInterval = 20.0
    var cacheOutDateTimeSeconds: TimeInterval = 300.0
    var cacheCountLimit: NSInteger = 1000
    
    //默认值为NO，当值为YES时，HTTP请求除了GET请求，其他的请求都会将参数放到HTTPBody中，如下所示
    var shouldSetParamsInHTTPBodyButGET: Bool = false
    
}
