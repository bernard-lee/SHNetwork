//
//  LYURLResponse.swift
//  LYNetworkingModule
//
//  Created by User on 01/09/2017.
//  Copyright © 2017 GoldenMango. All rights reserved.
//

import Foundation
import Alamofire

public struct LYURLResponse {

    public enum LYURLResponseStatus {
        ///作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的CTAPIBaseManager来决定。
        case success
        case errorTimeout
        case errorNoNetwork // 默认除了超时以外的错误都是无网络错误。
    }
    
    public let status: LYURLResponseStatus

    public let contentString: NSString?
    
    public let content: Any?
    
    public let requestId: NSNumber?
    
    public let request: Request?
    
    public let responseData: NSData?
    
    public var requestParams: NSDictionary = [:]
    
    public let error: NSError?
    
    public let isCache: Bool
    
    public init(responseString: String, requestId: NSNumber, request: Request, responseData: NSData, status: LYURLResponseStatus) {
        self.contentString = responseString as NSString
        self.content = try? JSONSerialization.jsonObject(with: responseData as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
        self.status = status
        self.requestId = requestId
        self.request = request
        self.responseData = responseData
        self.requestParams = request.requestParams
        self.isCache = false
        self.error = nil
    }
    
    public init(responseString: String, requestId: NSNumber, request: Request, responseData: NSData?, error: NSError?) {
        self.contentString = responseString as NSString
        self.requestId = requestId
        self.request = request
        self.responseData = responseData
        self.requestParams = request.requestParams
        self.isCache = false
        self.error = error
        if responseData != nil {
            self.content = try? JSONSerialization.jsonObject(with: responseData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
        } else {
            self.content = nil
        }
        
        if (error != nil) {
            if error?.code == NSURLErrorTimedOut {
                self.status = .errorTimeout
            } else {
                self.status = .errorNoNetwork
            }
        } else {
            self.status = .success
        }
        
    }

    /// 使用initWithData的response，它的isCache是YES，上面两个函数生成的response的isCache是NO
    init(data: NSData?) {
        self.contentString = NSString.init(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
        self.status = .success
        self.requestId = nil
        self.request = nil
        self.responseData = data?.copy() as? NSData
        self.content = try? JSONSerialization.jsonObject(with: responseData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers)
        self.isCache = true
        self.error = nil
    }
    
//    private func responseStatusWithError(_ error: NSError?) ->LYURLResponseStatus {
//        if (error != nil) {
//            let result = LYURLResponseStatus.LYURLResponseStatusErrorNoNetwork
//            if error?.code == NSURLErrorTimedOut {
//                return LYURLResponseStatus.LYURLResponseStatusErrorTimeout
//            } else {
//                return result
//            }
//        }
//        
//        return LYURLResponseStatus.LYURLResponseStatusSuccess
//    }
    
}
