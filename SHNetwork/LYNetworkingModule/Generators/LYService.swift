//
//  LYService.swift
//  LYNetworkingModule
//
//  Created by User on 08/09/2017.
//  Copyright © 2017 GoldenMango. All rights reserved.
//

import Foundation

// 所有LYService的派生类都要符合这个protocol
public protocol LYServiceProtocol {
    
    var isOnline: Bool { get }
    
    var offlineApiBaseUrl: NSString { get }
    var onlineApiBaseUrl: NSString { get }
    
    var offlineApiVersion: NSString { get }
    var onlineApiVersion: NSString { get }
    
    var offlinePublicKey: NSString { get }
    var onlinePublicKey: NSString { get }
    
    var offlinePrivateKey: NSString { get }
    var onlinePrivateKey: NSString { get }
    
    //optional
    
    /// 返回的数据解密base64
    var base64DecodedResponse: Bool { get }
    
    func extraParams() -> NSDictionary?
    
    func extraHttpHeadParams(_ methodName: NSString) -> NSDictionary?
    
//    func urlGeneratingRule(_ methodName: NSString) -> NSString?
    
    //提供拦截器集中处理Service错误问题，比如token失效要抛通知等
//    - (BOOL)shouldCallBackByFailedOnCallingAPI:(CTURLResponse *)response;
    func shouldCallBackByFailedOnCallingApi(_ response: LYURLResponse?) -> Bool
    
}

extension LYServiceProtocol {
    
    var base64DecodedResponse: Bool {
        return false
    }
    
    func extraParams() -> NSDictionary? {
        return nil
    }
    
    func extraHttpHeadParams(_ methodName: NSString) -> NSDictionary? {
        return nil
    }
    
//    func urlGeneratingRule(_ methodName: NSString) -> NSString? {
//        return nil
//    }
    
    func shouldCallBackByFailedOnCallingApi(_ response: LYURLResponse?) -> Bool {
        return true
    }
}

open class LYService: NSObject {
    
    var publicKey: NSString {
        return self.child!.isOnline ? self.child!.onlinePublicKey : self.child!.offlinePublicKey
    }

    var privateKey: NSString {
        return self.child!.isOnline ? self.child!.onlinePrivateKey : self.child!.offlinePrivateKey
    }

    var apiBaseUrl: NSString {
        return self.child!.isOnline ? self.child!.onlineApiBaseUrl : self.child!.offlineApiBaseUrl
    }

    var apiVersion: NSString {
        return self.child!.isOnline ? self.child!.onlineApiVersion : self.child!.offlineApiVersion
    }
    
    var child: LYServiceProtocol? = nil
    
    override init() {
        super.init()
        
        if self is LYServiceProtocol {
            self.child = self as? LYServiceProtocol
        } else {
            return
        }
    }
    
    
    /*
     * 因为考虑到每家公司的拼凑逻辑都有或多或少不同，
     * 如有的公司为http://abc.com/v2/api/login或者http://v2.abc.com/api/login
     * 所以将默认的方式，有versioin时，则为http://abc.com/v2/api/login
     * 否则，则为http://abc.com/v2/api/login
     */
    func urlGeneratingRule(_ methodName: NSString) -> String {
        var urlString: String
        
        if self.apiVersion.length != 0 {
            urlString = String.init(format: "%@/%@/%@", self.apiBaseUrl, self.apiVersion, methodName)
        } else {
            urlString = String.init(format: "%@/%@", self.apiBaseUrl, methodName)
        }
        
        return urlString
        
    }
}



