//
//  LYCache.swift
//  LYNetworkingModule
//
//  Created by User on 20/09/2017.
//  Copyright © 2017 GoldenMango. All rights reserved.
//

import UIKit

open class LYCachedObject: NSObject {
    
     private(set) var content: Data?

    private(set) var lastUpdateTime: Date? = nil
    
    var isOutdated: Bool {
        let timeInterval: TimeInterval = Date().timeIntervalSince(self.lastUpdateTime!)
        return timeInterval > LYNetworkingConfigurationManager.shareInstance.cacheOutDateTimeSeconds
    }
    
    var isEmpty: Bool {
        return self.content == nil
    }
    
    public override init() {
        self.lastUpdateTime = Date(timeIntervalSinceNow: 0)
    }
    
    required public convenience init(content: Data) {
        self.init()
        self.content = content
    }
    
    func update(_ content: Data) -> Void {
        self.content = content
        self.lastUpdateTime = Date(timeIntervalSinceNow: 0)
    }
    
}

class LYCache: NSObject {

    static let `default`: LYCache = {
        return LYCache()
    }()
    
    private override init() {
        self.cache = NSCache<NSString, LYCachedObject>()
        self.cache.countLimit = LYNetworkingConfigurationManager.shareInstance.cacheCountLimit
    }
    
    fileprivate var cache: NSCache<NSString, LYCachedObject>
    
    func fetchCachedData(_ serviceIdentifier: String, methodName: String, requestParams: NSDictionary) -> Data? {
        return self.fetchCachedData(self.key(serviceIdentifier, methodName: methodName, requestParams: requestParams))
    }
    
    func fetchCachedData(_ key: NSString) -> Data? {
        let cachedData = self.cache.object(forKey: key)
        if cachedData == nil || cachedData!.isOutdated || cachedData!.isEmpty {
            return nil
        } else {
            return cachedData!.content
        }
    }

    func saveCache(_ cahcedData: Data, serviceIdentifier: String, methodName: String, requestParams: NSDictionary) -> Void {
        self.saveCache(cahcedData, key: self.key(serviceIdentifier, methodName: methodName, requestParams: requestParams) as NSString)
    }
    
    func saveCache(_ cachedData: Data, key: NSString) -> Void {
        var cachedObject = self.cache.object(forKey: key)
        if cachedObject == nil {
            cachedObject = LYCachedObject(content: cachedData)
        }
        
        self.cache.setObject(cachedObject!, forKey: key)
    }
    
    func deleteCache(_ serviceIdentifier: String, methodName: String, requestParams: NSDictionary) -> Void {
        self.deleteCache(self.key(serviceIdentifier, methodName: methodName, requestParams: requestParams))
    }
    
    func deleteCache(_ key: NSString) -> Void {
        self.cache.removeObject(forKey: key)
    }
    
    func clean() -> Void {
        self.cache.removeAllObjects()
    }
    
    func key(_ serviceIdentifier: String, methodName: String, requestParams: NSDictionary) -> NSString {
        return NSString(format: "%@%@%@", serviceIdentifier, methodName, requestParams.urlParamsString(false))
    }
}
