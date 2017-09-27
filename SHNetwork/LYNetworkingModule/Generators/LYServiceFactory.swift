//
//  LYServiceFactory.swift
//  LYNetworkingModule
//
//  Created by User on 08/09/2017.
//  Copyright © 2017 GoldenMango. All rights reserved.
//

import Foundation

public protocol LYServiceFactoryDataSource: NSObjectProtocol {
    
    func servicesKindsOfServieceFactory() -> [String: String]
}

open class LYServiceFactory {
    
    static let `default` = LYServiceFactory.init()
    private init() {
        self.serviceStorage = NSMutableDictionary.init() as! [NSString : LYService]
    }
    
    var dataSource: LYServiceFactoryDataSource?
    private var serviceStorage: [ NSString: LYService]
    
    func service(_ identifier: NSString) throws -> LYService {
        objc_sync_enter(self.dataSource)
        defer {
            objc_sync_exit(self.dataSource)
        }
        if self.serviceStorage[identifier] == nil {
            
            self.serviceStorage[identifier] = try! self.newService(identifier)
        }
        
        
        return self.serviceStorage[identifier]!
    }
    
    fileprivate func newService(_ identifier: NSString) throws -> LYService? {
        
        let servicesIdentifer: NSDictionary? = self.dataSource?.servicesKindsOfServieceFactory() as NSDictionary?
        if servicesIdentifer != nil {
            let classStr = servicesIdentifer!.object(forKey: identifier) as! NSString
            let moduelName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! NSString
            
            let moduelClassStr = moduelName.appendingFormat(".%@", classStr)
            let anyClass = NSClassFromString(moduelClassStr as String) as! NSObject.Type
            
            
            let service = anyClass.init()
            guard service is LYServiceProtocol else {
                throw LYError.ParameterInputFailureReason.dataError as! Error
            }

            return service as? LYService
        } else {
            throw (LYError.ParameterInputFailureReason.illegalArgument as! Error)
        }
    
//        return nil
    }
}




