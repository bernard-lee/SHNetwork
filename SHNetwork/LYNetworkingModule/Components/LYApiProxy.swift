//
//  LYApiProxy.swift
//  LYNetworkingModule
//
//  Created by User on 01/09/2017.
//  Copyright © 2017 GoldenMango. All rights reserved.
//

import Alamofire
import UIKit

public class LYApiProxy: NSObject {

    static let `default` = LYApiProxy.init()
    
    private var dispatchTable = [NSNumber : URLSessionTask]()
    
    fileprivate var base64DecodedResponse = false
    
    private override init() {}
    
    func callGETMethod(_ params: NSDictionary, serviceIdentifier: NSString, methodName: NSString, success: @escaping (_ response: LYURLResponse) -> (), fail: @escaping (_ response: LYURLResponse) -> ()) -> NSNumber {
        
        let request = self.generateRequest(serviceIdentifier, requestParams: params, methodName: methodName, requestWithMethod: .get)
        let requestId = self.callApi(request, successCallBack: success, failCallBack: fail)
        
        return requestId
    }
    
    func callPOSTMethod(_ params: NSDictionary, serviceIdentifier: NSString, methodName: NSString, success: @escaping (_ response: LYURLResponse) -> (), fail: @escaping (_ response: LYURLResponse) -> ()) -> NSNumber {
        
        let request = self.generateRequest(serviceIdentifier, requestParams: params, methodName: methodName, requestWithMethod: .post)
        let requestId = self.callApi(request, successCallBack: success, failCallBack: fail)
        
        return requestId
    }
    
    func callPUTMethod(_ params: NSDictionary, serviceIdentifier: NSString, methodName: NSString, success: @escaping (_ response: LYURLResponse) -> (), fail: @escaping (_ response: LYURLResponse) -> ()) -> NSNumber {
        
        let request = self.generateRequest(serviceIdentifier, requestParams: params, methodName: methodName, requestWithMethod: .put)
        let requestId = self.callApi(request, successCallBack: success, failCallBack: fail)
        
        return requestId
    }
    
    func callDELETEMethod(_ params: NSDictionary, serviceIdentifier: NSString, methodName: NSString, success: @escaping (_ response: LYURLResponse) -> (), fail: @escaping (_ response: LYURLResponse) -> ()) -> NSNumber {
        
        let request = self.generateRequest(serviceIdentifier, requestParams: params, methodName: methodName, requestWithMethod: .delete)
        let requestId = self.callApi(request, successCallBack: success, failCallBack: fail)
        
        return requestId
    }
    
    func callHTTPMethod(_ requestWithMethod: HTTPMethod, params: NSDictionary, serviceIdentifier: NSString, methodName: NSString, success: @escaping (_ response: LYURLResponse) -> (), fail: @escaping (_ response: LYURLResponse) -> ()) -> NSNumber {
        let request = self.generateRequest(serviceIdentifier, requestParams: params, methodName: methodName, requestWithMethod: requestWithMethod)
        let requestId = self.callApi(request, successCallBack: success, failCallBack: fail)
        
        return requestId
    }
    
    /// 取消某个request请求
    ///
    /// - Parameter requestID: requestID
    func cancelRequest(requestID: NSNumber) -> Void {
        let requestOperation = self.dispatchTable[requestID]
        requestOperation?.cancel()
        
        self.dispatchTable.removeValue(forKey: requestID)
    }
    
    /// 取消一些request请求
    ///
    /// - Parameter requestIDList: <#requestIDList description#>
    func cancelRequest(requestIDList: [NSNumber]) -> Void {
        for requestID in requestIDList {
            self.cancelRequest(requestID: requestID)
        }
    }
    
    
    func callApi(_ request: DataRequest, successCallBack: @escaping (_ response: LYURLResponse) -> (), failCallBack: @escaping (_ response: LYURLResponse) -> ()) -> NSNumber {
        
        request.responseData { (dataResponse) in
            let requestId = NSNumber.init(value: request.task!.taskIdentifier)
            self.dispatchTable.removeValue(forKey: requestId)
            
            var encodingData: NSData = dataResponse.data! as NSData
            if self.base64DecodedResponse {
                encodingData = NSData(base64Encoded: dataResponse.data!, options: NSData.Base64DecodingOptions(rawValue: 0))!
            }
            let responseString = String(data: encodingData as Data, encoding: .utf8)
            
            switch dataResponse.result{
            case .success( _):
                // TODO: to do
                // 检查http response是否成立。
//                [CTLogger logDebugInfoWithResponse:httpResponse
//                responseString:responseString
//                request:request
//                error:NULL];

                let LYResponse = LYURLResponse.init(responseString: responseString!, requestId: requestId, request: request, responseData: encodingData, status: .success)
                successCallBack(LYResponse)
            case .failure(let error):
//                [CTLogger logDebugInfoWithResponse:httpResponse
//                                    responseString:responseString
//                                    request:request
//                                    error:error];
                let LYResponse = LYURLResponse.init(responseString: responseString!, requestId: requestId, request: request, responseData: encodingData, error: error as NSError)
                failCallBack(LYResponse)
            }
        }
        
        let requestId = NSNumber.init(value: request.task!.taskIdentifier)
        
        self.dispatchTable[requestId] = request.task
        return requestId
    }
    
}

extension LYApiProxy {
    
    fileprivate func generateRequest(_ serviceIdentifier: NSString, requestParams: NSDictionary, methodName: NSString, requestWithMethod: HTTPMethod) -> DataRequest {
        let service = try? LYServiceFactory.default.service(serviceIdentifier)
        let urlString = service!.urlGeneratingRule(methodName)
        if service!.child != nil {
            self.base64DecodedResponse = service!.child!.base64DecodedResponse
        }
        
        let totoalRequestParams = self.totoalRequestParams(service!, requestParams: requestParams)
        
        let header: NSDictionary? = nil
        let  dict = service!.child?.extraHttpHeadParams(methodName)
        if dict != nil {
            for (key, value) in dict! {
                header?.setValue(value, forKey: key as! String)
            }
        }
        
        let result = Alamofire.request(urlString, method: requestWithMethod, parameters: (totoalRequestParams as! [String:Any]), encoding: URLEncoding.default, headers: header as? HTTPHeaders)
        
        //这里很重要
        result.requestParams = requestParams
    
        return result
    }
    
    fileprivate func totoalRequestParams(_ service: LYService, requestParams: NSDictionary?) -> NSDictionary? {
        
        let totoalRequestParams = NSMutableDictionary(dictionary: requestParams!)
        
        if ((service.child?.extraParams()) != nil) {
            for (key, value) in (service.child?.extraParams())! {
                totoalRequestParams.setObject(value, forKey: key as! NSCopying)
            }
        }
        
        return totoalRequestParams.copy() as? NSDictionary
    }
    
}
